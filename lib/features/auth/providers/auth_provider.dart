import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/services/secure_storage_service.dart';

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

final _apiTimeoutDuration = const Duration(seconds: 20);
final _storageTimeoutDuration = const Duration(seconds: 10);

/// Helper function to retry with exponential backoff
Future<T> _retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
  double backoffMultiplier = 2.0,
}) async {
  int retryCount = 0;
  Duration currentDelay = initialDelay;

  while (true) {
    try {
      return await operation();
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries) {
        rethrow;
      }
      // Only retry on timeout or network errors
      if (e is TimeoutException ||
          (e is DioException && (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout))) {
        await Future.delayed(currentDelay);
        currentDelay *= backoffMultiplier;
      } else {
        rethrow;
      }
    }
  }
}

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storage = ref.read(secureStorageProvider);
    try {
      final token = await storage.getToken().timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Storage access timed out',
          );
        },
      );

      if (token == null || token.isEmpty) {
        return false;
      }

      // Validate token by calling /profile
      return await _retryWithBackoff(
        () async {
          final dio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            connectTimeout: _apiTimeoutDuration,
            receiveTimeout: _apiTimeoutDuration,
            sendTimeout: _apiTimeoutDuration,
          ));

          final response = await dio.get(ApiConstants.profile).timeout(
            _apiTimeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'API validation timed out after ${_apiTimeoutDuration.inSeconds} seconds.',
              );
            },
          );

          return response.statusCode == 200;
        },
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 500),
      );
    } catch (e) {
      // If token validation fails, assume not authenticated
      // ignore: avoid_print
      print('Auth check error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      return await _retryWithBackoff(
        () async {
          final dio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseWebUrl,
            headers: {
              'Accept': 'application/json',
            },
            connectTimeout: _apiTimeoutDuration,
            receiveTimeout: _apiTimeoutDuration,
            sendTimeout: _apiTimeoutDuration,
          ));

          final response = await dio.post(
            ApiConstants.login,
            data: {
              'email': email,
              'password': password,
              'timezone': DateTime.now().timeZoneOffset.inHours,
            },
          ).timeout(
            _apiTimeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'Login timed out after ${_apiTimeoutDuration.inSeconds} seconds. Please check your network connection.',
              );
            },
          );

          if (response.statusCode == 200) {
            // Extract token from response
            final token = response.data['token'] ??
                response.data['access_token'] ??
                response.data['data']['token'];

            if (token == null) {
              throw Exception('No token in response');
            }

            final storage = ref.read(secureStorageProvider);
            await storage.saveToken(token).timeout(
              _storageTimeoutDuration,
              onTimeout: () {
                throw TimeoutException(
                  'Failed to save credentials',
                );
              },
            );
            state = const AsyncValue.data(true);
            return true;
          }

          state = const AsyncValue.data(false);
          return false;
        },
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 500),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAll();
    state = const AsyncValue.data(false);
  }
}
