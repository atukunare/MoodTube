import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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
}
