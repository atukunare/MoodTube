import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/screens/player_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.mood, this.sourceText});

  final MoodPreset mood;
  final String? sourceText;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final Future<List<VideoItem>> resultsFuture;

  @override
  void initState() {
    super.initState();
    final state = context.read<MoodTubeState>();
    final sourceText = widget.sourceText;
    resultsFuture = sourceText == null || sourceText.isEmpty
        ? state.searchMoodAndRemember(widget.mood)
        : state.searchTextAndRemember(sourceText);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
          title: Text(widget.sourceText == null || widget.sourceText!.isEmpty
              ? text.moodName(widget.mood.id)
              : widget.sourceText!)),
      body: SoftPage(
        child: FutureBuilder<List<VideoItem>>(
          future: resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 40, color: DesignTokens.muted),
                      const SizedBox(height: 12),
                      Text(text.genericError,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: DesignTokens.sage,
                              fontSize: 14,
                              height: 1.4,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final results = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
              children: [
                Text(text.moodDescription(widget.mood.id),
                    style: TextStyle(
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.ink)),
                if (widget.sourceText != null &&
                    widget.sourceText!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${text.sourceMoodPrefix}: ${widget.sourceText}',
                      style: TextStyle(color: DesignTokens.sage)),
                ],
                const SizedBox(height: 20),
                ...results.map((item) => VideoResultCard(item: item)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ThumbnailFallback extends StatelessWidget {
  const ThumbnailFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cobalt.withValues(alpha: 0.22),
            DesignTokens.violet.withValues(alpha: 0.20),
            DesignTokens.rose.withValues(alpha: 0.18),
          ],
        ),
        color: DesignTokens.panelAlt,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: DesignTokens.panel.withValues(alpha: 0.8),
            shape: BoxShape.circle),
        child: const Icon(Icons.play_arrow_rounded,
            color: DesignTokens.violet, size: 28),
      ),
    );
  }
}

class VideoResultCard extends StatelessWidget {
  const VideoResultCard({super.key, required this.item});

  final VideoItem item;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final saved = state.isSaved(item.videoId);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: DesignTokens.panel,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                        imageUrl: item.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const ThumbnailFallback()),
              ),
            ),
            const SizedBox(height: 12),
            Text(item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 17,
                    height: 1.22,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.ink)),
            const SizedBox(height: 6),
            Text(
              '${item.channelTitle} · ${text.duration(item.durationSeconds)} · ${text.views(item.viewCount)} · ${text.published(item.publishedText)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13, height: 1.3, color: DesignTokens.muted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...item.tags.map((tag) => Chip(label: Text(text.tag(tag)))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => state.toggleSaved(item),
                    icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_add_outlined),
                    label: Text(saved ? text.saved : text.save),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<MoodTubeState>().setCurrentPlaying(item);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PlayerScreen(item: item)));
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(text.play),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
