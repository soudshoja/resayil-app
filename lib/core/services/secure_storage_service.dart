import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  static const _tokenKey = 'resayil_auth_token';
  static const _localeKey = 'resayil_locale';
  static const _storageTimeoutDuration = Duration(seconds: 10);

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to save token');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to retrieve token');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to delete token');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting token: $e');
      rethrow;
    }
  }

  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      // ignore: avoid_print
      print('Error checking token: $e');
      return false;
    }
  }

  Future<void> saveLocale(String locale) async {
    try {
      await _storage.write(key: _localeKey, value: locale).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to save locale');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error saving locale: $e');
      rethrow;
    }
  }

  Future<String?> getLocale() async {
    try {
      return await _storage.read(key: _localeKey).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to retrieve locale');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving locale: $e');
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll().timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to clear storage');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error clearing storage: $e');
      rethrow;
    }
  }
}
