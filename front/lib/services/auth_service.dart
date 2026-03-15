import 'package:flutter/material.dart';
import 'package:front/core/network/api_client.dart';
import 'package:front/core/network/secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class User {
  final int id;
  final String email;
  final String username;
  final String? steamId;
  final String? profilePicture;
  final int? level;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.steamId,
    this.profilePicture,
    this.level,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_user'] ?? json['user_id'] ?? json['id'];
    int parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else {
      parsedId = int.tryParse(rawId?.toString() ?? '') ?? 0;
    }

    return User(
      id: parsedId,
      email: json['user_email'] ?? json['email'] ?? '',
      username: json['username'] ?? 'Utilisateur',
      steamId: (json['id_steam'] ?? json['steam_id'])?.toString(),
      profilePicture:
          json['profile_picture'] ?? json['image_profil'] ?? json['profile_img'],
      level: json['level'],
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? steamId,
    String? profilePicture,
    int? level,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      steamId: steamId ?? this.steamId,
      profilePicture: profilePicture ?? this.profilePicture,
      level: level ?? this.level,
    );
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthService(this._apiClient, this._secureStorage);

  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Call this when the app starts to restore a previous session if one exists.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      log('AuthService: Initializing session recovery...');
      final token = await _secureStorage.readToken();
      final refreshToken = await _secureStorage.readRefreshToken();

      if (token != null || refreshToken != null) {
        bool profileSuccess = false;

        if (token != null) {
          log('AuthService: Verifying profile with current access token...');
          profileSuccess = await _fetchProfile();
        }

        if (!profileSuccess && refreshToken != null) {
          log('AuthService: Access token failed. Attempting refresh...');
          final refreshed = await _attemptTokenRefresh(refreshToken);
          if (refreshed) {
            profileSuccess = await _fetchProfile();
          }
        }

        if (!_isAuthenticated) {
          log('AuthService: Session recovery failed. Clearing stale tokens.');
          await logout();
        } else {
          log('AuthService: Session recovered for ${_currentUser?.username}.');
        }
      } else {
        log('AuthService: No tokens found in storage.');
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      log('AuthService: Crash during init: $e');
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      log('AuthService: Init complete. Authenticated: $_isAuthenticated');
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Auth actions
  // ---------------------------------------------------------------------------

  /// Signs in with [email] and [password].
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        await _secureStorage.writeToken(data['token']);
        await _secureStorage.writeRefreshToken(data['refreshToken']);

        _updateCurrentUser(data);

        final int? userId = _currentUser?.id;
        if (userId != null) await _fetchSteamUser(userId);

        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      log('AuthService: Sign-in failed: ${e.response?.data}');
    } catch (e) {
      log('AuthService: Unexpected sign-in error: $e');
    }
    return false;
  }

  /// Registers a new account, then automatically signs in on success.
  Future<bool> signUp(String username, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/signup', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return await signIn(email, password);
      }
    } on DioException catch (e) {
      log('AuthService: Sign-up failed: ${e.response?.data}');
    } catch (e) {
      log('AuthService: Unexpected sign-up error: $e');
    }
    return false;
  }

  /// Logs out by clearing local tokens and resetting state.
  Future<void> logout() async {
    log('AuthService: Logging out...');
    await _secureStorage.deleteTokens();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Permanently deletes the current user's account, then logs out.
  Future<bool> deleteAccount() async {
    final userId = _currentUser?.id;
    if (userId == null) return false;

    try {
      log('AuthService: Deleting account for user $userId...');
      final response = await _apiClient.dio.delete('/users/$userId');

      if (response.statusCode == 200) {
        await logout();
        return true;
      }
    } on DioException catch (e) {
      log('AuthService: Account deletion failed: ${e.response?.data}');
    } catch (e) {
      log('AuthService: Unexpected error deleting account: $e');
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Steam
  // ---------------------------------------------------------------------------

  /// Links or updates a Steam ID for the current user.
  ///
  /// Tries PUT first; if the backend returns 404 (no Steam profile yet), falls
  /// back to POST to create one.
  Future<bool> updateSteamId(String steamId) async {
    final userId = _currentUser?.id;
    if (userId == null) return false;

    final body = {
      'id_steam': steamId,
      'id_user': userId,
      'username': _currentUser?.username ?? 'Utilisateur',
    };

    try {
      // Try updating an existing steam profile.
      final response =
          await _apiClient.dio.put('/steam_users/$userId', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _currentUser = _currentUser!.copyWith(steamId: steamId);
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No steam profile yet — create one.
        try {
          final response =
              await _apiClient.dio.post('/steam_users', data: body);
          if (response.statusCode == 200 || response.statusCode == 201) {
            _currentUser = _currentUser!.copyWith(steamId: steamId);
            notifyListeners();
            return true;
          }
        } catch (postError) {
          log('AuthService: Failed to create steam profile: $postError');
        }
      } else {
        log('AuthService: Failed to update steam profile: ${e.response?.data}');
      }
    } catch (e) {
      log('AuthService: Unexpected error in updateSteamId: $e');
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<bool> _attemptTokenRefresh(String refreshToken) async {
    try {
      log('AuthService: Requesting token refresh...');
      final baseUrl = _apiClient.dio.options.baseUrl;
      // Use a fresh Dio to avoid interceptor loops during boot.
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));

      final response = await refreshDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        await _secureStorage.writeToken(data['token']);
        if (data['refreshToken'] != null) {
          await _secureStorage.writeRefreshToken(data['refreshToken']);
        }
        return true;
      }
    } catch (e) {
      log('AuthService: Token refresh failed: $e');
    }
    return false;
  }

  Future<bool> _fetchProfile() async {
    try {
      log('AuthService: Requesting /auth/me...');
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        final success =
            _updateCurrentUser(response.data as Map<String, dynamic>);
        if (!success) {
          log('AuthService: Data mapping failed. Data: ${response.data}');
          return false;
        }

        _isAuthenticated = true;

        final int? userId = _currentUser?.id;
        if (userId != null) await _fetchSteamUser(userId);

        notifyListeners();
        return true;
      }
    } catch (e) {
      log('AuthService: Failed to fetch /me: $e');
    }
    return false;
  }

  bool _updateCurrentUser(Map<String, dynamic> data) {
    try {
      if (_currentUser == null) {
        _currentUser = User.fromJson(data);
      } else {
        final updated = User.fromJson(data);
        _currentUser = _currentUser!.copyWith(
          email: updated.email.isNotEmpty ? updated.email : null,
          username: updated.username != 'Utilisateur' ? updated.username : null,
          steamId: updated.steamId,
          profilePicture: updated.profilePicture,
          level: updated.level,
        );
      }

      if (_currentUser?.id == 0) {
        log('AuthService: Warning — user ID is 0. Raw data: $data');
      }
      return true;
    } catch (e) {
      log('AuthService: Critical error mapping user data: $e');
      return false;
    }
  }

  Future<void> _fetchSteamUser(int userId) async {
    try {
      final response = await _apiClient.dio.get('/steam_users/$userId');
      if (response.statusCode == 200 && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          steamId: response.data['id_steam']?.toString(),
          profilePicture: response.data['image_profil'],
          level: response.data['level'],
        );
      }
    } catch (e) {
      log('AuthService: No Steam profile found for user $userId (may not be linked).');
    }
  }
}
