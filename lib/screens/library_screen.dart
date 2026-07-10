import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/screens/player_screen.dart';
import 'package:moodtube/screens/results_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';
import 'package:moodtube/widgets/navigation.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.onOpenExplore});

  final VoidCallback? onOpenExplore;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String category = 'all';
  final categories = const {
    'all': null,
    'study': '공부',
    'cafe': '카페',
    'sleep': '수면',
    'workout': '운동',
    'drive': '드라이브',
    'likes': '좋아요',
  };

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final saved = context.watch<MoodTubeState>().saved;
    final rawCategory = categories[category];
    final filtered = rawCategory == null
        ? saved
        : saved.where((item) => item.tags.contains(rawCategory)).toList();
    return SoftPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          PremiumHeader(
              title: text.library,
              subtitle: text.librarySubtitle,
              accent: DesignTokens.violet),
          const SizedBox(height: 18),
          // Right-edge fade hints that the chip row scrolls (the last chips
          // sit off-screen on narrow devices).
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.92, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 28),
              child: Row(
                children: categories.keys
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(text.category(item)),
                            selected: category == item,
                            onSelected: (_) => setState(() => category = item),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: auroraPanelDecoration(),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DesignTokens.violet.withValues(alpha: 0.18),
                            DesignTokens.rose.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.bookmark_border_rounded,
                          color: DesignTokens.violet, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(text.noSavedItems,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: DesignTokens.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                        text.libraryEmptySubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: DesignTokens.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    if (widget.onOpenExplore != null) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: widget.onOpenExplore,
                        icon:
                            const Icon(Icons.travel_explore_rounded, size: 18),
                        label: Text(text.saveFromExplore),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ...filtered
                .map((item) => CompactVideoRow(item: item, showDelete: true)),
        ],
      ),
    );
  }
}

class CompactVideoRow extends StatelessWidget {
  const CompactVideoRow(
      {super.key, required this.item, this.showDelete = false});

  final VideoItem item;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<MoodTubeState>().startPlayback(item);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PlayerScreen(item: item)));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: auroraPanelDecoration(
                color: DesignTokens.panel, shadow: DesignTokens.cardShadow),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 64,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                        imageUrl: item.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const ThumbnailFallback()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14.5,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: DesignTokens.ink)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 13, color: DesignTokens.muted),
                          const SizedBox(width: 4),
                          Text(text.clockDuration(item.durationSeconds),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: DesignTokens.muted,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Icon(Icons.headphones_rounded,
                              size: 13, color: DesignTokens.muted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(text.listeners(item.viewCount),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DesignTokens.muted,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      context.read<MoodTubeState>().toggleSaved(item),
                  icon: Icon(
                      showDelete
                          ? Icons.delete_outline_rounded
                          : Icons.chevron_right_rounded,
                      color: DesignTokens.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
