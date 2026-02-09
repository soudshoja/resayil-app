import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/models/status_update.dart';
import '../../../core/widgets/chat_avatar.dart';
import '../repository/status_repository.dart';

class StatusViewerScreen extends ConsumerStatefulWidget {
  final List<ContactStatus> contacts;
  final int initialContactIndex;

  const StatusViewerScreen({
    super.key,
    required this.contacts,
    this.initialContactIndex = 0,
  });

  @override
  ConsumerState<StatusViewerScreen> createState() =>
      _StatusViewerScreenState();
}

class _StatusViewerScreenState extends ConsumerState<StatusViewerScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentContactIndex;
  int _currentStatusIndex = 0;
  Timer? _timer;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  static const _statusDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentContactIndex = widget.initialContactIndex;
    _pageController =
        PageController(initialPage: widget.initialContactIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: _statusDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStatus();
        }
      });
    _startTimer();
    _markCurrentAsViewed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _startTimer() {
    _progressController.forward(from: 0);
  }

  void _pauseTimer() {
    _progressController.stop();
  }

  void _resumeTimer() {
    _progressController.forward();
  }

  void _nextStatus() {
    final contact = widget.contacts[_currentContactIndex];
    if (_currentStatusIndex < contact.statuses.length - 1) {
      setState(() => _currentStatusIndex++);
      _markCurrentAsViewed();
      _startTimer();
    } else {
      _nextContact();
    }
  }

  void _previousStatus() {
    if (_currentStatusIndex > 0) {
      setState(() => _currentStatusIndex--);
      _startTimer();
    } else {
      _previousContact();
    }
  }

  void _nextContact() {
    if (_currentContactIndex < widget.contacts.length - 1) {
      setState(() {
        _currentContactIndex++;
        _currentStatusIndex = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _markCurrentAsViewed();
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousContact() {
    if (_currentContactIndex > 0) {
      setState(() {
        _currentContactIndex--;
        _currentStatusIndex = widget
            .contacts[_currentContactIndex].statuses.length -
            1;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startTimer();
    }
  }

  void _markCurrentAsViewed() {
    final contact = widget.contacts[_currentContactIndex];
    if (contact.statuses.isNotEmpty) {
      final status = contact.statuses[_currentStatusIndex];
      if (!status.viewed) {
        ref.read(statusRepositoryProvider).markAsViewed(status.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contacts[_currentContactIndex];
    if (contact.statuses.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('No statuses',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final status = contact.statuses[_currentStatusIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _previousStatus();
          } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
            _nextStatus();
          }
        },
        onLongPressStart: (_) => _pauseTimer(),
        onLongPressEnd: (_) => _resumeTimer(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Status content
            _buildStatusContent(status),

            // Top overlay: progress bars + header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 8,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Column(
                  children: [
                    // Progress bars
                    Row(
                      children: List.generate(
                        contact.statuses.length,
                        (index) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            child: _buildProgressBar(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Header: avatar + name + time + close
                    Row(
                      children: [
                        ChatAvatar(
                          name: contact.name,
                          imageUrl: contact.avatar,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                _formatTime(status.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom overlay: caption for media
            if (status.caption != null && status.caption!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).padding.bottom + 16,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  child: Text(
                    status.caption!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    if (index < _currentStatusIndex) {
      // Completed
      return Container(
        height: 2.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1.25),
        ),
      );
    } else if (index == _currentStatusIndex) {
      // Current — animated
      return AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Container(
            height: 2.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.25),
              color: Colors.white30,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressController.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1.25),
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Upcoming
      return Container(
        height: 2.5,
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(1.25),
        ),
      );
    }
  }

  Widget _buildStatusContent(StatusUpdate status) {
    switch (status.type) {
      case 'text':
        final bgColor = status.backgroundColor != null
            ? _parseColor(status.backgroundColor!)
            : AppColors.accent;
        return Container(
          color: bgColor,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                status.text ?? '',
                style: TextStyle(
                  color: status.textColor != null
                      ? _parseColor(status.textColor!)
                      : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );

      case 'image':
        if (status.mediaUrl != null) {
          return CachedNetworkImage(
            imageUrl: status.mediaUrl!,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image,
                  color: Colors.white54, size: 64),
            ),
          );
        }
        return const Center(
          child: Icon(Icons.image, color: Colors.white54, size: 64),
        );

      case 'video':
        if (status.mediaUrl != null) {
          return _buildVideoPlayer(status.mediaUrl!);
        }
        return const Center(
          child: Icon(Icons.videocam, color: Colors.white54, size: 64),
        );

      default:
        return Container(
          color: Colors.black,
          child: Center(
            child: Text(
              status.text ?? 'Unknown status type',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
    }
  }

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayer(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }
          if (_videoController != null && _isVideoInitialized) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
                // Play/pause button overlay
                Center(
                  child: GestureDetector(
                    onTap: _toggleVideoPlayPause,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        }
        // Loading state
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    if (_videoController == null || _videoController!.dataSource != videoUrl) {
      await _videoController?.dispose();
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      try {
        await _videoController!.initialize();
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isVideoPlaying = true;
          });
          _videoController!.play();
          _pauseTimer();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
        rethrow;
      }
    }
  }

  void _toggleVideoPlayPause() {
    if (!_isVideoInitialized || _videoController == null) return;

    setState(() {
      if (_isVideoPlaying) {
        _videoController!.pause();
        _isVideoPlaying = false;
        _resumeTimer();
      } else {
        _videoController!.play();
        _isVideoPlaying = true;
        _pauseTimer();
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return 'Yesterday';
  }
}

/// Custom AnimatedBuilder to avoid using the deprecated AnimatedBuilder pattern
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
