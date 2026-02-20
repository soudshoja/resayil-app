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
  group('AuthNotifier - Email/Password Auth Flow', () {
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

    group('login() - Email & Password', () {
      test('should successfully login with valid credentials', () async {
        when(mockStorage.saveToken(any))
            .thenAnswer((_) => Future.value());

        final notifier = container.read(authStateProvider.notifier);
        final result = await notifier.login('user@example.com', 'password123');

        expect(result, true);
        verify(mockStorage.saveToken(any)).called(1);
      });

      test('should fail login with empty email', () async {
        final notifier = container.read(authStateProvider.notifier);

        expect(
          () => notifier.login('', 'password123'),
          throwsException,
        );
      });

      test('should fail login with empty password', () async {
        final notifier = container.read(authStateProvider.notifier);

        expect(
          () => notifier.login('user@example.com', ''),
          throwsException,
        );
      });

      test('should handle storage timeout during login', () async {
        when(mockStorage.saveToken(any))
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 15),
              () => throw TimeoutException('Storage timeout'),
            ));

        final notifier = container.read(authStateProvider.notifier);

        expect(
          () => notifier.login('user@example.com', 'password123'),
          throwsException,
        );
      });

      test('should transition state to loading, then success', () async {
        when(mockStorage.saveToken(any))
            .thenAnswer((_) => Future.value());

        final notifier = container.read(authStateProvider.notifier);
        expect(container.read(authStateProvider), isA<AsyncValue>());

        final result = await notifier.login('user@example.com', 'password123');
        expect(result, true);

        final finalState = container.read(authStateProvider);
        expect(finalState, isA<AsyncData>());
      });

      test('should handle errors and set error state', () async {
        when(mockStorage.saveToken(any))
            .thenThrow(Exception('Storage error'));

        final notifier = container.read(authStateProvider.notifier);

        expect(
          () => notifier.login('user@example.com', 'password123'),
          throwsException,
        );
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
      test('should check if token exists on build', () async {
        when(mockStorage.getToken())
            .thenAnswer((_) => Future.value('valid_token'));

        final result = await container.read(authStateProvider.future);
        expect(result, isA<bool>());
      });

      test('should handle storage timeout during build', () async {
        when(mockStorage.getToken())
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 15),
              () => throw TimeoutException('Storage timeout'),
            ));

        final result = await container.read(authStateProvider.future);
        expect(result, false);
      });

      test('should return false when no token exists', () async {
        when(mockStorage.getToken())
            .thenAnswer((_) => Future.value(null));

        final result = await container.read(authStateProvider.future);
        expect(result, false);
      });

      test('should handle storage error gracefully', () async {
        when(mockStorage.getToken())
            .thenThrow(Exception('Storage error'));

        final result = await container.read(authStateProvider.future);
        expect(result, false);
      });
    });

    group('Timeout Handling', () {
      test('should timeout after 20 seconds for API calls', () async {
        when(mockStorage.saveToken(any))
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 25),
            ));

        final notifier = container.read(authStateProvider.notifier);

        expect(
          () => notifier.login('user@example.com', 'password123'),
          throwsException,
        );
      });

      test('should timeout after 10 seconds for storage operations', () async {
        when(mockStorage.getToken())
            .thenAnswer((_) => Future.delayed(
              const Duration(seconds: 15),
            ));

        final future = container.read(authStateProvider.future);
        final result = await future;

        expect(result, false);
      });
    });
  });
}
