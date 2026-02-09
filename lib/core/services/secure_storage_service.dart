import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  static const _apiKeyKey = 'resayil_api_key';
  static const _localeKey = 'resayil_locale';
  static const _storageTimeoutDuration = Duration(seconds: 10);

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveApiKey(String apiKey) async {
    try {
      await _storage.write(key: _apiKeyKey, value: apiKey).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to save API key');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error saving API key: $e');
      rethrow;
    }
  }

  Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: _apiKeyKey).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to retrieve API key');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error retrieving API key: $e');
      return null;
    }
  }

  Future<void> deleteApiKey() async {
    try {
      await _storage.delete(key: _apiKeyKey).timeout(
        _storageTimeoutDuration,
        onTimeout: () {
          throw TimeoutException('Failed to delete API key');
        },
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting API key: $e');
      rethrow;
    }
  }

  Future<bool> hasApiKey() async {
    try {
      final key = await getApiKey();
      return key != null && key.isNotEmpty;
    } catch (e) {
      // ignore: avoid_print
      print('Error checking API key: $e');
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
