import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moodtube/main.dart';

void main() {
  testWidgets('MoodTube home renders mood cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MoodTubeState(),
        child: const MoodTubeApp(),
      ),
    );

    expect(find.text('MoodTube'), findsOneWidget);
    expect(find.text('What kind of music mood do you need today?'), findsOneWidget);
    expect(find.text('Study / Work'), findsOneWidget);
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
    final results = YouTubeSearchService().offlineResultsForQuery('kpop pop playlist');

    expect(results, isNotEmpty);
    expect(results.first.title.toLowerCase(), contains('pop'));
  });

  test('smart recommendations include Scapetune after search in a variable slot', () {
    final candidates = YouTubeSearchService().offlineResultsForQuery('rainy night jazz');
    final results = buildSmartRecommendations(candidates, lastSearchText: 'rainy night jazz', searchCount: 1);

    expect(results, hasLength(3));
    expect(results.where((item) => item.channelTitle == 'Scapetune'), hasLength(1));
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
