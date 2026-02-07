import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/models/contact.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../providers/groups_provider.dart';
import '../repository/groups_repository.dart';

class AddParticipantsScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const AddParticipantsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  ConsumerState<AddParticipantsScreen> createState() =>
      _AddParticipantsScreenState();
}

class _AddParticipantsScreenState
    extends ConsumerState<AddParticipantsScreen> {
  final _searchController = TextEditingController();
  final List<Contact> _selectedContacts = [];
  bool _isAdding = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsSearchProvider(_searchQuery));
    final existingParticipants =
        ref.watch(groupParticipantsProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add to ${widget.groupName}'),
        actions: [
          if (_selectedContacts.isNotEmpty)
            TextButton(
              onPressed: _isAdding ? null : _addParticipants,
              child: _isAdding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    )
                  : Text(
                      'Add (${_selectedContacts.length})',
                      style:
                          const TextStyle(color: AppColors.accent),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Selected chips
          if (_selectedContacts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedContacts.map((contact) {
                  return Chip(
                    avatar:
                        ChatAvatar(name: contact.name, size: 24),
                    label: Text(contact.name,
                        style: const TextStyle(fontSize: 13)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedContacts.remove(contact);
                      });
                    },
                    backgroundColor: AppColors.surface,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => setState(() => _searchQuery = q),
              style:
                  const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),

          // Contacts list
          Expanded(
            child: contactsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.accent),
              ),
              error: (error, _) => Center(
                child: Text(error.toString(),
                    style: const TextStyle(
                        color: AppColors.textSecondary)),
              ),
              data: (contacts) {
                // Filter out existing participants
                final existingIds = existingParticipants
                        .valueOrNull
                        ?.map((p) => p.id)
                        .toSet() ??
                    {};
                final available = contacts
                    .where((c) => !existingIds.contains(c.id))
                    .toList();

                if (available.isEmpty) {
                  return const Center(
                    child: Text('No contacts available to add',
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  );
                }

                return ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final contact = available[index];
                    final isSelected = _selectedContacts
                        .any((c) => c.id == contact.id);
                    return ListTile(
                      leading: ChatAvatar(
                        name: contact.name,
                        imageUrl: contact.avatar,
                        size: 40,
                      ),
                      title: Text(contact.name),
                      subtitle: contact.phone != null
                          ? Text(contact.phone!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13))
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.accent)
                          : const Icon(Icons.circle_outlined,
                              color: AppColors.textSecondary),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedContacts.removeWhere(
                                (c) => c.id == contact.id);
                          } else {
                            _selectedContacts.add(contact);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addParticipants() async {
    if (_isAdding) return;
    setState(() => _isAdding = true);

    try {
      final repo = ref.read(groupsRepositoryProvider);
      await repo.addParticipants(
        widget.groupId,
        _selectedContacts.map((c) => c.id).toList(),
      );

      // Refresh participants
      ref.invalidate(groupParticipantsProvider(widget.groupId));
      ref.invalidate(groupDetailProvider(widget.groupId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_selectedContacts.length} participant(s) added'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}
