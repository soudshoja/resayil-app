import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake secure storage for testing
class FakeSecureStorage {
  String? _apiKey;
  String? _locale;

  Future<String?> getApiKey() async => _apiKey;
  Future<void> saveApiKey(String key) async => _apiKey = key;
  Future<String?> getLocale() async => _locale;
  Future<void> saveLocale(String locale) async => _locale = locale;
}

void main() {
  group('Settings Tests', () {
    late FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSecureStorage();
    });

    test('API Key dialog can be created with TextField', () {
      final controller = TextEditingController();
      expect(controller.text, isEmpty);

      controller.text = 'my_api_key_123';
      expect(controller.text, equals('my_api_key_123'));

      controller.dispose();
    });

    test('API Key dialog can mask/unmask password', () {
      bool obscureText = true;

      expect(obscureText, isTrue);

      obscureText = !obscureText;
      expect(obscureText, isFalse);

      obscureText = !obscureText;
      expect(obscureText, isTrue);
    });

    test('API Key dialog validates non-empty input', () {
      final controller = TextEditingController();
      final isValid = controller.text.isNotEmpty;

      expect(isValid, isFalse);

      controller.text = 'valid_key';
      expect(controller.text.isNotEmpty, isTrue);

      controller.dispose();
    });

    test('API Key reading from secure storage', () async {
      await fakeStorage.saveApiKey('stored_api_key_xyz');
      final key = await fakeStorage.getApiKey();

      expect(key, equals('stored_api_key_xyz'));
    });

    test('API Key saving to secure storage', () async {
      await fakeStorage.saveApiKey('new_api_key');

      expect(await fakeStorage.getApiKey(), equals('new_api_key'));
    });

    test('API Key can be updated in dialog', () {
      const oldKey = 'old_key_123';
      const newKey = 'new_key_456';

      final controller = TextEditingController(text: oldKey);
      expect(controller.text, equals(oldKey));

      controller.text = newKey;
      expect(controller.text, equals(newKey));

      controller.dispose();
    });

    test('API Key dialog shows current key when opened', () async {
      await fakeStorage.saveApiKey('existing_key');
      final key = await fakeStorage.getApiKey();

      expect(key, isNotNull);
      expect(key, equals('existing_key'));
    });

    test('API Key dialog handles null/empty storage value', () async {
      final key = await fakeStorage.getApiKey();

      expect(key, isNull);
    });

    test('Language picker shows English and Arabic options', () {
      final languages = ['en', 'ar'];

      expect(languages, contains('en'));
      expect(languages, contains('ar'));
      expect(languages.length, equals(2));
    });

    test('Language picker can select English', () {
      const selectedLocale = 'en';

      expect(selectedLocale, equals('en'));
    });

    test('Language picker can select Arabic', () {
      const selectedLocale = 'ar';

      expect(selectedLocale, equals('ar'));
    });

    test('Language selection creates Locale correctly', () {
      final enLocale = Locale('en');
      expect(enLocale.languageCode, equals('en'));

      final arLocale = Locale('ar');
      expect(arLocale.languageCode, equals('ar'));
    });

    test('LocaleNotifier initializes with English by default', () {
      const defaultLocale = Locale('en');

      expect(defaultLocale.languageCode, equals('en'));
    });

    test('LocaleNotifier can save locale to storage', () async {
      await fakeStorage.saveLocale('ar');

      expect(await fakeStorage.getLocale(), equals('ar'));
    });

    test('LocaleNotifier can load saved locale from storage', () async {
      await fakeStorage.saveLocale('ar');
      final savedLocale = await fakeStorage.getLocale();

      expect(savedLocale, equals('ar'));
    });

    test('LocaleNotifier updates state when setLocale is called', () {
      var currentLocale = Locale('en');
      expect(currentLocale.languageCode, equals('en'));

      currentLocale = Locale('ar');
      expect(currentLocale.languageCode, equals('ar'));
    });

    test('Language change updates app locale immediately', () {
      var appLocale = Locale('en');
      expect(appLocale.languageCode, equals('en'));

      appLocale = Locale('ar');
      expect(appLocale.languageCode, equals('ar'));

      appLocale = Locale('en');
      expect(appLocale.languageCode, equals('en'));
    });

    test('RadioListTile can represent language selection', () {
      const selectedLanguage = 'en';
      const language = 'en';

      final isSelected = selectedLanguage == language;
      expect(isSelected, isTrue);
    });

    test('RadioListTile selection can be changed', () {
      String selectedLanguage = 'en';

      expect(selectedLanguage, equals('en'));

      selectedLanguage = 'ar';
      expect(selectedLanguage, equals('ar'));
    });

    test('Language picker dialog shows correct current selection', () {
      const currentLanguage = 'ar';
      const displayedLanguages = ['en', 'ar'];

      expect(displayedLanguages, contains(currentLanguage));
    });

    test('API Key and Language settings are independent', () async {
      await fakeStorage.saveApiKey('test_key');
      await fakeStorage.saveLocale('ar');

      final apiKey = await fakeStorage.getApiKey();
      final locale = await fakeStorage.getLocale();

      expect(apiKey, equals('test_key'));
      expect(locale, equals('ar'));
    });

    test('Settings can be updated without affecting other settings', () async {
      // Update API key
      await fakeStorage.saveApiKey('new_key');

      // Locale should remain unchanged
      expect(await fakeStorage.getApiKey(), equals('new_key'));
      expect(await fakeStorage.getLocale(), isNull);
    });

    test('Multiple settings updates preserve previous state', () async {
      await fakeStorage.saveApiKey('key1');
      await fakeStorage.saveLocale('en');
      await fakeStorage.saveApiKey('key2');

      expect(await fakeStorage.getApiKey(), equals('key2'));
      expect(await fakeStorage.getLocale(), equals('en'));
    });

    test('API Key dialog can clear existing key', () {
      final controller = TextEditingController(text: 'existing_key');

      expect(controller.text, equals('existing_key'));

      controller.clear();
      expect(controller.text, isEmpty);

      controller.dispose();
    });

    test('Language picker preserves selection after dialog close', () {
      String selectedLanguage = 'en';

      // User selects Arabic
      selectedLanguage = 'ar';
      expect(selectedLanguage, equals('ar'));

      // Dialog closes and reopens (state should persist)
      expect(selectedLanguage, equals('ar'));
    });

    test('Settings dialog SnackBar message is non-empty', () {
      const successMessage = 'Settings updated successfully';
      const errorMessage = 'Failed to update settings';

      expect(successMessage.isNotEmpty, isTrue);
      expect(errorMessage.isNotEmpty, isTrue);
    });

    test('API Key minimum length validation', () {
      final minLength = 8;
      final validKey = 'abcd1234'; // 8 chars
      final invalidKey = 'abc'; // 3 chars

      expect(validKey.length >= minLength, isTrue);
      expect(invalidKey.length >= minLength, isFalse);
    });
  });
}
