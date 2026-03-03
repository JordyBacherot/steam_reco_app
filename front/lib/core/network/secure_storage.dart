import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Read value from secure storage
  Future<String?> readToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Write value to secure storage
  Future<void> writeToken(String value) async {
    await _storage.write(key: _keyToken, value: value);
  }

  Future<void> writeRefreshToken(String value) async {
    await _storage.write(key: _keyRefreshToken, value: value);
  }

  // Delete value from secure storage
  Future<void> deleteTokens() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
  }
}
