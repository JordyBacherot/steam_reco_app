import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyToken = 'jwt_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Read value from secure storage
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

  // Write value to secure storage
  Future<void> writeToken(String value) async {
    try {
      log('SecureStorage: Writing $_keyToken...');
      await _storage.write(key: _keyToken, value: value);
    } catch (e) {
      log('SecureStorage Error: Failed to write $_keyToken: $e');
    }
  }

  Future<void> writeRefreshToken(String value) async {
    try {
      log('SecureStorage: Writing $_keyRefreshToken...');
      await _storage.write(key: _keyRefreshToken, value: value);
    } catch (e) {
      log('SecureStorage Error: Failed to write $_keyRefreshToken: $e');
    }
  }

  // Delete value from secure storage
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
