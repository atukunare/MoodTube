import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moodtube/app.dart';
import 'package:moodtube/data/mock_catalog.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/screens/library_screen.dart';
import 'package:moodtube/services/search_service.dart';
import 'package:moodtube/state/mood_tube_state.dart';
import 'package:moodtube/widgets/mood_dial.dart';

void main() {
  testWidgets('MoodTube home renders mood cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MoodTubeState(),
        child: const MoodTubeApp(),
      ),
    );

    // The wordmark is rendered as two texts: gradient "Mood" + ink "Tube".
    expect(find.text('Mood'), findsOneWidget);
    expect(find.text('Tube'), findsOneWidget);
    // Atmosphere mood dial node labels (calm -> energetic spectrum).
    expect(find.text('Calm'), findsWidgets);
    expect(find.text('Exciting'), findsWidgets);
    // Smart Picks section is below the fold; scroll to reveal it.
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pump();
    expect(find.text('Smart Picks'), findsWidgets);
  });

  test('scores long playlists higher than short videos', () {
    final score = scoreVideo(
      title: 'relaxing cafe jazz playlist 2 hours',
      durationSeconds: 7200,
      viewCount: 1000000,
      mood: moodPresets[1],
    );

    expect(score, greaterThan(80));
  });

  test('free text search ranks matching mood results', () {
    final results =
        YouTubeSearchService().offlineResultsForQuery('kpop pop playlist');

    expect(results, isNotEmpty);
    // The top result must come from the matched mood's catalog. (Titles are
    // real YouTube titles now, so asserting on title text would couple the
    // test to catalog wording instead of ranking behaviour.)
    final kpopIds =
        mockCatalog['kpop_pop']!.map((video) => video.videoId).toSet();
    expect(kpopIds.contains(results.first.videoId), isTrue);
  });

  test(
      'smart recommendations include Scapetune after search in a variable slot',
      () {
    final candidates =
        YouTubeSearchService().offlineResultsForQuery('rainy night jazz');
    final results = buildSmartRecommendations(candidates,
        lastSearchText: 'rainy night jazz', searchCount: 1);

    expect(results, hasLength(3));
    expect(results.where((item) => item.channelTitle == 'Scapetune'),
        hasLength(1));
  });

  test(
      'mini player resume request only increments for the current playing item',
      () {
    const item = VideoItem(
      videoId: 'resume-video',
      title: 'Resume playback test',
      channelTitle: 'MoodTube',
      durationSeconds: 3600,
      viewCount: 1000,
      publishedText: '1년 전',
      tags: ['공부'],
      score: 90,
    );
    const other = VideoItem(
      videoId: 'other-video',
      title: 'Other playback test',
      channelTitle: 'MoodTube',
      durationSeconds: 3600,
      viewCount: 1000,
      publishedText: '1년 전',
      tags: ['카페'],
      score: 80,
    );
    final state = MoodTubeState();

    expect(state.miniPlayerResumeToken, 0);
    state.requestMiniPlayerResume(item);
    expect(state.miniPlayerResumeToken, 0);

    state.setCurrentPlaying(item);
    state.requestMiniPlayerResume(other);
    expect(state.miniPlayerResumeToken, 0);

    state.requestMiniPlayerResume(item);
    expect(state.miniPlayerResumeToken, 1);
  });

  testWidgets('compact video row keeps thumbnail fallback inside mobile layout',
      (WidgetTester tester) async {
    const item = VideoItem(
      videoId: 'broken-thumb',
      title: 'Long playlist for testing thumbnail fallback',
      channelTitle: 'MoodTube',
      durationSeconds: 7200,
      viewCount: 1200000,
      publishedText: '1년 전',
      tags: ['공부'],
      score: 95,
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MoodTubeState(),
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(20),
              child: CompactVideoRow(item: item),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'aurora mood dial changes selected mood when a mood node is tapped',
      (WidgetTester tester) async {
    var selected = moodPresets.first;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MoodTubeState(),
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: AuroraMoodDial(
                  moods: moodPresets.take(5).toList(),
                  selectedMood: selected,
                  onMoodSelected: (mood) => setState(() => selected = mood),
                  onPrimaryAction: () {},
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cafe Jazz'));
    await tester.pumpAndSettle();

    expect(find.text('Cafe Jazz'), findsWidgets);
    // New dial footer shows the selected mood as "{mood} vibes".
    expect(find.text('Cafe Jazz vibes'), findsOneWidget);
  });

  test('home shows only eight personalized mood categories', () async {
    SharedPreferences.setMockInitialValues({});
    final state = MoodTubeState();
    final results = await state.searchTextAndRemember('kpop pop playlist');

    expect(results, isNotEmpty);
    expect(state.homeMoodPresets, hasLength(8));
    expect(state.homeMoodPresets.first.id, 'kpop_pop');
  });
}
