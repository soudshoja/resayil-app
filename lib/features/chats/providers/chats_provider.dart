import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/chat.dart';
import '../../../core/models/message.dart';
import '../repository/chats_repository.dart';

// ─── Chat List ───────────────────────────────────────────────

final chatsProvider =
    AsyncNotifierProvider<ChatsNotifier, List<Chat>>(ChatsNotifier.new);

class ChatsNotifier extends AsyncNotifier<List<Chat>> {
  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _pollingTimer;

  @override
  Future<List<Chat>> build() async {
    // Start polling timer for chat list updates (every 30 seconds)
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refresh(),
    );

    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return _fetchPage(1);
  }

  Future<List<Chat>> _fetchPage(int page) async {
    final repo = ref.read(chatsRepositoryProvider);
    final chats = await repo.getChats(page: page);
    _hasMore = chats.length >= 50;
    _currentPage = page;
    return chats;
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull ?? [];
    final repo = ref.read(chatsRepositoryProvider);
    final next = await repo.getChats(page: _currentPage + 1);
    _hasMore = next.length >= 50;
    _currentPage++;
    state = AsyncValue.data([...current, ...next]);
  }

  bool get hasMore => _hasMore;

  /// Optimistically update a chat in the list
  void updateChat(Chat updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.map((c) => c.id == updated.id ? updated : c).toList(),
    );
  }

  /// Remove a chat from the visible list (archive)
  void removeChat(String chatId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current.where((c) => c.id != chatId).toList(),
    );
  }
}

// ─── Chat Messages ───────────────────────────────────────────

final chatMessagesProvider =
    AsyncNotifierProvider.family<ChatMessagesNotifier, List<Message>, String>(
        ChatMessagesNotifier.new);

class ChatMessagesNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _pollingTimer;

  @override
  Future<List<Message>> build(String arg) async {
    // Start polling timer for message updates (every 5 seconds)
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => refresh(),
    );

    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    return _fetchPage(arg, 1);
  }

  Future<List<Message>> _fetchPage(String chatId, int page) async {
    final repo = ref.read(chatsRepositoryProvider);
    final messages = await repo.getMessages(chatId, page: page);
    _hasMore = messages.length >= 50;
    _currentPage = page;
    return messages;
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(arg, 1));
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final current = state.valueOrNull ?? [];
    final repo = ref.read(chatsRepositoryProvider);
    final older = await repo.getMessages(arg, page: _currentPage + 1);
    _hasMore = older.length >= 50;
    _currentPage++;
    state = AsyncValue.data([...older, ...current]);
  }

  bool get hasMore => _hasMore;

  /// Add a sent message optimistically
  void addMessage(Message message) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, message]);
  }

  /// Update message status (sending -> sent -> delivered -> read)
  void updateMessageStatus(String messageId, String newStatus) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
      current
          .map((m) => m.id == messageId ? m.copyWith(status: newStatus) : m)
          .toList(),
    );
  }
}

// ─── Send Message Action ─────────────────────────────────────

final sendMessageProvider =
    FutureProvider.family<Message?, ({String chatId, String text})>(
  (ref, params) async {
    final repo = ref.read(chatsRepositoryProvider);
    return repo.sendTextMessage(params.chatId, params.text);
  },
);

// ─── Labels ──────────────────────────────────────────────────

final labelsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(chatsRepositoryProvider);
  return repo.getLabels();
});

// ─── Chat Filter ─────────────────────────────────────────────

enum ChatFilter { all, unread, archived, resolved }

final chatFilterProvider = StateProvider<ChatFilter>((ref) => ChatFilter.all);

final filteredChatsProvider = Provider<AsyncValue<List<Chat>>>((ref) {
  final filter = ref.watch(chatFilterProvider);
  final chatsAsync = ref.watch(chatsProvider);

  return chatsAsync.whenData((chats) {
    switch (filter) {
      case ChatFilter.all:
        return chats.where((c) => !c.archived).toList();
      case ChatFilter.unread:
        return chats.where((c) => c.unreadCount > 0 && !c.archived).toList();
      case ChatFilter.archived:
        return chats.where((c) => c.archived).toList();
      case ChatFilter.resolved:
        return chats.where((c) => c.resolved).toList();
    }
  });
});
