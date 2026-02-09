import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final storage = ref.watch(secureStorageProvider);
  dio.interceptors.addAll([
    AuthInterceptor(
      storage,
      onUnauthorized: () {
        // Invalidate auth state to trigger logout and redirect to login
        ref.invalidate(authStateProvider);
      },
    ),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  ]);

  return dio;
});
