import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/screens/home_screen.dart';
import 'package:moodtube/screens/results_screen.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/theme/tokens.dart';
import 'package:moodtube/widgets/navigation.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return SoftPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          PremiumHeader(
              title: text.explore,
              subtitle: text.smartMoodMatching,
              accent: DesignTokens.cobalt),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: auroraPanelDecoration(color: DesignTokens.panel),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: text.searchHint,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(context),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _search(context),
              icon: const Icon(Icons.travel_explore_rounded),
              label: Text(text.findRecommendations),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
          const SizedBox(height: 26),
          _buildRecentSearches(context, text),
          Text(text.tryReco,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.ink)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: text.searchExamples
                .map((example) => ActionChip(
                      label: Text(example),
                      onPressed: () {
                        controller.text = example;
                        _search(context);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 26),
          Text(text.quickMoods,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.ink)),
          const SizedBox(height: 12),
          SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: dialMoodPresets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  QuickMoodChip(mood: dialMoodPresets[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, AppText text) {
    final state = context.watch<MoodTubeState>();
    final recent = state.recentSearches;
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text.recentSearches,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: DesignTokens.ink,
              ),
            ),
            TextButton(
              onPressed: () => state.clearRecentSearches(),
              child: Text(
                text.clearAll,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DesignTokens.violet,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recent.map((query) {
            return InputChip(
              label: Text(query),
              onPressed: () {
                controller.text = query;
                _search(context);
              },
              onDeleted: () => state.removeRecentSearch(query),
              deleteIcon: const Icon(Icons.close, size: 16),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            );
          }).toList(),
        ),
        const SizedBox(height: 26),
      ],
    );
  }

  void _search(BuildContext context) {
    final languageCode = context
        .read<MoodTubeState>()
        .effectiveLanguageCode(Localizations.localeOf(context));
    final fallback = AppText(languageCode).emptySearchFallback;
    final query =
        controller.text.trim().isEmpty ? fallback : controller.text.trim();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            ResultsScreen(mood: matchMood(query), sourceText: query)));
  }
}
