import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/models/contact.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../providers/groups_provider.dart';
import '../repository/groups_repository.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final List<Contact> _selectedContacts = [];
  bool _isCreating = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsSearchProvider(_searchQuery));
    final canCreate =
        _nameController.text.trim().isNotEmpty && _selectedContacts.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          TextButton(
            onPressed: canCreate && !_isCreating ? _createGroup : null,
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accent),
                  )
                : Text(
                    'Create',
                    style: TextStyle(
                      color: canCreate
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group info section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.background,
                      child: const Icon(Icons.group,
                          size: 32, color: AppColors.textSecondary),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.accent,
                        child: const Icon(Icons.camera_alt,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                            color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Group name',
                          hintStyle: TextStyle(
                              color: AppColors.textSecondary),
                          border: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.accent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.accent),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Description (optional)',
                          hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Selected contacts chips
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
                    avatar: ChatAvatar(
                        name: contact.name, size: 24),
                    label: Text(
                      contact.name,
                      style: const TextStyle(fontSize: 13),
                    ),
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

          // Search contacts
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(error.toString(),
                        style: const TextStyle(
                            color: AppColors.textSecondary)),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(
                          contactsSearchProvider(_searchQuery)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (contacts) {
                if (contacts.isEmpty) {
                  return const Center(
                    child: Text('No contacts found',
                        style: TextStyle(
                            color: AppColors.textSecondary)),
                  );
                }

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
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
                          ? Text(
                              contact.phone!,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            )
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

  Future<void> _createGroup() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final repo = ref.read(groupsRepositoryProvider);
      final group = await repo.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        participantIds: _selectedContacts.map((c) => c.id).toList(),
      );

      if (group != null) {
        ref.read(groupsProvider.notifier).addGroup(group);
      }

      if (mounted) {
        if (group != null) {
          context.go(
              '/groups/${group.id}?name=${Uri.encodeComponent(group.name)}');
        } else {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}
