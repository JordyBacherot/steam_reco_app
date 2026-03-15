import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/core/network/secure_storage.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart'; // N'oublie pas cet import tout en haut

/// A centralized HTTP client using the `dio` package.
///
/// This client is responsible for:
/// - Configuring the base URL from environment variables.
/// - Injecting authentication tokens into request headers.
/// - Handling token refresh logic on 401 Unauthorized responses.
class ApiClient {
  /// The underlying Dio instance used for network requests.
  late Dio dio;

  /// Helper for interacting with secure storage for tokens.
  final SecureStorage _secureStorage = SecureStorage();

  /// Initializes the [ApiClient] with base options and interceptors.
  ApiClient() {
    // Determine base URL, falling back to local host if not provided.
    final baseUrl = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? (dotenv.env['API_URL_EMULATOR'] ?? 'http://10.0.2.2:3000')
            : (dotenv.env['API_URL'] ?? 'http://127.0.0.1:3000'))
        .replaceAll(RegExp(r'/$'), '');

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for authentication and error recovery.
    dio.interceptors.add(
      InterceptorsWrapper(
        /// Attaches the Bearer token to every request if available in storage.
        onRequest: (options, handler) async {
          final token = await _secureStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        /// Intercepts errors to handle automatic token refresh.
        onError: (DioException error, handler) async {
          // Pass through any errors that aren't 401 Unauthorized.
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          log('ApiClient: 401 Unauthorized. Attempting token refresh...');
          final refreshToken = await _secureStorage.readRefreshToken();

          // Cannot recover if no refresh token is present.
          if (refreshToken == null) {
            return handler.next(error);
          }

          try {
            // Use a dedicated Dio instance for refresh to avoid interceptor recursion.
            log('ApiClient: Requesting token refresh at /auth/refresh...');
            final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
            final response = await refreshDio.post('/auth/refresh', data: {
              'refreshToken': refreshToken,
            });

            if (response.statusCode == 200) {
              final newAccessToken = response.data['data']['token'];
              final newRefreshToken = response.data['data']['refreshToken'];

              // Persist new credentials.
              await _secureStorage.writeToken(newAccessToken);
              if (newRefreshToken != null) {
                await _secureStorage.writeRefreshToken(newRefreshToken);
              }

              // Retry the failed request with the new access token.
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(options);
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            log('ApiClient: Token refresh attempt failed: $e');
            // Clear invalid tokens on failure to force a fresh login.
            await _secureStorage.deleteTokens();
          }

          return handler.next(error);
        },
      ),
    );
  }
}
