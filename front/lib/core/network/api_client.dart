import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/core/network/secure_storage.dart';
import 'dart:developer';

class ApiClient {
  late Dio dio;
  final SecureStorage _secureStorage = SecureStorage();

  ApiClient() {
    final baseUrl = (dotenv.env['API_URL'] ?? 'http://127.0.0.1:3000').replaceAll(RegExp(r'/$'), '');

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add access token to all requests if it exists
          final token = await _secureStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If NOT a 401 Unauthorized, pass the error along
          if (error.response?.statusCode != 401) {
            return handler.next(error);
          }

          // If a 401 occurs, try to refresh the token gracefully
          log('401 Unauthorized encountered. Attempting token refresh...');
          final refreshToken = await _secureStorage.readRefreshToken();

          // If there is no refresh token, we can't recover
          if (refreshToken == null) {
             return handler.next(error);
          }

          try {
             // Create a new fresh Dio instance without interceptors for the refresh request
             // so it doesn't loop infinitely getting stuck in 401s
             log('ApiClient: Attempting refresh at /auth/refresh...');
             final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
             final response = await refreshDio.post('/auth/refresh', data: {
               'refreshToken': refreshToken,
             });

             if (response.statusCode == 200) {
               final newAccessToken = response.data['data']['token'];
               final newRefreshToken = response.data['data']['refreshToken']; // Backend returns a new one?

               // Save the new tokens
               await _secureStorage.writeToken(newAccessToken);
               if (newRefreshToken != null) {
                 await _secureStorage.writeRefreshToken(newRefreshToken);
               }

               // Modify the original failed request headers with the new token
               final options = error.requestOptions;
               options.headers['Authorization'] = 'Bearer $newAccessToken';

               // Retry the failed request
               final retryResponse = await dio.fetch(options);
               return handler.resolve(retryResponse);
             }
          } catch (e) {
             log('Token refresh failed: $e');
             // If the refresh call itself fails (e.g. refresh token expired), we log the user out.
             // Usually accomplished by throwing an error that the AuthService catches,
             // or resolving with an error event.
             await _secureStorage.deleteTokens(); // Clear invalid tokens
          }
          
          return handler.next(error); // Reject the original request
        },
      ),
    );
  }
}
