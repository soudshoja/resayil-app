import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/group.dart';
import '../../../core/models/message.dart';
import '../../../core/models/contact.dart';
import '../repository/groups_repository.dart';

// ─── Groups List ────────────────────────────────────────────

final groupsProvider =
    AsyncNotifierProvider<GroupsNotifier, List<Group>>(GroupsNotifier.new);

class GroupsNotifier extends AsyncNotifier<List<Group>> {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Group>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchGroups(page: 1);
  }

  Future<List<Group>> _fetchGroups({int page = 1, int perPage = 50}) async {
    final repo = ref.read(groupsRepositoryProvider);
    final groups = await repo.getGroups(page: page, perPage: perPage);
    if (groups.length < perPage) _hasMore = false;
    return groups;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      _page++;
      final moreGroups = await _fetchGroups(page: _page);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, ...moreGroups]);
    } catch (e, st) {
      _page--;
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchGroups(page: 1));
  }

  void addGroup(Group group) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([group, ...current]);
  }

  void removeGroup(String groupId) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
        current.where((g) => g.id != groupId).toList());
  }

  void updateGroup(Group updated) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((g) => g.id == updated.id ? updated : g).toList(),
    );
  }
}

// ─── Group Messages ─────────────────────────────────────────

final groupMessagesProvider = AsyncNotifierProvider.family<
    GroupMessagesNotifier, List<Message>, String>(GroupMessagesNotifier.new);

class GroupMessagesNotifier extends FamilyAsyncNotifier<List<Message>, String> {
  int _page = 1;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<Message>> build(String arg) async {
    _page = 1;
    _hasMore = true;
    return _fetchMessages(page: 1);
  }

  Future<List<Message>> _fetchMessages({int page = 1}) async {
    final repo = ref.read(groupsRepositoryProvider);
    final messages = await repo.getMessages(arg, page: page);
    if (messages.length < 50) _hasMore = false;
    return messages;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    try {
      final older = await _fetchMessages(page: _page);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, ...older]);
    } catch (e, st) {
      _page--;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMessages(page: 1));
  }

  void addMessage(Message message) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([...current, message]);
  }

  void updateMessageStatus(String messageId, String newStatus) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((m) {
        if (m.id == messageId) {
          return Message(
            id: m.id,
            chatId: m.chatId,
            type: m.type,
            text: m.text,
            mediaUrl: m.mediaUrl,
            mediaCaption: m.mediaCaption,
            fileName: m.fileName,
            mimeType: m.mimeType,
            outgoing: m.outgoing,
            status: newStatus,
            senderName: m.senderName,
            createdAt: m.createdAt,
            readAt: m.readAt,
          );
        }
        return m;
      }).toList(),
    );
  }
}

// ─── Group Detail ───────────────────────────────────────────

final groupDetailProvider =
    FutureProvider.family<Group?, String>((ref, groupId) async {
  final repo = ref.read(groupsRepositoryProvider);
  return repo.getGroup(groupId);
});

// ─── Group Participants ─────────────────────────────────────

final groupParticipantsProvider =
    FutureProvider.family<List<Participant>, String>((ref, groupId) async {
  final repo = ref.read(groupsRepositoryProvider);
  return repo.getParticipants(groupId);
});

// ─── Contacts (for participant selection) ───────────────────

final contactsSearchProvider =
    FutureProvider.family<List<Contact>, String>((ref, search) async {
  final repo = ref.read(groupsRepositoryProvider);
  return repo.getContacts(search: search.isEmpty ? null : search);
});

// ─── Group Search ───────────────────────────────────────────

final groupSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredGroupsProvider = Provider<AsyncValue<List<Group>>>((ref) {
  final query = ref.watch(groupSearchQueryProvider).toLowerCase();
  final groupsAsync = ref.watch(groupsProvider);

  return groupsAsync.whenData((groups) {
    if (query.isEmpty) return groups;
    return groups
        .where((g) => g.name.toLowerCase().contains(query))
        .toList();
  });
});
