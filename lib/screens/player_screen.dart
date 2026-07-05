import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/screens/results_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.item});

  final VideoItem item;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final YoutubePlayerController controller;
  late final MoodTubeState _tubeState;
  var _shouldResumeMiniPlayer = true;
  bool _showYouTubeOverlay = false;
  bool _overlayDismissed = false;

  @override
  void initState() {
    super.initState();
    _tubeState = context.read<MoodTubeState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tubeState.setCurrentPlaying(widget.item);
    });
    controller = YoutubePlayerController(
      initialVideoId: widget.item.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        controlsVisibleAtStart: true,
        enableCaption: false,
      ),
    );
    controller.addListener(_trackPlaybackIntent);
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.play());
  }

  @override
  void dispose() {
    if (_shouldResumeMiniPlayer) {
      _tubeState.requestMiniPlayerResume(widget.item);
    }
    controller.removeListener(_trackPlaybackIntent);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final saved = state.isSaved(widget.item.videoId);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final player = YoutubePlayer(
      controller: controller,
    );
    _syncSystemUi(isLandscape);
    if (isLandscape) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(child: player),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: Text(text.play)),
      body: Stack(
        children: [
          SoftPage(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      softPanelDecoration(color: DesignTokens.panelAlt),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: YoutubePlayerBuilder(
                      player: player,
                      builder: (context, player) => player,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(widget.item.title,
                    style: TextStyle(
                        fontSize: 22,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.ink)),
                const SizedBox(height: 8),
                Text(widget.item.channelTitle,
                    style: TextStyle(
                        fontSize: 14,
                        color: DesignTokens.sage,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  onPressed: () => state.toggleSaved(widget.item),
                  icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_add_outlined),
                  label: Text(saved ? text.saved : text.savePlaylist),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final mood = matchMood(widget.item.tags.join(' '));
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ResultsScreen(mood: mood)));
                  },
                  icon: const Icon(Icons.queue_music),
                  label: Text(text.similarPlaylists),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await launchUrl(Uri.parse(widget.item.youtubeUrl),
                          mode: LaunchMode.inAppBrowserView);
                    } catch (_) {
                      // Keep playback usable even if the in-app browser is absent.
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(text.openInYouTube),
                ),
              ],
            ),
          ),
          // v0.1.3: YouTube overlay at 30s
          if (_showYouTubeOverlay)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _showYouTubeOverlay ? 1.0 : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: 30,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.open_in_new_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              text.overlaySeeMore,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _showYouTubeOverlay = false;
                              _overlayDismissed = true;
                            }),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white70, size: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() => _showYouTubeOverlay = false);
                            launchUrl(
                              Uri.parse(widget.item.youtubeUrl),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(text.openInYouTube),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0000),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _syncSystemUi(bool isLandscape) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(
        isLandscape ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    });
  }

  void _trackPlaybackIntent() {
    final value = controller.value;
    if (value.hasError) {
      controller.removeListener(_trackPlaybackIntent);
      final videoId = widget.item.videoId;
      _tubeState.blacklistVideo(videoId);

      final errMsg = AppText.of(context).playErrorRestricted;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errMsg)),
          );
          Navigator.of(context).pop();
        }
      });
      setState(() => _shouldResumeMiniPlayer = false);
      return;
    }
    if (value.playerState == PlayerState.paused ||
        value.playerState == PlayerState.ended) {
      _shouldResumeMiniPlayer = false;
      return;
    }
    if (value.isPlaying ||
        value.playerState == PlayerState.playing ||
        value.playerState == PlayerState.buffering) {
      _shouldResumeMiniPlayer = true;
    }
    // v0.1.3: Show YouTube overlay after 30s of playback
    if (value.isPlaying && value.position.inSeconds >= 30 &&
        !_overlayDismissed && !_showYouTubeOverlay) {
      setState(() => _showYouTubeOverlay = true);
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showYouTubeOverlay = false);
      });
    }
  }
}
