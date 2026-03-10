import 'package:flutter/material.dart';
import 'package:front/core/network/api_client.dart';
import 'package:front/core/network/secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SecureStorage _secureStorage = SecureStorage();

  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true; // Indicates whether we are checking the initial token
  int _addedGamesCount = 0;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  int get addedGamesCount => _addedGamesCount;

  /// Call this when the app starts to see if the user is already logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.readToken();
      if (token != null) {
        // Optimistically set authenticated to true to show the UI quickly
        _isAuthenticated = true;
        // Optionally fetch the user profile from /me
        await _fetchProfile();
        
        // Fetch user games count
        await fetchUserGamesCount();
      } else {
         _isAuthenticated = false;
         _currentUser = null;
      }
    } catch (e) {
      log('Error during auth initialization: $e');
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs the user in with their email and password
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
         final data = response.data['data'];
         final token = data['token'];
         final refreshToken = data['refreshToken'];

         await _secureStorage.writeToken(token);
         await _secureStorage.writeRefreshToken(refreshToken);

         _currentUser = {
           'id': data['user_id'],
           'email': data['user_email'],
           'username': data['username'],
         };
         
         // Fetch steam user details explicitly here to populate steam_id
         await _fetchSteamUser(data['user_id']);
         
         _isAuthenticated = true;
         notifyListeners();
         
         // Fetch games in background
         fetchUserGamesCount();
         return true;
      }
      return false;
    } on DioException catch (e) {
      log('Sign-in failed: ${e.response?.data}');
      return false;
    } catch (e) {
      log('Unexpected sign-in error: $e');
      return false;
    }
  }

  /// Registers a new user
  Future<bool> signUp(String username, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/signup', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
         // Auto sign-in after successful registration
         return await signIn(email, password);
      }
      return false;
    } on DioException catch (e) {
      log('Sign-up failed: ${e.response?.data}');
      return false;
    } catch (e) {
      log('Unexpected sign-up error: $e');
      return false;
    }
  }

  /// Logs the user out
  Future<void> logout() async {
    // Delete tokens from secure storage
    await _secureStorage.deleteTokens();
    
    // Clear state
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  /// Internal method to fetch the current user profile
  Future<void> _fetchProfile() async {
     try {
        final response = await _apiClient.dio.get('/auth/me');
        if (response.statusCode == 200) {
           _currentUser = response.data['data'];
           
           // Fetch steam user details explicitly here to populate steam_id
           // Ensure we use the correct user ID from the response 
           final int userId = _currentUser!['id_user'] ?? _currentUser!['id'];
           await _fetchSteamUser(userId);
           
           notifyListeners();
        }
     } catch (e) {
        log('Failed to fetch user profile: $e');
        // If /me fails with 401, the interceptor will try to refresh.
        // If refresh fails, it clears tokens, but we should also update state here just in case!
        final token = await _secureStorage.readToken();
        if (token == null) {
           _isAuthenticated = false;
           _currentUser = null;
           notifyListeners();
        }
     }
  }

  /// Internal method to fetch the Steam user by user ID
  Future<void> _fetchSteamUser(int userId) async {
    try {
      final response = await _apiClient.dio.get('/steam_users/$userId');

      if (response.statusCode == 200) {
        // Merge steam data into the current user object
        _currentUser ??= {};
        _currentUser!['steam_id'] = response.data['id_steam']?.toString();
        // The backend returns the column name 'image_profil', not 'profile_img'
        _currentUser!['profile_picture'] = response.data['image_profil'];
        _currentUser!['level'] = response.data['level'];
      }
    } catch (e) {
      log('Failed to fetch steam user info (user may not have linked steam): $e');
    }
  }

  /// Public method to fetch and update the number of games the user added manually
  Future<void> fetchUserGamesCount() async {
    final userId = _currentUser?['id'] ?? _currentUser?['id_user'];
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
}
