import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/push_notification_service.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

final pushNotificationInitializedProvider = StateProvider<bool>((ref) => false);

class PushNotificationState {
  final bool isInitialized;
  final String? token;
  final String? lastMessage;
  final bool isLoading;
  final String? error;

  const PushNotificationState({
    required this.isInitialized,
    this.token,
    this.lastMessage,
    this.isLoading = false,
    this.error,
  });

  PushNotificationState copyWith({
    bool? isInitialized,
    String? token,
    String? lastMessage,
    bool? isLoading,
    String? error,
  }) {
    return PushNotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      token: token ?? this.token,
      lastMessage: lastMessage ?? this.lastMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PushNotificationNotifier extends StateNotifier<PushNotificationState> {
  final PushNotificationService _service;

  PushNotificationNotifier(this._service) : super(const PushNotificationState(isInitialized: false)) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _service.initialize();
      state = state.copyWith(
        isInitialized: true,
        token: _service.token,
        lastMessage: _service.lastMessage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshToken() async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.initialize();
      state = state.copyWith(
        token: _service.token,
        lastMessage: _service.lastMessage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true);

    try {
      // Request permission is handled in initialize(), but we can retry
      await _service.initialize();
      state = state.copyWith(
        token: _service.token,
        lastMessage: _service.lastMessage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final pushNotificationProvider =
    StateNotifierProvider<PushNotificationNotifier, PushNotificationState>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  return PushNotificationNotifier(service);
});