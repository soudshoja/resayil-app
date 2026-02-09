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
      return await storage.hasApiKey().timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Storage access timed out',
          );
        },
      );
    } catch (e) {
      // If storage times out, assume no API key
      // ignore: avoid_print
      print('Auth check storage error: $e');
      return false;
    }
  }

  Future<bool> login(String apiKey) async {
    state = const AsyncValue.loading();
    try {
      // Validate API key by calling /profile with retry logic
      return await _retryWithBackoff(
        () async {
          final dio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            headers: {
              'Authorization': 'Bearer $apiKey',
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
                'API authentication timed out after ${_apiTimeoutDuration.inSeconds} seconds. Please check your network connection.',
              );
            },
          );

          if (response.statusCode == 200) {
            final storage = ref.read(secureStorageProvider);
            await storage.saveApiKey(apiKey).timeout(
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
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 500),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAll();
    state = const AsyncValue.data(false);
  }
}
