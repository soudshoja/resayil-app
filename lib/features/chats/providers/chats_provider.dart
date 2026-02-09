import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/chat.dart';
import '../../../core/models/message.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/connectivity_provider.dart';
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

    // Stale-while-revalidate: return cached data immediately
    final db = ref.read(appDatabaseProvider);
    final cachedChats = await db.getAllChats();

    if (cachedChats.isNotEmpty) {
      // Return cached data immediately
      final chats = cachedChats.map(_fromCachedChat).toList();

      // Fetch fresh data in background and update
      _fetchPage(1).then((freshChats) {
        state = AsyncValue.data(freshChats);
        _updateCache(freshChats);
      }).catchError((error, stack) {
        // Keep cached data on error, just log
      });

      return chats;
    }

    // No cache: fetch normally
    return _fetchPage(1);
  }

  Future<List<Chat>> _fetchPage(int page) async {
    final repo = ref.read(chatsRepositoryProvider);
    final chats = await repo.getChats(page: page);
    _hasMore = chats.length >= 50;
    _currentPage = page;

    // Update cache with fresh data
    if (page == 1) {
      await _updateCache(chats);
    }

    return chats;
  }

  /// Convert CachedChat to Chat model
  Chat _fromCachedChat(CachedChat cached) {
    return Chat(
      id: cached.id,
      name: cached.name,
      phone: cached.phone,
      avatar: cached.avatar,
      lastMessage: cached.lastMessage,
      lastMessageTime: cached.lastMessageTime,
      unreadCount: cached.unreadCount,
      archived: cached.archived,
      resolved: cached.resolved,
      pinned: cached.pinned,
      labels: cached.labels.isEmpty ? [] : (jsonDecode(cached.labels) as List).cast<String>(),
      isGroup: cached.isGroup,
      status: cached.status,
    );
  }

  /// Update Drift cache with fresh chats
  Future<void> _updateCache(List<Chat> chats) async {
    final db = ref.read(appDatabaseProvider);
    final companions = chats.map((chat) {
      return CachedChatsCompanion(
        id: drift.Value(chat.id),
        name: drift.Value(chat.name),
        phone: drift.Value(chat.phone),
        avatar: drift.Value(chat.avatar),
        lastMessage: drift.Value(chat.lastMessage),
        lastMessageTime: drift.Value(chat.lastMessageTime),
        unreadCount: drift.Value(chat.unreadCount),
        archived: drift.Value(chat.archived),
        resolved: drift.Value(chat.resolved),
        pinned: drift.Value(chat.pinned),
        labels: drift.Value(jsonEncode(chat.labels)),
        isGroup: drift.Value(chat.isGroup),
        status: drift.Value(chat.status),
        syncedAt: drift.Value(DateTime.now()),
      );
    }).toList();

    await db.upsertChats(companions);
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

    // Stale-while-revalidate: return cached messages immediately
    final db = ref.read(appDatabaseProvider);
    final cachedMessages = await db.getMessages(arg);

    if (cachedMessages.isNotEmpty) {
      // Return cached data immediately
      final messages = cachedMessages.map(_fromCachedMessage).toList();

      // Fetch fresh data in background and update
      _fetchPage(arg, 1).then((freshMessages) {
        state = AsyncValue.data(freshMessages);
        _updateCache(freshMessages);
      }).catchError((error, stack) {
        // Keep cached data on error, just log
      });

      return messages;
    }

    // No cache: fetch normally
    return _fetchPage(arg, 1);
  }

  Future<List<Message>> _fetchPage(String chatId, int page) async {
    final repo = ref.read(chatsRepositoryProvider);
    final messages = await repo.getMessages(chatId, page: page);
    _hasMore = messages.length >= 50;
    _currentPage = page;

    // Update cache with fresh data
    if (page == 1) {
      await _updateCache(messages);
    }

    return messages;
  }

  /// Convert CachedMessage to Message model
  Message _fromCachedMessage(CachedMessage cached) {
    return Message(
      id: cached.id,
      chatId: cached.chatId,
      type: cached.type,
      text: cached.textContent,
      mediaUrl: cached.mediaUrl,
      mediaCaption: cached.mediaCaption,
      fileName: cached.fileName,
      mimeType: cached.mimeType,
      outgoing: cached.outgoing,
      status: cached.status,
      senderName: cached.senderName,
      createdAt: cached.createdAt,
      readAt: cached.readAt,
    );
  }

  /// Update Drift cache with fresh messages
  Future<void> _updateCache(List<Message> messages) async {
    final db = ref.read(appDatabaseProvider);
    final companions = messages.map((msg) {
      return CachedMessagesCompanion(
        id: drift.Value(msg.id),
        chatId: drift.Value(msg.chatId),
        type: drift.Value(msg.type),
        textContent: drift.Value(msg.text),
        mediaUrl: drift.Value(msg.mediaUrl),
        mediaCaption: drift.Value(msg.mediaCaption),
        fileName: drift.Value(msg.fileName),
        mimeType: drift.Value(msg.mimeType),
        outgoing: drift.Value(msg.outgoing),
        status: drift.Value(msg.status),
        senderName: drift.Value(msg.senderName),
        createdAt: drift.Value(msg.createdAt),
        readAt: drift.Value(msg.readAt),
        syncedAt: drift.Value(DateTime.now()),
      );
    }).toList();

    await db.upsertMessages(companions);
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

// ─── Connectivity-based Retry ────────────────────────────────

/// Provider that watches connectivity and retries pending messages
final pendingMessagesRetryProvider = Provider<void>((ref) {
  // Watch for connectivity changes
  ref.listen(isOnlineProvider, (previous, current) {
    // When connection is restored (offline -> online)
    if (previous == false && current == true) {
      _retryPendingMessages(ref);
    }
  });
});

/// Retry all pending messages when connectivity is restored
Future<void> _retryPendingMessages(Ref ref) async {
  final db = ref.read(appDatabaseProvider);
  final repo = ref.read(chatsRepositoryProvider);

  // Get all messages with 'sending' status
  final pendingMessages = await db.getPendingMessages();

  for (final cached in pendingMessages) {
    try {
      // Retry sending the message
      final message = Message(
        id: cached.id,
        chatId: cached.chatId,
        type: cached.type,
        text: cached.textContent,
        mediaUrl: cached.mediaUrl,
        mediaCaption: cached.mediaCaption,
        fileName: cached.fileName,
        mimeType: cached.mimeType,
        outgoing: cached.outgoing,
        status: cached.status,
        senderName: cached.senderName,
        createdAt: cached.createdAt,
        readAt: cached.readAt,
      );

      // Send the message (assuming text message for now)
      if (message.type == 'text' && message.text != null) {
        final sent = await repo.sendTextMessage(message.chatId, message.text!);

        if (sent != null) {
          // Update status to 'sent' in cache
          await db.updateMessageStatus(message.id, 'sent');

          // Update in provider if the chat is being watched
          final chatNotifier = ref.read(
            chatMessagesProvider(message.chatId).notifier,
          );
          chatNotifier.updateMessageStatus(message.id, 'sent');
        }
      }
    } catch (e) {
      // Log error but continue with other messages
      // Could also mark as 'failed' if needed
    }
  }
}
