import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/screens/explore_screen.dart';
import 'package:moodtube/screens/home_screen.dart';
import 'package:moodtube/screens/library_screen.dart';
import 'package:moodtube/screens/settings_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';
import 'package:moodtube/widgets/mood_dial.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  var index = 0;
  YoutubePlayerController? miniController;
  String? miniVideoId;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final screens = [
      HomeScreen(
        onOpenExplore: () => setState(() => index = 1),
        onOpenSettings: () => setState(() => index = 3),
      ),
      const ExploreScreen(),
      LibraryScreen(onOpenExplore: () => setState(() => index = 1)),
      const SettingsScreen(),
    ];
    final playerState = context.watch<MoodTubeState>();
    final playing = playerState.currentPlaying;
    // Full-screen PlayerScreen owns the YouTube controller — do not create a
    // second mini-player controller while it is open (dual-audio risk).
    final showMini =
        playing != null && !playerState.fullPlayerActive;
    _syncMiniController(showMini ? playing : null);
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        bottom: false,
        // Cross-fade between tabs so switching never snaps.
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(key: ValueKey(index), child: screens[index]),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMini && miniController != null)
              MiniPlayer(
                  item: playing,
                  controller: miniController!,
                  resumeToken: playerState.miniPlayerResumeToken),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
              child: SizedBox(
                height: 76,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 62,
                      decoration: BoxDecoration(
                        color: DesignTokens.panel,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: DesignTokens.cardBorder),
                        boxShadow: DesignTokens.softShadow,
                      ),
                      child: Row(
                        children: [
                          _NavTab(
                              icon: Icons.home_outlined,
                              selectedIcon: Icons.home_rounded,
                              label: text.home,
                              selected: index == 0,
                              onTap: () => setState(() => index = 0)),
                          _NavTab(
                              icon: Icons.explore_outlined,
                              selectedIcon: Icons.explore_rounded,
                              label: text.explore,
                              selected: index == 1,
                              onTap: () => setState(() => index = 1)),
                          const SizedBox(width: 64),
                          _NavTab(
                              icon: Icons.bookmarks_outlined,
                              selectedIcon: Icons.bookmarks_rounded,
                              label: text.library,
                              selected: index == 2,
                              onTap: () => setState(() => index = 2)),
                          _NavTab(
                              icon: Icons.settings_outlined,
                              selectedIcon: Icons.settings_rounded,
                              label: text.settings,
                              selected: index == 3,
                              onTap: () => setState(() => index = 3)),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: _CenterGlowButton(
                        onTap: () => showMoodDialSheet(context),
                        label: text.openMoodDial,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncMiniController(VideoItem? item) {
    if (item == null) {
      if (miniController != null) {
        final toDispose = miniController;
        miniController = null;
        miniVideoId = null;
        Future.microtask(() => toDispose?.dispose());
      }
      return;
    }
    if (miniVideoId == item.videoId) return;
    final toDispose = miniController;
    miniVideoId = item.videoId;
    miniController = YoutubePlayerController(
      initialVideoId: item.videoId,
      flags: const YoutubePlayerFlags(
          autoPlay: true, controlsVisibleAtStart: true, enableCaption: false),
    );
    if (toDispose != null) {
      Future.microtask(() => toDispose.dispose());
    }
  }

  @override
  void dispose() {
    miniController?.dispose();
    super.dispose();
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? DesignTokens.violet : DesignTokens.muted;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, size: 23, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    height: 1,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _CenterGlowButton extends StatelessWidget {
  const _CenterGlowButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: DesignTokens.spectrum,
            ),
            border: Border.all(color: DesignTokens.background, width: 3),
            boxShadow: DesignTokens.glowShadow,
          ),
          child: const Icon(Icons.graphic_eq_rounded,
              color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class MiniPlayer extends StatefulWidget {
  const MiniPlayer(
      {super.key,
      required this.item,
      required this.controller,
      required this.resumeToken});

  final VideoItem item;
  final YoutubePlayerController controller;
  final int resumeToken;

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  YoutubePlayerController? _listeningController;

  @override
  void initState() {
    super.initState();
    _subscribeToController();
    _playAfterVisible();
  }

  @override
  void didUpdateWidget(covariant MiniPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _unsubscribeFromController();
      _subscribeToController();
    }
    if (oldWidget.item.videoId != widget.item.videoId ||
        oldWidget.resumeToken != widget.resumeToken) {
      _playAfterVisible();
    }
  }

  @override
  void dispose() {
    _unsubscribeFromController();
    super.dispose();
  }

  void _subscribeToController() {
    _listeningController = widget.controller;
    _listeningController?.addListener(_onControllerStateChanged);
  }

  void _unsubscribeFromController() {
    _listeningController?.removeListener(_onControllerStateChanged);
    _listeningController = null;
  }

  void _onControllerStateChanged() {
    if (!mounted) return;
    final controller = _listeningController;
    if (controller == null) return;
    if (controller.value.hasError) {
      _unsubscribeFromController();
      final videoId = widget.item.videoId;
      final tubeState = context.read<MoodTubeState>();
      tubeState.blacklistVideo(videoId);

      if (!mounted) return;
      final next = tubeState.advanceToNextInQueue();
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.of(context).playErrorGeneric)),
        );
        // Shell will rebuild mini controller for the new currentPlaying.
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.of(context).playErrorRestricted)),
      );
      tubeState.clearCurrentPlaying();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<MoodTubeState>();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
          color: DesignTokens.panel,
          border: Border(top: BorderSide(color: DesignTokens.line))),
      child: Row(
        children: [
          SizedBox(
            width: 124,
            height: 70,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: YoutubePlayer(
                  controller: widget.controller,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.ink)),
          ),
          IconButton(
              onPressed: state.clearCurrentPlaying,
              icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  void _playAfterVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.play();
    });
  }
}

class PremiumHeader extends StatelessWidget {
  const PremiumHeader(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.accent,
      this.trailing});

  final String title;
  final String subtitle;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // Editorial header: a slim spectrum bar + oversized tight-tracked title on
    // the page background itself — no boxed card, the type carries the design.
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: DesignTokens.spectrum,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 32,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: DesignTokens.ink)),
                const SizedBox(height: 6),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: DesignTokens.muted)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 14),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.42),
              blurRadius: 12,
              spreadRadius: 1)
        ],
      ),
    );
  }
}
