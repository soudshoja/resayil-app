import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/secure_storage_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref ref;

  LocaleNotifier(this.ref) : super(const Locale('en')) {
    _initLocale();
  }

  Future<void> _initLocale() async {
    final storage = ref.read(secureStorageProvider);
    final savedLocale = await storage.getLocale();
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(String localeCode) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveLocale(localeCode);
    state = Locale(localeCode);
  }
}
