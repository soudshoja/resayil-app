import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/theme/app_colors.dart';
import '../providers/status_provider.dart';
import '../repository/status_repository.dart';

class CreateStatusScreen extends ConsumerStatefulWidget {
  const CreateStatusScreen({super.key});

  @override
  ConsumerState<CreateStatusScreen> createState() =>
      _CreateStatusScreenState();
}

class _CreateStatusScreenState extends ConsumerState<CreateStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _textController = TextEditingController();
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  Color _bgColor = AppColors.accent;
  bool _isPosting = false;
  XFile? _selectedFile;
  DateTime? _scheduledAt;

  final _bgColors = [
    AppColors.accent,
    const Color(0xFF1a73e8),
    const Color(0xFFe91e63),
    const Color(0xFF9c27b0),
    const Color(0xFFff9800),
    const Color(0xFF795548),
    const Color(0xFF607d8b),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }

  Future<void> _postTextStatus() async {
    if (_isPosting || _textController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);

    try {
      final repo = ref.read(statusRepositoryProvider);
      await repo.postTextStatus(
        text: _textController.text.trim(),
        backgroundColor: _colorToHex(_bgColor),
        scheduledAt: _scheduledAt,
      );
      ref.read(statusProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_scheduledAt != null
                ? 'Status scheduled!'
                : 'Status posted!'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _pickAndPostImage({ImageSource source = ImageSource.gallery}) async {
    final file = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _selectedFile = file);

    // Show preview with caption
    if (mounted) {
      final shouldPost = await _showMediaPreview('image');
      if (shouldPost == true) {
        await _postImageStatus(file);
      }
    }
  }

  Future<void> _postImageStatus(XFile file) async {
    setState(() => _isPosting = true);
    try {
      final repo = ref.read(statusRepositoryProvider);
      await repo.postImageStatus(
        filePath: file.path,
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
        scheduledAt: _scheduledAt,
      );
      ref.read(statusProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo status posted!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _pickAndPostVideo({ImageSource source = ImageSource.gallery}) async {
    final file = await _imagePicker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 30),
    );
    if (file == null) return;

    setState(() => _selectedFile = file);

    if (mounted) {
      final shouldPost = await _showMediaPreview('video');
      if (shouldPost == true) {
        await _postVideoStatus(file);
      }
    }
  }

  Future<void> _postVideoStatus(XFile file) async {
    setState(() => _isPosting = true);
    try {
      final repo = ref.read(statusRepositoryProvider);
      await repo.postVideoStatus(
        filePath: file.path,
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
        scheduledAt: _scheduledAt,
      );
      ref.read(statusProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video status posted!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<bool?> _showMediaPreview(String type) {
    _captionController.clear();
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Post $type status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedFile != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    type == 'image' ? Icons.image : Icons.videocam,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showSchedulePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Status'),
        actions: [
          if (_scheduledAt != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'Scheduled: ${_scheduledAt!.hour}:${_scheduledAt!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                side: BorderSide.none,
                deleteIcon:
                    const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    setState(() => _scheduledAt = null),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: _showSchedulePicker,
            tooltip: 'Schedule',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Text'),
            Tab(text: 'Photo'),
            Tab(text: 'Video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextStatus(),
          _buildMediaStatus('Photo'),
          _buildMediaStatus('Video'),
        ],
      ),
    );
  }

  Widget _buildTextStatus() {
    return Container(
      color: _bgColor,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type a status',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          // Color picker
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _bgColors
                  .map((color) => GestureDetector(
                        onTap: () =>
                            setState(() => _bgColor = color),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _bgColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Post button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _textController.text.trim().isEmpty || _isPosting
                        ? null
                        : _postTextStatus,
                icon: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(_scheduledAt != null
                    ? 'Schedule Status'
                    : 'Post Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaStatus(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'Photo' ? Icons.photo_camera : Icons.videocam,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Take or select a $type',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isPosting
                    ? null
                    : () {
                        if (type == 'Photo') {
                          _pickAndPostImage(
                              source: ImageSource.camera);
                        } else {
                          _pickAndPostVideo(
                              source: ImageSource.camera);
                        }
                      },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isPosting
                    ? null
                    : () {
                        if (type == 'Photo') {
                          _pickAndPostImage();
                        } else {
                          _pickAndPostVideo();
                        }
                      },
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side:
                      const BorderSide(color: AppColors.accent),
                ),
              ),
            ],
          ),
          if (_isPosting) ...[
            const SizedBox(height: 24),
            const CircularProgressIndicator(
                color: AppColors.accent),
            const SizedBox(height: 8),
            const Text('Posting...',
                style: TextStyle(
                    color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
