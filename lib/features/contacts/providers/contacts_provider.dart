import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/contact.dart';
import '../repository/contacts_repository.dart';

// ─── Contact List ────────────────────────────────────────────

final contactsProvider =
    AsyncNotifierProvider<ContactsNotifier, List<Contact>>(
        ContactsNotifier.new);

class ContactsNotifier extends AsyncNotifier<List<Contact>> {
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  Future<List<Contact>> build() => _fetchPage(1);

  Future<List<Contact>> _fetchPage(int page) async {
    final repo = ref.read(contactsRepositoryProvider);
    final contacts = await repo.getContacts(page: page);
    _hasMore = contacts.length >= 50;
    _currentPage = page;
    return contacts;
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
    final repo = ref.read(contactsRepositoryProvider);
    final next = await repo.getContacts(page: _currentPage + 1);
    _hasMore = next.length >= 50;
    _currentPage++;
    state = AsyncValue.data([...current, ...next]);
  }

  bool get hasMore => _hasMore;
}
