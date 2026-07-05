import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ads/ads.dart' as ads;
import 'package:moodtube/app.dart';
import 'package:moodtube/state/mood_tube_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Global error handlers to catch unhandled errors and prevent silent crashes.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Also log to debug console for development.
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Platform error: $error');
    debugPrint('Stack: $stack');
    return true; // Error was handled; don't crash the app.
  };
  // Ads should never block or crash the music experience.
  unawaited(ads.initAds().catchError((_) {}));
  runApp(
    ChangeNotifierProvider(
      create: (_) => MoodTubeState()..load(),
      child: const MoodTubeApp(),
    ),
  );
}
