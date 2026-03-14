import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

/// A wrapper around `FlutterSecureStorage` for managing sensitive credentials.
///
/// Provides high-level methods to read, write, and delete JWT access
/// and refresh tokens securely on the device.
class SecureStorage {
  /// Internal storage instance.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Key used for the primary JWT access token.
  static const String _keyToken = 'jwt_token';
  
  /// Key used for the long-lived refresh token.
  static const String _keyRefreshToken = 'refresh_token';

  /// Reads the primary JWT access token from secure storage.
  ///
  /// Returns null if the token is missing or if an error occurs.
  Future<String?> readToken() async {
    try {
      final value = await _storage.read(key: _keyToken);
      log('SecureStorage: Read $_keyToken (Found: ${value != null})');
      return value;
    } catch (e) {
      log('SecureStorage Error: Failed to read $_keyToken: $e');
      return null;
    }
  }

  /// Reads the refresh token from secure storage.
  ///
  /// Returns null if the token is missing or if an error occurs.
  Future<String?> readRefreshToken() async {
    try {
      final value = await _storage.read(key: _keyRefreshToken);
      log('SecureStorage: Read $_keyRefreshToken (Found: ${value != null})');
      return value;
    } catch (e) {
      log('SecureStorage Error: Failed to read $_keyRefreshToken: $e');
      return null;
    }
  }

  /// Persists the primary JWT access token.
  Future<void> writeToken(String value) async {
    try {
      log('SecureStorage: Writing $_keyToken...');
      await _storage.write(key: _keyToken, value: value);
    } catch (e) {
      log('SecureStorage Error: Failed to write $_keyToken: $e');
    }
  }

  /// Persists the long-lived refresh token.
  Future<void> writeRefreshToken(String value) async {
    try {
      log('SecureStorage: Writing $_keyRefreshToken...');
      await _storage.write(key: _keyRefreshToken, value: value);
    } catch (e) {
      log('SecureStorage Error: Failed to write $_keyRefreshToken: $e');
    }
  }

  /// Deletes all stored authentication tokens.
  ///
  /// Usually called during logout or when a session becomes irrecoverable.
  Future<void> deleteTokens() async {
    try {
      log('SecureStorage: Deleting all tokens...');
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      log('SecureStorage Error: Failed to delete tokens: $e');
    }
  }
}
