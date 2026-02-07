import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/status_update.dart';
import '../repository/status_repository.dart';

// ─── Status List ────────────────────────────────────────────

final statusProvider =
    AsyncNotifierProvider<StatusNotifier, List<ContactStatus>>(
        StatusNotifier.new);

class StatusNotifier extends AsyncNotifier<List<ContactStatus>> {
  @override
  Future<List<ContactStatus>> build() => _fetch();

  Future<List<ContactStatus>> _fetch() async {
    final repo = ref.read(statusRepositoryProvider);
    return repo.getStatuses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ─── My Statuses (own updates) ──────────────────────────────

final myStatusesProvider =
    Provider<AsyncValue<ContactStatus?>>((ref) {
  final all = ref.watch(statusProvider);
  return all.whenData((statuses) {
    // The API may include "own" status as a special entry
    // or we filter by checking for a flag. For now return first with no contactId match
    return null; // Own statuses handled via the create flow
  });
});

// ─── Recent (unviewed) Statuses ─────────────────────────────

final recentStatusesProvider =
    Provider<AsyncValue<List<ContactStatus>>>((ref) {
  final all = ref.watch(statusProvider);
  return all.whenData(
      (statuses) => statuses.where((s) => s.hasUnviewed).toList());
});

// ─── Viewed Statuses ────────────────────────────────────────

final viewedStatusesProvider =
    Provider<AsyncValue<List<ContactStatus>>>((ref) {
  final all = ref.watch(statusProvider);
  return all.whenData(
      (statuses) => statuses.where((s) => !s.hasUnviewed).toList());
});
