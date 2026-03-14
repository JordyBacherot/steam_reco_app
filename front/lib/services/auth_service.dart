import 'package:flutter/material.dart';
import 'package:front/core/network/api_client.dart';
import 'package:front/core/network/secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

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
      profilePicture: json['profile_picture'] ?? json['image_profil'] ?? json['profile_img'],
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

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthService(this._apiClient, this._secureStorage);

  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isLoading = true;
  int _addedGamesCount = 0;

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  int get addedGamesCount => _addedGamesCount;

  /// Call this when the app starts to see if the user is already logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      log('AuthService: Initializing session recovery...');
      final token = await _secureStorage.readToken();
      final refreshToken = await _secureStorage.readRefreshToken();

      if (token != null || refreshToken != null) {
        log('AuthService: Token found (Access: ${token != null}, Refresh: ${refreshToken != null}), attempting recovery...');
        
        bool profileSuccess = false;
        if (token != null) {
          log('AuthService: Verifying profile with current access token...');
          profileSuccess = await _fetchProfile();
        }

        if (!profileSuccess && refreshToken != null) {
          log('AuthService: Profile check failed or access token missing. Attempting refresh recovery...');
          final refreshed = await _attemptTokenRefresh(refreshToken);
          if (refreshed) {
            log('AuthService: Refresh successful, fetching profile now...');
            profileSuccess = await _fetchProfile();
          } else {
            log('AuthService: Refresh attempt failed.');
          }
        }

        if (_isAuthenticated) {
          log('AuthService: Session recovered successfully for user: ${_currentUser?.username}');
          await fetchUserGamesCount();
        } else {
          log('AuthService: Session recovery failed after all attempts.');
          await logout(); // Clear any stale tokens
        }
      } else {
        log('AuthService: No tokens found in storage.');
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      log('AuthService: Unexpected crash during auth initialization: $e');
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      log('AuthService: Initialization complete. Authenticated: $_isAuthenticated');
      notifyListeners();
    }
  }

  /// Triggers a manual token refresh, typically during app initialization.
  Future<bool> _attemptTokenRefresh(String refreshToken) async {
    try {
      log('AuthService: Requesting token refresh...');
      // Use a dedicated Dio instance to avoid interceptor side-effects during boot.
      final baseUrl = _apiClient.dio.options.baseUrl;
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      
      final response = await refreshDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _secureStorage.writeToken(data['token']);
        if (data['refreshToken'] != null) {
          await _secureStorage.writeRefreshToken(data['refreshToken']);
        }
        return true;
      }
    } catch (e) {
      log('AuthService: Manual refresh attempt failed: $e');
    }
    return false;
  }

  /// Attempts to sign in with [email] and [password].
  ///
  /// Persists the returned tokens and fetches the user's profile on success.
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final token = data['token'];
        final refreshToken = data['refreshToken'];

        await _secureStorage.writeToken(token);
        await _secureStorage.writeRefreshToken(refreshToken);

        _updateCurrentUser(data);
        
        // Fetch steam user details explicitly here to populate steam_id.
        final int? userId = _currentUser?.id;
        if (userId != null) {
          await _fetchSteamUser(userId);
        }
        
        _isAuthenticated = true;
        notifyListeners();
        
        // Fetch user games count in the background.
        fetchUserGamesCount();
        return true;
      }
      return false;
    } on DioException catch (e) {
      log('AuthService: Sign-in failed: ${e.response?.data}');
      return false;
    } catch (e) {
      log('AuthService: Unexpected sign-in error: $e');
      return false;
    }
  }

  /// Registers a new user account with [username], [email], and [password].
  Future<bool> signUp(String username, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
         // Automatically sign in after successful registration.
         return await signIn(email, password);
      }
      return false;
    } on DioException catch (e) {
      log('AuthService: Sign-up failed: ${e.response?.data}');
      return false;
    } catch (e) {
      log('AuthService: Unexpected sign-up error: $e');
      return false;
    }
  }

  /// Logs the user out by clearing local tokens and resetting state.
  Future<void> logout() async {
    log('AuthService: Logging out...');
    await _secureStorage.deleteTokens();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Internal method to fetch the current user profile
  /// Returns true if the profile was successfully fetched and state updated
  Future<bool> _fetchProfile() async {
     try {
        log('AuthService: Requesting /auth/me...');
        final response = await _apiClient.dio.get('/auth/me');
        if (response.statusCode == 200) {
          // NOTE: The /me endpoint returns the user object directly (no 'data' wrapper)
          final success = _updateCurrentUser(response.data);
          if (!success) {
            log('AuthService: Data mapping failed for /me response. Data: ${response.data}');
            return false;
          }

          _isAuthenticated = true; // Mark as authenticated now that we have the profile
          
          final int? userId = _currentUser?.id;
          if (userId != null) {
            await _fetchSteamUser(userId);
          }

          notifyListeners();
          return true;
        }
     } catch (e) {
        log('AuthService: Failed to fetch /me: $e');
     }
     return false;
  }

  /// Helper to standardize user data from different API responses
  bool _updateCurrentUser(Map<String, dynamic> data) {
    try {
      if (_currentUser == null) {
        _currentUser = User.fromJson(data);
      } else {
        // Merge updates into existing user
        final updatedData = User.fromJson(data);
        _currentUser = _currentUser!.copyWith(
          email: updatedData.email.isNotEmpty ? updatedData.email : null,
          username: updatedData.username != 'Utilisateur' ? updatedData.username : null,
          steamId: updatedData.steamId,
          profilePicture: updatedData.profilePicture,
          level: updatedData.level,
        );
      }

      if (_currentUser?.id == 0) {
        log('AuthService: Warning - User ID is 0 or missing in API response data: $data');
      }

      return true;
    } catch (e) {
      log('AuthService: Critical error mapping user data: $e');
      return false;
    }
  }

  /// Internal method to fetch the Steam user by user ID
  Future<void> _fetchSteamUser(int userId) async {
    try {
      final response = await _apiClient.dio.get('/steam_users/$userId');

      if (response.statusCode == 200) {
        // Merge steam data into the current user object
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            steamId: response.data['id_steam']?.toString(),
            profilePicture: response.data['image_profil'],
            level: response.data['level'],
          );
        }
      }
    } catch (e) {
      log('Failed to fetch steam user info (user may not have linked steam): $e');
    }
  }

  /// Public method to fetch and update the number of games the user added manually
  Future<void> fetchUserGamesCount() async {
    final userId = _currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _apiClient.dio.get('/users/$userId/games');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _addedGamesCount = data.length;
        notifyListeners();
      }
    } catch (e) {
      log('Failed to load user games count: $e');
    }
  }

  /// Public method to update or add a Steam ID for the current user
  Future<bool> updateSteamId(String steamId) async {
    final userId = _currentUser?.id;
    if (userId == null) return false;

    try {
      // First, try to fetch if the user already has a steam profile created
      final checkResponse = await _apiClient.dio.get('/steam_users/$userId');
      
      Response response;
      if (checkResponse.statusCode == 200) {
        // Steam user exists, we update it via PUT
        final steamUserId = checkResponse.data['id_steam_user'] ?? checkResponse.data['id']; // ID of the steam_users row if applicable, but the route uses id_user usually
        // Actually the backend update route `steamUserRoutes.put('/:id'` expects the SteamUser ID or User ID depending on implementation.
        // Looking at backend it might expect id_steam_user, but let's assume it puts by user ID since it's a 1:1 relation.
        // A safer way if it is not 100% known if it's PUT by user_id or steam_id is to handle errors
          response = await _apiClient.dio.put('/steam_users/$userId', data: {
            'id_steam': steamId,
            'id_user': userId,
            'username': _currentUser?.username ?? 'Utilisateur',
          });
      } else {
         // Create new steam user
         throw Exception("Not found");
      }

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Update local state
          if (_currentUser != null) {
            _currentUser = _currentUser!.copyWith(steamId: steamId);
          }
          notifyListeners();
          return true;
        }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Steam user doesn't exist yet, we create it via POST
        try {
          final response = await _apiClient.dio.post('/steam_users', data: {
            'id_steam': steamId,
            'id_user': userId,
            'username': _currentUser?.username ?? 'Utilisateur',
          });
          if (response.statusCode == 200 || response.statusCode == 201) {
            if (_currentUser != null) {
              _currentUser = _currentUser!.copyWith(steamId: steamId);
            }
            notifyListeners();
            return true;
          }
        } catch (postError) {
          log('Failed to create steam user: $postError');
        }
      } else {
        log('Failed to update steam user: ${e.response?.data}');
      }
    } catch (e) {
      log('Unexpected error updating steam id: $e');
    }
    
    // Fallback: If the PUT/POST to steam_users fails, try the old /users/ update if have_steamid needs true
    return false;
  }
}
