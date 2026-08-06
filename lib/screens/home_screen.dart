import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/ads/ads.dart' as ads;
import 'package:moodtube/data/mock_catalog.dart';
import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/screens/player_screen.dart';
import 'package:moodtube/screens/results_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';
import 'package:moodtube/widgets/mood_dial.dart';
import 'package:moodtube/widgets/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenExplore, this.onOpenSettings});

  final VoidCallback? onOpenExplore;
  final VoidCallback? onOpenSettings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDialStarting = false;
  MoodPreset? selectedDialMood;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final featured = state.smartRecommendations;
    final homeMoods = state.homeMoodPresets;
    final selectedDial = dialMoodPresets.firstWhere(
        (m) => m.id == selectedDialMood?.id,
        orElse: () => dialMoodPresets[dialMoodPresets.length ~/ 2]);
    return SoftPage(
      // Signature moment: the backdrop glow slowly takes on the colour of the
      // mood picked on the dial — the mood literally tints the screen.
      tint: atmosphereAccent(selectedDial.id),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 34),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wordmark: "Mood" carries the spectrum, "Tube" stays
                      // ink — the brand gradient is the logo.
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (r) =>
                                DesignTokens.spectrumGradient.createShader(r),
                            child: const Text(
                              'Mood',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: Colors.white),
                            ),
                          ),
                          Text(
                            'Tube',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: DesignTokens.ink),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text.todayLabel(),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: DesignTokens.muted),
                      ),
                    ],
                  ),
                ),
                _CircleIconButton(
                    icon: Icons.search_rounded,
                    label: text.searchLabel,
                    onTap: widget.onOpenExplore ?? () {}),
                const SizedBox(width: 10),
                _CircleIconButton(
                    icon: Icons.person_rounded,
                    gradient: true,
                    label: text.profile,
                    onTap: widget.onOpenSettings ?? () {}),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AuroraMoodDial(
            moods: dialMoodPresets,
            selectedMood: selectedDial,
            onMoodSelected: (mood) => setState(() => selectedDialMood = mood),
            onPrimaryAction: () => _playSelectedMood(selectedDial),
            isPrimaryBusy: isDialStarting,
            showFooter: false,
          ),
          // Content sheet: a shadowed rounded box that tucks the bottom of
          // the dial circle behind it (reference look).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
            decoration: BoxDecoration(
              // Top is a touch translucent so the dial softly melts into the
              // box; it turns solid a little below the seam.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  DesignTokens.sheet.withValues(alpha: 0.55),
                  DesignTokens.sheet,
                ],
                stops: const [0.0, 0.12],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(34)),
              boxShadow: [
                BoxShadow(
                    color: (DesignTokens.isDark
                        ? const Color(0x55000000)
                        : const Color(0x163b2f7a)),
                    blurRadius: 30,
                    offset: const Offset(0, -10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 98,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: homeMoods.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) =>
                        QuickMoodChip(mood: homeMoods[index]),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(text.smartPicks,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: DesignTokens.ink)),
                          const SizedBox(height: 3),
                          Text(
                            // Show the matched mood, never the raw query
                            // string — internal queries read like debug text.
                            state.lastSearchText.isNotEmpty
                                ? text.smartPicksBasedOn(text.moodName(
                                    matchMood(state.lastSearchText).id))
                                : text.smartPicksSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: DesignTokens.muted),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _browseSelectedMood(selectedDial),
                      child: Row(
                        children: [
                          Text(text.seeAll,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: DesignTokens.violet)),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: DesignTokens.violet),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < featured.length; i++) ...[
                  SmartPickCard(
                      item: featured[i], accent: DesignTokens.moodColor(i)),
                  // sponsored slot after the 3rd pick (renders nothing until
                  // an ad loads; always nothing on web)
                  if (i == 2) ads.smartPickAd(),
                ],
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        text.browseByMood,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: DesignTokens.ink),
                      ),
                    ),
                    IconButton(
                      tooltip: text.refreshMoods,
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          context.read<MoodTubeState>().refreshHomeMoods(),
                      icon: Icon(Icons.refresh_rounded,
                          size: 22, color: DesignTokens.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: homeMoods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.22,
                  ),
                  itemBuilder: (context, index) =>
                      MoodCard(mood: homeMoods[index]),
                ),
                const SizedBox(height: 14),
                // Curated channel slot as a full-width banner — visually
                // separate from the mood grid so it never orphans a grid row.
                const _ScapetuneBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playSelectedMood(MoodPreset mood) async {
    if (isDialStarting) return;
    setState(() => isDialStarting = true);
    try {
      final state = context.read<MoodTubeState>();
      final results = await state.searchMoodAndRemember(mood);
      if (!mounted || results.isEmpty) return;
      final item = results.first;
      state.startPlayback(item, queue: results);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PlayerScreen(item: item, queue: results)));
    } finally {
      if (mounted) setState(() => isDialStarting = false);
    }
  }

  void _browseSelectedMood(MoodPreset mood) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood)),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton(
      {required this.icon,
      required this.onTap,
      required this.label,
      this.gradient = false});

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: DesignTokens.spectrum,
                  )
                : null,
            color: gradient ? null : DesignTokens.panelAlt,
            border: Border.all(color: DesignTokens.cardBorder),
            boxShadow: DesignTokens.smallShadow,
          ),
          child: Icon(icon,
              size: 22, color: gradient ? Colors.white : DesignTokens.ink),
        ),
      ),
    );
  }
}

class MoodGlyph extends StatelessWidget {
  const MoodGlyph({super.key, required this.moodId, required this.accent});

  final String moodId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.92),
            DesignTokens.violet.withValues(alpha: 0.78)
          ],
        ),
        boxShadow: [
          BoxShadow(
              color: accent.withValues(alpha: 0.34),
              blurRadius: 14,
              offset: const Offset(0, 8))
        ],
      ),
      child: Icon(iconForMood(moodId), color: Colors.white, size: 19),
    );
  }

  static IconData iconForMood(String id) {
    return switch (id) {
      'study_work' => Icons.menu_book_rounded,
      'cafe_jazz' => Icons.local_cafe_rounded,
      'rainy_night' => Icons.water_drop_rounded,
      'workout_edm' => Icons.fitness_center_rounded,
      'drive' => Icons.directions_car_rounded,
      'sleep_piano' => Icons.bedtime_rounded,
      'morning' => Icons.wb_sunny_rounded,
      'late_night' => Icons.nights_stay_rounded,
      'chill_lofi' => Icons.headphones_rounded,
      'classical_focus' => Icons.piano_rounded,
      'kpop_pop' => Icons.mic_rounded,
      'rock_energy' => Icons.bolt_rounded,
      'meditation_ambient' => Icons.spa_rounded,
      'gaming_focus' => Icons.sports_esports_rounded,
      'cooking_bossa' => Icons.restaurant_rounded,
      'sad_ballad' => Icons.favorite_rounded,
      'nature_sound' => Icons.forest_rounded,
      'party_dance' => Icons.celebration_rounded,
      'acoustic_folk' => Icons.music_note_rounded,
      'film_score' => Icons.movie_rounded,
      'mood_calm' => Icons.favorite_rounded,
      'mood_melancholy' => Icons.cloudy_snowing,
      'mood_dreamy' => Icons.cloud_rounded,
      'mood_energetic' => Icons.bolt_rounded,
      'mood_exciting' => Icons.wb_sunny_rounded,
      _ => Icons.graphic_eq_rounded,
    };
  }
}

// Reference-1 style horizontal quick chip: a soft pastel rounded-square icon
// with the mood label underneath.
class QuickMoodChip extends StatelessWidget {
  const QuickMoodChip({super.key, required this.mood});

  final MoodPreset mood;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final moodIndex = moodPresets.indexWhere((item) => item.id == mood.id);
    final accent = mood.id.startsWith('mood_')
        ? atmosphereAccent(mood.id)
        : DesignTokens.moodColor(max(0, moodIndex));
    return SizedBox(
      width: 72,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.panel,
                    accent.withValues(alpha: 0.18),
                  ],
                ),
                border: Border.all(color: DesignTokens.cardBorder),
                boxShadow: DesignTokens.smallShadow,
              ),
              child:
                  Icon(MoodGlyph.iconForMood(mood.id), color: accent, size: 26),
            ),
            const SizedBox(height: 7),
            Text(
              text.moodName(mood.id),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.sage),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodCard extends StatelessWidget {
  const MoodCard({super.key, required this.mood});

  final MoodPreset mood;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final moodIndex = moodPresets.indexWhere((item) => item.id == mood.id);
    final accent = DesignTokens.moodColor(max(0, moodIndex));
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: auroraPanelDecoration(
            color: DesignTokens.panel, shadow: DesignTokens.cardShadow),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: StatusDot(color: accent),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DesignTokens.panelAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: DesignTokens.line),
                  boxShadow: DesignTokens.smallShadow,
                ),
                child: MoodGlyph(moodId: mood.id, accent: accent),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 9),
                  Text(
                    text.moodName(mood.id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text.moodDescription(mood.id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: DesignTokens.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Rich Smart Pick card: rounded thumbnail with play overlay, title,
// genre tag chips, listener count, clock duration, and a bookmark toggle.
class SmartPickCard extends StatefulWidget {
  const SmartPickCard({super.key, required this.item, required this.accent});

  final VideoItem item;
  final Color accent;

  @override
  State<SmartPickCard> createState() => _SmartPickCardState();
}

class _SmartPickCardState extends State<SmartPickCard> {
  bool _hasTrackedImpression = false;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final saved = state.isSaved(widget.item.videoId);
    // Transparency: clearly mark picks coming from the pinned spotlight
    // channel so curated promotion is never mistaken for organic ranking.
    final isSpotlight = state.smartPinnedChannel.trim().isNotEmpty &&
        widget.item.channelTitle
            .toLowerCase()
            .contains(state.smartPinnedChannel.trim().toLowerCase());
    // The badge already fills the row on spotlight cards — keep one mood tag
    // (and drop the channel-name tag) so nothing gets ellipsized into
    // "집중 · …" noise.
    final tags = widget.item.tags
        .where((tag) =>
            tag.toLowerCase() !=
            state.smartPinnedChannel.trim().toLowerCase())
        .take(isSpotlight ? 1 : 3)
        .map(text.tag)
        .toList();
    // Track impression for Scapetune spotlight cards exactly once
    if (isSpotlight && !_hasTrackedImpression) {
      _hasTrackedImpression = true;
      Future.microtask(() {
        if (mounted) {
          context.read<MoodTubeState>().trackImpression(
                widget.item.videoId,
                widget.item.channelTitle,
              );
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final queue = state.smartRecommendations;
            state.startPlayback(widget.item, queue: queue);
            // Track click for Scapetune spotlight cards
            if (isSpotlight) {
              context.read<MoodTubeState>().trackClick(
                    widget.item.videoId,
                    widget.item.channelTitle,
                  );
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    PlayerScreen(item: widget.item, queue: queue)));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: auroraPanelDecoration(
                color: DesignTokens.panel, shadow: DesignTokens.cardShadow),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: widget.item.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) =>
                              const ThumbnailFallback(),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            shape: BoxShape.circle,
                            boxShadow: DesignTokens.smallShadow,
                          ),
                          child: Icon(Icons.play_arrow_rounded,
                              color: widget.accent, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: DesignTokens.ink)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isSpotlight) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                gradient: DesignTokens.spectrumGradient,
                              ),
                              // 12 is the design-system minimum font size.
                              child: Text(
                                  state.badgeVariant == 'B'
                                      ? text.badgeMoodChannel
                                      : text.badgeFeatured,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (tags.isNotEmpty)
                            Flexible(
                              child: Text(tags.join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: widget.accent)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.headphones_rounded,
                              size: 13, color: DesignTokens.muted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(text.listeners(widget.item.viewCount),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: DesignTokens.muted)),
                          ),
                           const SizedBox(width: 10),
                          Icon(Icons.schedule_rounded,
                              size: 13, color: DesignTokens.muted),
                          const SizedBox(width: 4),
                          Text(text.clockDuration(widget.item.durationSeconds),
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: DesignTokens.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      context.read<MoodTubeState>().toggleSaved(widget.item),
                  icon: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: saved ? DesignTokens.violet : DesignTokens.muted,
                      size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Curated Scapetune slot as a full-width banner below the mood grid. A banner
// (instead of a grid cell) never orphans a grid row and gives the channel
// promotion a proper stage: thumbnail, eyebrow label, title, spectrum play.
class _ScapetuneBanner extends StatelessWidget {
  const _ScapetuneBanner();

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final video = spotlightVideoForQuery('', moodPresets.first,
        isBlacklisted: state.isBlacklisted);
    final queue =
        scapetuneSpotlightQueue(isBlacklisted: state.isBlacklisted);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          final playQueue = queue.isNotEmpty ? queue : [video];
          state.startPlayback(video, queue: playQueue);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) =>
                    PlayerScreen(item: video, queue: playQueue)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: auroraPanelDecoration(
              color: DesignTokens.panel, shadow: DesignTokens.cardShadow),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const ThumbnailFallback(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.todaysChannelPick,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: DesignTokens.violet,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      video.channelTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: DesignTokens.spectrum,
                  ),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
