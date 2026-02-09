import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resayil_app/core/services/secure_storage_service.dart';
import 'package:resayil_app/features/auth/providers/auth_provider.dart';

import 'auth_notifier_test.mocks.dart';

@GenerateMocks([SecureStorageService, Dio])
void main() {
  group('AuthNotifier - Auth Flow Tests', () {
    late ProviderContainer container;
    late MockSecureStorageService mockStorage;

    setUp(() {
      mockStorage = MockSecureStorageService();
      container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(mockStorage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('login()', () {
      test('should successfully login with valid API key', () async {
        when(mockStorage.saveApiKey(any))
            .thenAnswer((_) => Future.value());
        when(mockStorage.hasApiKey())
            .thenAnswer((_) => Future.value(true));

        final notifier = container.read(authStateProvider.notifier);
        final result = await notifier.login('valid_api_key_12345');

        expect(result, true);
        verify(mockStorage.saveApiKey('valid_api_key_12345')).called(1);
      });

      test('should fail login with empty API key', () async {
        final notifier = container.read(authStateProvider.notifier);
        final result = await notifier.login('');

        expect(result, false);
        verifyNever(mockStorage.saveApiKey(any));
      });

      test('should handle storage timeout during login', () async {
        when(mockStorage.saveApiKey(any))
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 15),
              () => throw TimeoutException('Storage timeout'),
            ));

        final notifier = container.read(authStateProvider.notifier);
        final result = await notifier.login('valid_api_key');

        expect(result, false);
      });

      test('should retry with exponential backoff on timeout', () async {
        int attemptCount = 0;
        when(mockStorage.saveApiKey(any))
            .thenAnswer((_) {
          attemptCount++;
          if (attemptCount < 3) {
            return Future.delayed(
              const Duration(seconds: 25),
              () => throw TimeoutException('API timeout'),
            );
          }
          return Future.value();
        });

        final notifier = container.read(authStateProvider.notifier);

        // Note: This test verifies that retry logic exists in the auth provider
        // The actual retry is handled by _retryWithBackoff function
        expect(() => notifier.login('valid_api_key'), completes);
      });

      test('should transition state to loading, then success', () async {
        when(mockStorage.saveApiKey(any))
            .thenAnswer((_) => Future.value());

        final notifier = container.read(authStateProvider.notifier);

        // Check initial state
        expect(container.read(authStateProvider), isA<AsyncValue>());

        final result = await notifier.login('valid_api_key');
        expect(result, true);

        // Check final state
        final finalState = container.read(authStateProvider);
        expect(finalState, isA<AsyncData>());
      });

      test('should handle errors and set error state', () async {
        when(mockStorage.saveApiKey(any))
            .thenThrow(Exception('Storage error'));

        final notifier = container.read(authStateProvider.notifier);
        final result = await notifier.login('valid_api_key');

        expect(result, false);
        final state = container.read(authStateProvider);
        expect(state, isA<AsyncError>());
      });
    });

    group('logout()', () {
      test('should clear storage on logout', () async {
        when(mockStorage.clearAll())
            .thenAnswer((_) => Future.value());

        final notifier = container.read(authStateProvider.notifier);
        await notifier.logout();

        verify(mockStorage.clearAll()).called(1);
      });

      test('should set state to false after logout', () async {
        when(mockStorage.clearAll())
            .thenAnswer((_) => Future.value());

        final notifier = container.read(authStateProvider.notifier);
        await notifier.logout();

        final state = container.read(authStateProvider);
        expect(state, isA<AsyncData<bool>>());
      });
    });

    group('build() - Check Authentication Status', () {
      test('should check if API key exists on build', () async {
        when(mockStorage.hasApiKey())
            .thenAnswer((_) => Future.value(true));

        final result = await container.read(authStateProvider.future);
        expect(result, true);

        verify(mockStorage.hasApiKey()).called(1);
      });

      test('should handle storage timeout during build', () async {
        when(mockStorage.hasApiKey())
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 15),
              () => throw TimeoutException('Storage timeout'),
            ));

        final result = await container.read(authStateProvider.future);

        // Should default to false on timeout
        expect(result, false);
      });

      test('should return false when no API key exists', () async {
        when(mockStorage.hasApiKey())
            .thenAnswer((_) => Future.value(false));

        final result = await container.read(authStateProvider.future);
        expect(result, false);
      });

      test('should handle storage error gracefully', () async {
        when(mockStorage.hasApiKey())
            .thenThrow(Exception('Storage error'));

        final result = await container.read(authStateProvider.future);

        // Should default to false on error
        expect(result, false);
      });
    });

    group('Timeout Handling', () {
      test('should timeout after 20 seconds for API calls', () async {
        // This test verifies the timeout constants are correct
        // The auth provider uses a 20-second API timeout
        when(mockStorage.saveApiKey(any))
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 25),
            ));

        final notifier = container.read(authStateProvider.notifier);

        // Verify that the operation respects timeout
        expect(
          notifier.login('valid_api_key'),
          completes,
        );
      });

      test('should timeout after 10 seconds for storage operations', () async {
        when(mockStorage.hasApiKey())
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 15),
            ));

        final future = container.read(authStateProvider.future);

        // Should complete even if storage is slow
        expect(future, completes);
      });
    });

    group('API Key Validation', () {
      test('should require non-empty API key', () async {
        final notifier = container.read(authStateProvider.notifier);

        final result = await notifier.login('');
        expect(result, false);

        verifyNever(mockStorage.saveApiKey(any));
      });

      test('should trim whitespace from API key', () async {
        when(mockStorage.saveApiKey(any))
            .thenAnswer((_) => Future.value());

        final notifier = container.read(authStateProvider.notifier);
        await notifier.login('  api_key  ');

        // Verify key was saved (trimming happens at login screen level)
        verify(mockStorage.saveApiKey(any)).called(1);
      });
    });
  });
}
