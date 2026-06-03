import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DesignTokens {
  static const background = Color(0xffedf1f6);
  static const backgroundDeep = Color(0xffd8e0e9);
  static const panel = Color(0xf8f7f9fc);
  static const panelAlt = Color(0xffeef3f8);
  static const mint = Color(0xff2fd0ac);
  static const sage = Color(0xff566173);
  static const ink = Color(0xff111827);
  static const muted = Color(0xff687386);
  static const peach = Color(0xffff6b35);
  static const cream = Color(0xfffbfcff);
  static const cobalt = Color(0xff2477ff);
  static const violet = Color(0xff8b5cf6);
  static const graphite = Color(0xff252b36);
  static const line = Color(0xd9ffffff);
  static const darkLine = Color(0x1f111827);

  static const moodPalette = [
    Color(0xffff6b35),
    Color(0xff2477ff),
    Color(0xff252b36),
    Color(0xffff4267),
    Color(0xff8b5cf6),
    Color(0xff2fd0ac),
    Color(0xff8792a5),
    Color(0xffffb23f),
  ];

  static List<BoxShadow> get softShadow => const [
        BoxShadow(color: Color(0x1f101828), blurRadius: 28, offset: Offset(10, 16)),
        BoxShadow(color: Color(0xd9ffffff), blurRadius: 18, offset: Offset(-8, -8)),
      ];

  static List<BoxShadow> get smallShadow => const [
        BoxShadow(color: Color(0x17101828), blurRadius: 16, offset: Offset(6, 8)),
        BoxShadow(color: Color(0xccffffff), blurRadius: 10, offset: Offset(-5, -5)),
      ];

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(color: Color(0x24101828), blurRadius: 24, offset: Offset(10, 14)),
        BoxShadow(color: Color(0xbfffffff), blurRadius: 12, offset: Offset(-4, -5)),
      ];

  static Color moodColor(int index) => moodPalette[index % moodPalette.length];
}

BoxDecoration softPanelDecoration({Color color = DesignTokens.panel, List<BoxShadow>? shadow}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: DesignTokens.line),
    boxShadow: shadow ?? DesignTokens.softShadow,
  );
}

class SoftBackdrop extends StatelessWidget {
  const SoftBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff6f8fb), Color(0xffe6ebf2), Color(0xfff9fafc)],
          ),
        ),
        child: CustomPaint(painter: _SurfaceGridPainter()),
      ),
    );
  }
}

class _SurfaceGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x33aab3c2)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 96) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = 0.0; y < size.height; y += 112) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final sheenPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00ffffff), Color(0x88ffffff), Color(0x00ffffff)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sheenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SoftPage extends StatelessWidget {
  const SoftPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: SoftBackdrop()),
        Positioned.fill(child: child),
      ],
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MoodTubeState()..load(),
      child: const MoodTubeApp(),
    ),
  );
}

class MoodTubeApp extends StatelessWidget {
  const MoodTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodTubeState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'MoodTube',
          debugShowCheckedModeBanner: false,
          locale: state.appLocale,
          supportedLocales: const [Locale('en'), Locale('ko')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale?.languageCode == 'ko') return const Locale('ko');
            return const Locale('en');
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: DesignTokens.mint,
              brightness: Brightness.light,
            ).copyWith(
              surface: DesignTokens.panel,
              surfaceContainerHighest: DesignTokens.panelAlt,
              primary: DesignTokens.peach,
              secondary: DesignTokens.mint,
              onSurface: DesignTokens.ink,
              onPrimary: DesignTokens.ink,
            ),
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: DesignTokens.background,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: DesignTokens.ink,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: DesignTokens.ink),
            ),
            cardTheme: CardThemeData(
              color: DesignTokens.panel,
              elevation: 4,
              shadowColor: const Color(0x331f2a27),
              surfaceTintColor: Colors.transparent,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: DesignTokens.line),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            chipTheme: const ChipThemeData(
              backgroundColor: Color(0xf4f8faff),
              selectedColor: Color(0xffffd6c7),
              labelStyle: TextStyle(color: DesignTokens.sage, fontSize: 12, fontWeight: FontWeight.w800),
              side: BorderSide(color: DesignTokens.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(
                foregroundColor: DesignTokens.sage,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xf4f7f9fc),
              indicatorColor: const Color(0xffffd6c7),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  color: states.contains(WidgetState.selected) ? DesignTokens.ink : DesignTokens.muted,
                  fontSize: 12,
                  fontWeight: states.contains(WidgetState.selected) ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected) ? DesignTokens.ink : DesignTokens.muted,
                  size: 24,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xf6f8faff),
              labelStyle: const TextStyle(color: DesignTokens.muted),
              helperStyle: const TextStyle(color: DesignTokens.muted),
              prefixIconColor: DesignTokens.peach,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: DesignTokens.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: DesignTokens.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: DesignTokens.peach, width: 1.5),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: DesignTokens.peach,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.ink,
                backgroundColor: const Color(0xf2f8faff),
                side: const BorderSide(color: DesignTokens.line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          home: const ShellScreen(),
        );
      },
    );
  }
}

class AppText {
  const AppText(this.languageCode);

  final String languageCode;

  static AppText of(BuildContext context) {
    final state = context.watch<MoodTubeState>();
    final locale = Localizations.localeOf(context);
    return AppText(state.effectiveLanguageCode(locale));
  }

  bool get isKo => languageCode == 'ko';

  String get home => isKo ? '홈' : 'Home';
  String get explore => isKo ? '탐색' : 'Explore';
  String get library => isKo ? '보관함' : 'Library';
  String get settings => isKo ? '설정' : 'Settings';
  String get homePrompt => isKo ? '오늘은 어떤 분위기의 음악이 필요하세요?' : 'What kind of music mood do you need today?';
  String get smartRecommendations => isKo ? '스마트 추천' : 'Smart Picks';
  String get smartMoodMatching => isKo ? '스마트 무드 매칭으로 분위기 기반 추천을 찾아보세요.' : 'Find mood-based recommendations with smart mood matching.';
  String get searchHint => isKo ? '예: 비 오는 밤 재즈' : 'Example: rainy night jazz';
  String get findRecommendations => isKo ? '추천 찾기' : 'Find picks';
  String get sourceMoodPrefix => isKo ? '입력한 분위기' : 'Entered mood';
  String get saved => isKo ? '저장됨' : 'Saved';
  String get save => isKo ? '저장' : 'Save';
  String get play => isKo ? '재생' : 'Play';
  String get savePlaylist => isKo ? '저장하기' : 'Save';
  String get similarPlaylists => isKo ? '비슷한 플레이리스트' : 'Similar playlists';
  String get openInYouTube => isKo ? '유튜브에서 열기' : 'Open in YouTube';
  String get noSavedItems => isKo ? '아직 저장한 플레이리스트가 없습니다.' : 'No saved playlists yet.';
  String get librarySubtitle => isKo ? '저장한 분위기를 한눈에 정리하세요.' : 'Keep your saved moods beautifully organized.';
  String get settingsSubtitle => isKo ? '언어, API, 추천 기준을 조정하세요.' : 'Tune language, API, and recommendation settings.';
  String get appDescriptionTitle => isKo ? '앱 설명' : 'About MoodTube';
  String get appDescriptionBody => isKo
      ? 'MoodTube는 분위기를 고르면 유튜브 안의 긴 음악 플레이리스트를 찾아주는 앱입니다.'
      : 'MoodTube helps you find long music playlists on YouTube by mood.';
  String get policyTitle => isKo ? '정책 안내' : 'Policy notice';
  String get policyBody => isKo
      ? 'MoodTube는 유튜브 영상을 직접 저장하거나 다운로드하지 않습니다. 모든 재생은 공식 유튜브 플레이어를 통해 이루어집니다.'
      : 'MoodTube does not save or download YouTube videos. All playback happens through the official YouTube player.';
  String get apiMode => isKo ? 'API 모드' : 'API mode';
  String get apiModeHelp => isKo ? '키가 없거나 호출이 실패하면 Mock 데이터로 표시됩니다.' : 'If the key is missing or a request fails, mock data is shown.';
  String get apiKey => isKo ? 'YouTube API Key' : 'YouTube API key';
  String get apiKeyHelp => isKo ? '로컬 설정에 저장됩니다. 초기 MVP에서는 로그인 없이 사용합니다.' : 'Stored locally. This MVP works without sign-in.';
  String get smartPinnedChannel => isKo ? '스마트 추천 스포트라이트 채널' : 'Smart Picks spotlight channel';
  String get smartPinnedChannelHelp => isKo
      ? '최근 검색어 기반 추천 사이에 이 채널을 가끔 섞어 보여줍니다. 기본값은 Scapetune입니다.'
      : 'This channel occasionally appears inside search-based Smart Picks. Default is Scapetune.';
  String get language => isKo ? '언어' : 'Language';
  String get languageHelp => isKo ? '기기 언어를 따르거나 앱 언어를 직접 고를 수 있습니다.' : 'Follow the device language or choose an app language.';
  String get automatic => isKo ? '자동' : 'Auto';
  String get english => isKo ? '영어' : 'English';
  String get korean => isKo ? '한국어' : 'Korean';
  String get appVersion => isKo ? '앱 버전 0.1.0' : 'App version 0.1.0';
  String get unknownUploadDate => isKo ? '업로드일 정보 없음' : 'Upload date unavailable';
  String get all => isKo ? '전체' : 'All';

  List<String> get searchExamples => isKo
      ? ['비 오는 밤 재즈', '운동할 때 EDM', '카페에서 들을 음악', '코딩 집중 음악']
      : ['rainy night jazz', 'workout EDM', 'music for a cafe', 'coding focus music'];

  String get emptySearchFallback => isKo ? '공부 집중' : 'study focus';

  String duration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (isKo) {
      if (hours > 0) return '$hours시간 ${minutes.toString().padLeft(2, '0')}분';
      return '$minutes분';
    }
    if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    return '${minutes}m';
  }

  String views(int viewCount) {
    if (isKo) {
      if (viewCount >= 100000000) return '${(viewCount / 100000000).toStringAsFixed(1)}억회';
      if (viewCount >= 10000) return '${(viewCount / 10000).toStringAsFixed(1)}만회';
      return '$viewCount회';
    }
    if (viewCount >= 1000000) return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    if (viewCount >= 1000) return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    return '$viewCount views';
  }

  String published(String value) {
    final yearMatch = RegExp(r'^(\d+)년 전$').firstMatch(value);
    if (yearMatch != null) {
      final years = yearMatch.group(1)!;
      return isKo ? value : '$years ${years == '1' ? 'year' : 'years'} ago';
    }
    final monthMatch = RegExp(r'^(\d+)개월 전$').firstMatch(value);
    if (monthMatch != null) {
      final months = monthMatch.group(1)!;
      return isKo ? value : '$months ${months == '1' ? 'month' : 'months'} ago';
    }
    return value;
  }

  String category(String key) {
    final ko = {
      'all': '전체',
      'study': '공부',
      'cafe': '카페',
      'sleep': '수면',
      'workout': '운동',
      'drive': '드라이브',
      'likes': '좋아요',
    };
    final en = {
      'all': 'All',
      'study': 'Study',
      'cafe': 'Cafe',
      'sleep': 'Sleep',
      'workout': 'Workout',
      'drive': 'Drive',
      'likes': 'Likes',
    };
    return (isKo ? ko : en)[key] ?? key;
  }

  String tag(String value) {
    final koToEn = {
      '공부': 'Study',
      '집중': 'Focus',
      '작업': 'Work',
      '코딩': 'Coding',
      '카페': 'Cafe',
      '재즈': 'Jazz',
      '브런치': 'Brunch',
      '비': 'Rain',
      '밤': 'Night',
      '감성': 'Mood',
      '피아노': 'Piano',
      '운동': 'Workout',
      '헬스': 'Gym',
      '러닝': 'Running',
      '드라이브': 'Drive',
      '여행': 'Travel',
      '여름': 'Summer',
      '수면': 'Sleep',
      '휴식': 'Rest',
      '명상': 'Meditation',
      '아침': 'Morning',
      '상쾌한': 'Fresh',
      '시작': 'Start',
      '새벽': 'Late Night',
      '조용한': 'Quiet',
      '좋아요': 'Likes',
      '로파이': 'Lofi',
      '클래식': 'Classical',
      '케이팝': 'K-pop',
      '팝': 'Pop',
      '록': 'Rock',
      '메탈': 'Metal',
      '게임': 'Gaming',
      '요리': 'Cooking',
      '보사노바': 'Bossa Nova',
      '발라드': 'Ballad',
      '슬픈': 'Sad',
      '자연': 'Nature',
      '숲': 'Forest',
      '파티': 'Party',
      '댄스': 'Dance',
      '어쿠스틱': 'Acoustic',
      '영화': 'Film',
      'OST': 'OST',
      'Scapetune': 'Scapetune',
    };
    if (isKo) return value;
    return koToEn[value] ?? value;
  }

  String moodName(String id) {
    final ko = {
      'study_work': '공부 / 작업',
      'cafe_jazz': '카페 재즈',
      'rainy_night': '비 오는 밤',
      'workout_edm': '운동 EDM',
      'drive': '드라이브',
      'sleep_piano': '수면 피아노',
      'morning': '아침 시작',
      'late_night': '감성 밤',
      'chill_lofi': '칠 로파이',
      'classical_focus': '클래식 집중',
      'kpop_pop': 'K-pop / 팝',
      'rock_energy': '록 에너지',
      'meditation_ambient': '명상 앰비언트',
      'gaming_focus': '게임 집중',
      'cooking_bossa': '요리 보사노바',
      'sad_ballad': '슬픈 발라드',
      'nature_sound': '자연 사운드',
      'party_dance': '파티 댄스',
      'acoustic_folk': '어쿠스틱 포크',
      'film_score': '영화 OST',
    };
    final en = {
      'study_work': 'Study / Work',
      'cafe_jazz': 'Cafe Jazz',
      'rainy_night': 'Rainy Night',
      'workout_edm': 'Workout EDM',
      'drive': 'Drive',
      'sleep_piano': 'Sleep Piano',
      'morning': 'Morning Start',
      'late_night': 'Late Night Mood',
      'chill_lofi': 'Chill Lofi',
      'classical_focus': 'Classical Focus',
      'kpop_pop': 'K-pop / Pop',
      'rock_energy': 'Rock Energy',
      'meditation_ambient': 'Meditation Ambient',
      'gaming_focus': 'Gaming Focus',
      'cooking_bossa': 'Cooking Bossa',
      'sad_ballad': 'Sad Ballads',
      'nature_sound': 'Nature Sound',
      'party_dance': 'Party Dance',
      'acoustic_folk': 'Acoustic Folk',
      'film_score': 'Film Scores',
    };
    return (isKo ? ko : en)[id] ?? id;
  }

  String moodDescription(String id) {
    final ko = {
      'study_work': '집중이 필요한 시간에 어울리는 플레이리스트입니다.',
      'cafe_jazz': '카페에 앉아 있는 듯 잔잔한 플레이리스트입니다.',
      'rainy_night': '비 오는 밤에 어울리는 플레이리스트입니다.',
      'workout_edm': '운동 흐름을 끌어올리는 에너지 높은 플레이리스트입니다.',
      'drive': '도로 위 기분을 살려주는 플레이리스트입니다.',
      'sleep_piano': '잠들기 전 편안하게 틀어두기 좋은 플레이리스트입니다.',
      'morning': '하루를 산뜻하게 열어주는 플레이리스트입니다.',
      'late_night': '늦은 밤 조용히 듣기 좋은 플레이리스트입니다.',
      'chill_lofi': '가볍게 틀어두기 좋은 로파이/칠 플레이리스트입니다.',
      'classical_focus': '집중과 독서에 어울리는 클래식 플레이리스트입니다.',
      'kpop_pop': '가볍고 익숙한 팝 감성 플레이리스트입니다.',
      'rock_energy': '에너지가 필요한 순간에 어울리는 록 플레이리스트입니다.',
      'meditation_ambient': '명상과 호흡에 어울리는 앰비언트 플레이리스트입니다.',
      'gaming_focus': '게임이나 반복 작업에 어울리는 집중 플레이리스트입니다.',
      'cooking_bossa': '요리하거나 집안일할 때 틀기 좋은 플레이리스트입니다.',
      'sad_ballad': '조용히 감정에 잠기고 싶을 때 어울리는 플레이리스트입니다.',
      'nature_sound': '자연 소리와 함께 쉬고 싶을 때 어울리는 플레이리스트입니다.',
      'party_dance': '기분을 올리고 싶을 때 어울리는 댄스 플레이리스트입니다.',
      'acoustic_folk': '편안한 어쿠스틱/포크 감성 플레이리스트입니다.',
      'film_score': '몰입감을 주는 영화 음악 플레이리스트입니다.',
    };
    final en = {
      'study_work': 'Playlists for focus-heavy study, work, and coding sessions.',
      'cafe_jazz': 'Relaxed playlists that feel like sitting in a quiet cafe.',
      'rainy_night': 'Playlists for calm, rainy nights.',
      'workout_edm': 'High-energy playlists to keep your workout moving.',
      'drive': 'Playlists that fit the feeling of the open road.',
      'sleep_piano': 'Gentle playlists for winding down before sleep.',
      'morning': 'Fresh playlists to start the day.',
      'late_night': 'Quiet playlists for late-night listening.',
      'chill_lofi': 'Easygoing lofi playlists for casual listening.',
      'classical_focus': 'Classical playlists for reading and deep focus.',
      'kpop_pop': 'Familiar pop and K-pop mood playlists.',
      'rock_energy': 'Rock playlists for an energy lift.',
      'meditation_ambient': 'Ambient playlists for breathing and meditation.',
      'gaming_focus': 'Focus playlists for gaming and repetitive work.',
      'cooking_bossa': 'Bossa and kitchen-friendly playlists.',
      'sad_ballad': 'Quiet ballad playlists for reflective moments.',
      'nature_sound': 'Nature sound playlists for rest.',
      'party_dance': 'Dance playlists for lifting the mood.',
      'acoustic_folk': 'Warm acoustic and folk playlists.',
      'film_score': 'Cinematic playlists for immersive listening.',
    };
    return (isKo ? ko : en)[id] ?? id;
  }
}

class LanguageOption {
  const LanguageOption(this.code, this.labelKey);

  final String code;
  final String labelKey;

  String label(AppText text) {
    return switch (labelKey) {
      'auto' => text.automatic,
      'en' => text.english,
      'ko' => text.korean,
      _ => labelKey,
    };
  }
}

const languageOptions = [
  LanguageOption('auto', 'auto'),
  LanguageOption('en', 'en'),
  LanguageOption('ko', 'ko'),
];

const scapetuneChannelHandle = '@my_scapetune';

class MoodTubeState extends ChangeNotifier {
  final YouTubeSearchService searchService = YouTubeSearchService();
  final List<VideoItem> _saved = [];
  final Map<String, int> _moodSearchCounts = {};
  List<VideoItem> _lastSearchResults = [];
  VideoItem? currentPlaying;
  int homeRefreshSeed = 0;
  bool apiMode = false;
  String apiKey = '';
  String smartPinnedChannel = 'Scapetune';
  String languageCode = 'auto';
  String lastSearchText = '';
  int searchCount = 0;

  List<VideoItem> get saved => List.unmodifiable(_saved);
  List<VideoItem> get smartRecommendations {
    final candidates = _lastSearchResults.isNotEmpty
        ? _lastSearchResults
        : searchService.offlineResultsForQuery(
            lastSearchText.isEmpty ? 'study focus' : lastSearchText,
            mood: lastSearchText.isEmpty ? moodPresets.first : matchMood(lastSearchText),
            includeSpotlight: shouldShowSpotlight,
            spotlightChannel: smartPinnedChannel,
          );
    return buildSmartRecommendations(
      candidates,
      lastSearchText: lastSearchText,
      searchCount: searchCount,
      spotlightChannel: smartPinnedChannel,
    );
  }

  bool get shouldShowSpotlight => searchCount > 0;
  Locale? get appLocale => languageCode == 'auto' ? null : Locale(languageCode);

  List<MoodPreset> get homeMoodPresets {
    final ordered = [...moodPresets];
    ordered.sort((a, b) {
      final countCompare = (_moodSearchCounts[b.id] ?? 0).compareTo(_moodSearchCounts[a.id] ?? 0);
      if (countCompare != 0) return countCompare;
      final aIndex = moodPresets.indexOf(a);
      final bIndex = moodPresets.indexOf(b);
      if ((_moodSearchCounts[a.id] ?? 0) == 0 && (_moodSearchCounts[b.id] ?? 0) == 0) {
        return ((aIndex + homeRefreshSeed) % moodPresets.length).compareTo((bIndex + homeRefreshSeed) % moodPresets.length);
      }
      return aIndex.compareTo(bIndex);
    });
    return ordered.take(8).toList(growable: false);
  }

  void refreshHomeMoods() {
    homeRefreshSeed = (homeRefreshSeed + 3) % moodPresets.length;
    notifyListeners();
  }

  void setCurrentPlaying(VideoItem item) {
    currentPlaying = item;
    notifyListeners();
  }

  void clearCurrentPlaying() {
    currentPlaying = null;
    notifyListeners();
  }

  String effectiveLanguageCode(Locale locale) {
    if (languageCode == 'ko') return 'ko';
    if (languageCode == 'en') return 'en';
    return locale.languageCode == 'ko' ? 'ko' : 'en';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    apiMode = prefs.getBool('apiMode') ?? false;
    apiKey = prefs.getString('apiKey') ?? '';
    smartPinnedChannel = prefs.getString('smartPinnedChannel') ?? smartPinnedChannel;
    languageCode = prefs.getString('languageCode') ?? 'auto';
    lastSearchText = prefs.getString('lastSearchText') ?? '';
    searchCount = prefs.getInt('searchCount') ?? 0;
    _moodSearchCounts
      ..clear()
      ..addAll(_decodeSearchCounts(prefs.getString('moodSearchCounts')));
    final raw = prefs.getStringList('savedItems') ?? [];
    _saved
      ..clear()
      ..addAll(raw.map((item) => VideoItem.fromJson(jsonDecode(item))));
    notifyListeners();
  }

  Future<void> setApiMode(bool value) async {
    apiMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('apiMode', value);
    notifyListeners();
  }

  Future<void> setApiKey(String value) async {
    apiKey = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
    notifyListeners();
  }

  Future<void> setLanguageCode(String value) async {
    languageCode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', value);
    notifyListeners();
  }

  Future<void> setSmartPinnedChannel(String value) async {
    smartPinnedChannel = value.trim().isEmpty ? 'Scapetune' : value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('smartPinnedChannel', smartPinnedChannel);
    notifyListeners();
  }

  bool isSaved(String videoId) => _saved.any((item) => item.videoId == videoId);

  Future<void> toggleSaved(VideoItem item) async {
    if (isSaved(item.videoId)) {
      _saved.removeWhere((savedItem) => savedItem.videoId == item.videoId);
    } else {
      _saved.insert(0, item);
    }
    await _persistSaved();
    notifyListeners();
  }

  Future<List<VideoItem>> searchMoodAndRemember(MoodPreset mood) async {
    await _rememberSearch(mood.queries.first, mood);
    final results = await searchService.searchMood(
      mood: mood,
      apiMode: apiMode,
      apiKey: apiKey,
      includeSpotlight: shouldShowSpotlight,
      searchCount: searchCount,
      spotlightChannel: smartPinnedChannel,
    );
    _lastSearchResults = results;
    notifyListeners();
    return results;
  }

  Future<List<VideoItem>> searchTextAndRemember(String rawText) async {
    final query = rawText.trim().isEmpty ? 'study focus playlist' : rawText.trim();
    final mood = matchMood(query);
    await _rememberSearch(query, mood);
    final results = await searchService.searchText(
      query: query,
      mood: mood,
      apiMode: apiMode,
      apiKey: apiKey,
      includeSpotlight: shouldShowSpotlight,
      searchCount: searchCount,
      spotlightChannel: smartPinnedChannel,
    );
    _lastSearchResults = results;
    notifyListeners();
    return results;
  }

  Future<void> _rememberSearch(String query, MoodPreset mood) async {
    lastSearchText = query;
    searchCount += 1;
    _moodSearchCounts[mood.id] = (_moodSearchCounts[mood.id] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearchText', lastSearchText);
    await prefs.setInt('searchCount', searchCount);
    await prefs.setString('moodSearchCounts', jsonEncode(_moodSearchCounts));
  }

  Map<String, int> _decodeSearchCounts(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _persistSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'savedItems',
      _saved.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}

class MoodPreset {
  const MoodPreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    required this.koreanKeywords,
    required this.englishKeywords,
    required this.queries,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final String category;
  final List<String> koreanKeywords;
  final List<String> englishKeywords;
  final List<String> queries;

  List<String> get allKeywords => [...koreanKeywords, ...englishKeywords];
}

class VideoItem {
  const VideoItem({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.durationSeconds,
    required this.viewCount,
    required this.publishedText,
    required this.tags,
    required this.score,
  });

  final String videoId;
  final String title;
  final String channelTitle;
  final int durationSeconds;
  final int viewCount;
  final String publishedText;
  final List<String> tags;
  final int score;

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  String get durationText {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    return '${minutes}m';
  }

  String get viewsText {
    if (viewCount >= 1000000) return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    if (viewCount >= 1000) return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    return '$viewCount views';
  }

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'channelTitle': channelTitle,
        'durationSeconds': durationSeconds,
        'viewCount': viewCount,
        'publishedText': publishedText,
        'tags': tags,
        'score': score,
      };

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      videoId: json['videoId'] as String,
      title: json['title'] as String,
      channelTitle: json['channelTitle'] as String,
      durationSeconds: json['durationSeconds'] as int,
      viewCount: json['viewCount'] as int,
      publishedText: json['publishedText'] as String,
      tags: List<String>.from(json['tags'] as List),
      score: json['score'] as int,
    );
  }
}

const moodPresets = [
  MoodPreset(
    id: 'study_work',
    name: '공부 / 작업',
    emoji: '📚',
    category: '공부',
    description: '집중이 필요한 시간에 어울리는 플레이리스트입니다.',
    koreanKeywords: ['공부', '작업', '집중', '코딩', '업무'],
    englishKeywords: ['study', 'focus', 'work', 'coding', 'deep focus', 'no lyrics'],
    queries: ['lofi study playlist', 'deep focus music', 'coding music playlist', 'study music no lyrics'],
  ),
  MoodPreset(
    id: 'cafe_jazz',
    name: '카페 재즈',
    emoji: '☕',
    category: '카페',
    description: '카페에 앉아 있는 듯 잔잔한 플레이리스트입니다.',
    koreanKeywords: ['카페', '재즈', '브런치', '커피', '잔잔한'],
    englishKeywords: ['cafe', 'jazz', 'coffee shop', 'relaxing', 'bossa nova'],
    queries: ['cafe jazz playlist', 'coffee shop jazz music', 'relaxing cafe jazz 1 hour', 'bossa nova cafe music'],
  ),
  MoodPreset(
    id: 'rainy_night',
    name: '비 오는 밤',
    emoji: '🌧',
    category: '좋아요',
    description: '비 오는 밤에 어울리는 플레이리스트입니다.',
    koreanKeywords: ['비', '비오는', '밤', '감성', '차분한', '우울'],
    englishKeywords: ['rainy night', 'rain', 'calm', 'jazz', 'lofi', 'piano'],
    queries: ['rainy night jazz playlist', 'rainy lofi music', 'calm piano rainy night', 'coffee shop rainy jazz'],
  ),
  MoodPreset(
    id: 'workout_edm',
    name: '운동 EDM',
    emoji: '⚡',
    category: '운동',
    description: '운동 흐름을 끌어올리는 에너지 높은 플레이리스트입니다.',
    koreanKeywords: ['운동', '헬스', '러닝', '신나는', '강한'],
    englishKeywords: ['workout', 'gym', 'running', 'edm', 'phonk', 'high energy'],
    queries: ['workout edm mix', 'gym phonk playlist', 'running music mix', 'high energy workout music'],
  ),
  MoodPreset(
    id: 'drive',
    name: '드라이브',
    emoji: '🚗',
    category: '드라이브',
    description: '도로 위 기분을 살려주는 플레이리스트입니다.',
    koreanKeywords: ['드라이브', '여행', '도로', '여름'],
    englishKeywords: ['drive', 'road trip', 'city pop', 'synthwave', 'summer'],
    queries: ['city pop drive playlist', 'synthwave road trip mix', 'summer drive music', 'road trip playlist'],
  ),
  MoodPreset(
    id: 'sleep_piano',
    name: '수면 피아노',
    emoji: '🌙',
    category: '수면',
    description: '잠들기 전 편안하게 틀어두기 좋은 플레이리스트입니다.',
    koreanKeywords: ['수면', '잠', '휴식', '명상', '편안한'],
    englishKeywords: ['sleep', 'piano', 'ambient', 'healing', 'relaxing'],
    queries: ['sleep piano music', 'relaxing piano playlist', 'ambient sleep music', 'healing music for sleep'],
  ),
  MoodPreset(
    id: 'morning',
    name: '아침 시작',
    emoji: '🌤',
    category: '좋아요',
    description: '하루를 산뜻하게 열어주는 플레이리스트입니다.',
    koreanKeywords: ['아침', '시작', '산뜻한', '상쾌한'],
    englishKeywords: ['morning', 'fresh', 'acoustic', 'soft pop'],
    queries: ['morning acoustic playlist', 'fresh morning music', 'soft pop morning playlist'],
  ),
  MoodPreset(
    id: 'late_night',
    name: '감성 밤',
    emoji: '✨',
    category: '좋아요',
    description: '늦은 밤 조용히 듣기 좋은 플레이리스트입니다.',
    koreanKeywords: ['밤', '새벽', '감성', '조용한'],
    englishKeywords: ['late night', 'chill', 'lofi', 'jazz', 'ambient'],
    queries: ['late night lofi playlist', 'chill night music', 'midnight jazz playlist'],
  ),
  MoodPreset(
    id: 'chill_lofi',
    name: '칠 로파이',
    emoji: '🎧',
    category: '좋아요',
    description: '가볍게 틀어두기 좋은 로파이/칠 플레이리스트입니다.',
    koreanKeywords: ['로파이', '칠', '차분한', '집중'],
    englishKeywords: ['lofi', 'chill', 'chillhop', 'beats', 'relax'],
    queries: ['chill lofi playlist', 'lofi beats mix', 'chillhop playlist'],
  ),
  MoodPreset(
    id: 'classical_focus',
    name: '클래식 집중',
    emoji: '🎻',
    category: '공부',
    description: '집중과 독서에 어울리는 클래식 플레이리스트입니다.',
    koreanKeywords: ['클래식', '피아노', '독서', '집중'],
    englishKeywords: ['classical', 'piano', 'reading', 'focus', 'mozart'],
    queries: ['classical music for focus playlist', 'piano reading music 2 hours'],
  ),
  MoodPreset(
    id: 'kpop_pop',
    name: 'K-pop / 팝',
    emoji: '🎤',
    category: '좋아요',
    description: '가볍고 익숙한 팝 감성 플레이리스트입니다.',
    koreanKeywords: ['케이팝', '팝', '아이돌', '신나는'],
    englishKeywords: ['kpop', 'pop', 'hits', 'idol', 'upbeat'],
    queries: ['kpop playlist', 'pop hits playlist', 'upbeat pop mix'],
  ),
  MoodPreset(
    id: 'rock_energy',
    name: '록 에너지',
    emoji: '🎸',
    category: '운동',
    description: '에너지가 필요한 순간에 어울리는 록 플레이리스트입니다.',
    koreanKeywords: ['록', '메탈', '밴드', '에너지'],
    englishKeywords: ['rock', 'metal', 'band', 'energy', 'alternative'],
    queries: ['rock energy playlist', 'alternative rock mix', 'workout rock playlist'],
  ),
  MoodPreset(
    id: 'meditation_ambient',
    name: '명상 앰비언트',
    emoji: '🫧',
    category: '수면',
    description: '명상과 호흡에 어울리는 앰비언트 플레이리스트입니다.',
    koreanKeywords: ['명상', '호흡', '앰비언트', '휴식'],
    englishKeywords: ['meditation', 'ambient', 'breathing', 'calm', 'healing'],
    queries: ['ambient meditation playlist', 'breathing music mix', 'calm ambient music'],
  ),
  MoodPreset(
    id: 'gaming_focus',
    name: '게임 집중',
    emoji: '🎮',
    category: '공부',
    description: '게임이나 반복 작업에 어울리는 집중 플레이리스트입니다.',
    koreanKeywords: ['게임', '집중', '사이버', '작업'],
    englishKeywords: ['gaming', 'focus', 'cyberpunk', 'electronic', 'background'],
    queries: ['gaming focus music playlist', 'cyberpunk background music mix'],
  ),
  MoodPreset(
    id: 'cooking_bossa',
    name: '요리 보사노바',
    emoji: '🍳',
    category: '카페',
    description: '요리하거나 집안일할 때 틀기 좋은 플레이리스트입니다.',
    koreanKeywords: ['요리', '집안일', '보사노바', '카페'],
    englishKeywords: ['cooking', 'bossa nova', 'kitchen', 'brunch', 'jazz'],
    queries: ['cooking bossa nova playlist', 'kitchen jazz music mix'],
  ),
  MoodPreset(
    id: 'sad_ballad',
    name: '슬픈 발라드',
    emoji: '💧',
    category: '좋아요',
    description: '조용히 감정에 잠기고 싶을 때 어울리는 플레이리스트입니다.',
    koreanKeywords: ['슬픈', '발라드', '감성', '이별'],
    englishKeywords: ['sad', 'ballad', 'emotional', 'heartbreak', 'quiet'],
    queries: ['sad ballad playlist', 'emotional songs playlist', 'quiet heartbreak mix'],
  ),
  MoodPreset(
    id: 'nature_sound',
    name: '자연 사운드',
    emoji: '🌲',
    category: '수면',
    description: '자연 소리와 함께 쉬고 싶을 때 어울리는 플레이리스트입니다.',
    koreanKeywords: ['자연', '숲', '비', '파도', '휴식'],
    englishKeywords: ['nature', 'forest', 'rain sounds', 'ocean', 'relaxing'],
    queries: ['nature sounds playlist', 'forest rain sounds 3 hours', 'ocean waves sleep music'],
  ),
  MoodPreset(
    id: 'party_dance',
    name: '파티 댄스',
    emoji: '🪩',
    category: '운동',
    description: '기분을 올리고 싶을 때 어울리는 댄스 플레이리스트입니다.',
    koreanKeywords: ['파티', '댄스', '신나는', '클럽'],
    englishKeywords: ['party', 'dance', 'club', 'edm', 'upbeat'],
    queries: ['party dance playlist', 'club music mix', 'upbeat dance hits'],
  ),
  MoodPreset(
    id: 'acoustic_folk',
    name: '어쿠스틱 포크',
    emoji: '🪕',
    category: '좋아요',
    description: '편안한 어쿠스틱/포크 감성 플레이리스트입니다.',
    koreanKeywords: ['어쿠스틱', '포크', '잔잔한', '기타'],
    englishKeywords: ['acoustic', 'folk', 'guitar', 'cozy', 'soft'],
    queries: ['acoustic folk playlist', 'cozy guitar music mix'],
  ),
  MoodPreset(
    id: 'film_score',
    name: '영화 OST',
    emoji: '🎬',
    category: '공부',
    description: '몰입감을 주는 영화 음악 플레이리스트입니다.',
    koreanKeywords: ['영화', 'OST', '사운드트랙', '몰입'],
    englishKeywords: ['film score', 'soundtrack', 'cinematic', 'epic', 'orchestral'],
    queries: ['film score playlist', 'cinematic soundtrack mix', 'epic orchestral music'],
  ),
];

MoodPreset matchMood(String input) {
  final normalized = input.toLowerCase();
  var best = moodPresets.first;
  var bestScore = -1;
  for (final mood in moodPresets) {
    var score = 0;
    for (final keyword in mood.allKeywords) {
      final normalizedKeyword = keyword.toLowerCase();
      if (normalized.contains(normalizedKeyword)) score += normalizedKeyword.length > 3 ? 2 : 1;
    }
    for (final query in mood.queries) {
      for (final token in query.toLowerCase().split(RegExp(r'\s+'))) {
        if (token.length > 2 && normalized.contains(token)) score += 1;
      }
    }
    if (score > bestScore) {
      bestScore = score;
      best = mood;
    }
  }
  return best;
}

class YouTubeSearchService {
  Future<List<VideoItem>> searchMood({
    required MoodPreset mood,
    required bool apiMode,
    required String apiKey,
    bool includeSpotlight = false,
    int searchCount = 0,
    String spotlightChannel = 'Scapetune',
  }) {
    return searchText(
      query: mood.queries.first,
      mood: mood,
      apiMode: apiMode,
      apiKey: apiKey,
      includeSpotlight: includeSpotlight,
      searchCount: searchCount,
      spotlightChannel: spotlightChannel,
    );
  }

  Future<List<VideoItem>> searchText({
    required String query,
    required MoodPreset mood,
    required bool apiMode,
    required String apiKey,
    bool includeSpotlight = false,
    int searchCount = 0,
    String spotlightChannel = 'Scapetune',
  }) async {
    if (apiMode && apiKey.isNotEmpty) {
      try {
        final results = await _searchApiQuery(
          query: '$query long playlist music',
          apiKey: apiKey,
          mood: mood,
          sourceQuery: query,
        );
        if (includeSpotlight) {
          final scapetuneChannelId = await _resolveChannelId(apiKey, scapetuneChannelHandle);
          final spotlight = await _searchApiQuery(
            query: '$query playlist music',
            apiKey: apiKey,
            mood: mood,
            sourceQuery: query,
            preferredChannel: spotlightChannel,
            channelId: scapetuneChannelId,
            maxResults: 5,
          );
          final fallbackSpotlight = spotlight.isEmpty ? [spotlightVideoForQuery(query, mood, spotlightChannel: spotlightChannel)] : <VideoItem>[];
          return _mergeResults([...results, ...spotlight, ...fallbackSpotlight])..sort((a, b) => b.score.compareTo(a.score));
        }
        return results;
      } catch (_) {
        return offlineResultsForQuery(
          query,
          mood: mood,
          includeSpotlight: includeSpotlight,
          searchCount: searchCount,
          spotlightChannel: spotlightChannel,
        );
      }
    }
    return offlineResultsForQuery(
      query,
      mood: mood,
      includeSpotlight: includeSpotlight,
      searchCount: searchCount,
      spotlightChannel: spotlightChannel,
    );
  }

  List<VideoItem> offlineResultsForQuery(
    String query, {
    MoodPreset? mood,
    bool includeSpotlight = false,
    int searchCount = 0,
    String spotlightChannel = 'Scapetune',
  }) {
    final matchedMood = mood ?? matchMood(query);
    final moodVideoIds = (mockCatalog[matchedMood.id] ?? const <VideoItem>[]).map((item) => item.videoId).toSet();
    final allItems = _mergeResults(mockCatalog.values.expand((items) => items).toList());
    final scored = allItems.map((item) {
      final baseScore = scoreVideo(
        title: item.title,
        durationSeconds: item.durationSeconds,
        viewCount: item.viewCount,
        mood: matchedMood,
      );
      final queryScore = _queryScore(item, query) + _queryScore(item, matchedMood.queries.first);
      final moodBoost = moodVideoIds.contains(item.videoId) ? 180 : 0;
      return item.copyWith(
        tags: {...item.tags, matchedMood.category}.toList(),
        score: baseScore + queryScore + moodBoost,
      );
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (includeSpotlight) {
      final spotlight = spotlightVideoForQuery(query, matchedMood, spotlightChannel: spotlightChannel);
      scored.insert(min(searchCount % 3, scored.length), spotlight);
    }
    return _mergeResults(scored).take(12).toList();
  }

  Future<String?> _resolveChannelId(String apiKey, String handle) async {
    final normalizedHandle = handle.startsWith('@') ? handle : '@$handle';
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/channels', {
      'part': 'id',
      'forHandle': normalizedHandle,
      'key': apiKey,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(body['items'] as List? ?? const []);
    if (items.isEmpty) return null;
    return items.first['id'] as String?;
  }

  Future<List<VideoItem>> _searchApiQuery({
    required String query,
    required String apiKey,
    required MoodPreset mood,
    required String sourceQuery,
    String? preferredChannel,
    String? channelId,
    int maxResults = 15,
  }) async {
    final params = <String, String>{
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'videoEmbeddable': 'true',
      'maxResults': '$maxResults',
      'key': apiKey,
      if (channelId != null && channelId.isNotEmpty) 'channelId': channelId,
    };
    final searchUri = Uri.https('www.googleapis.com', '/youtube/v3/search', params);
    final searchResponse = await http.get(searchUri);
    if (searchResponse.statusCode != 200) throw Exception('YouTube search failed');
    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(searchJson['items'] as List);
    final ids = items.map((item) => item['id']['videoId'] as String).join(',');
    if (ids.isEmpty) return [];

    final videosUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'snippet,contentDetails,statistics',
      'id': ids,
      'key': apiKey,
    });
    final videosResponse = await http.get(videosUri);
    if (videosResponse.statusCode != 200) throw Exception('YouTube videos failed');
    final videosJson = jsonDecode(videosResponse.body) as Map<String, dynamic>;
    final videos = List<Map<String, dynamic>>.from(videosJson['items'] as List);

    final mapped = videos.map((video) {
      final snippet = video['snippet'] as Map<String, dynamic>;
      final stats = video['statistics'] as Map<String, dynamic>;
      final details = video['contentDetails'] as Map<String, dynamic>;
      final duration = _parseIsoDuration(details['duration'] as String);
      final views = int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0;
      final title = snippet['title'] as String;
      final channelTitle = snippet['channelTitle'] as String;
      final preferredBoost = preferredChannel != null && channelTitle.toLowerCase().contains(preferredChannel.toLowerCase()) ? 120 : 0;
      return VideoItem(
        videoId: video['id'] as String,
        title: title,
        channelTitle: channelTitle,
        durationSeconds: duration,
        viewCount: views,
        publishedText: _publishedLabel(snippet['publishedAt'] as String),
        tags: mood.koreanKeywords.take(2).toList(),
        score: scoreVideo(title: title, durationSeconds: duration, viewCount: views, mood: mood) + _queryScoreTitle(title, sourceQuery) + preferredBoost,
      );
    }).where((item) => item.durationSeconds >= 300 && item.score > -10).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return mapped;
  }

  List<VideoItem> _mergeResults(List<VideoItem> items) {
    final seen = <String>{};
    final merged = <VideoItem>[];
    for (final item in items) {
      if (seen.add(item.videoId)) merged.add(item);
    }
    return merged;
  }

  int _queryScore(VideoItem item, String query) => _queryScoreTitle('${item.title} ${item.channelTitle} ${item.tags.join(' ')}', query);

  int _queryScoreTitle(String title, String query) {
    final lowerTitle = title.toLowerCase();
    var score = 0;
    for (final token in query.toLowerCase().split(RegExp(r'[^a-z0-9가-힣]+'))) {
      if (token.length < 2) continue;
      if (lowerTitle.contains(token)) score += token.length > 3 ? 14 : 7;
    }
    return score;
  }

  int _parseIsoDuration(String value) {
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(value);
    if (match == null) return 0;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    return hours * 3600 + minutes * 60 + seconds;
  }

  String _publishedLabel(String publishedAt) {
    final date = DateTime.tryParse(publishedAt);
    if (date == null) return '업로드일 정보 없음';
    final years = max(0, DateTime.now().difference(date).inDays ~/ 365);
    if (years > 0) return '$years년 전';
    final months = max(1, DateTime.now().difference(date).inDays ~/ 30);
    return '$months개월 전';
  }
}

int scoreVideo({
  required String title,
  required int durationSeconds,
  required int viewCount,
  required MoodPreset mood,
}) {
  final lowerTitle = title.toLowerCase();
  var score = 0;
  if (lowerTitle.contains('playlist')) score += 20;
  if (lowerTitle.contains('mix')) score += 15;
  if (lowerTitle.contains('1 hour') || lowerTitle.contains('2 hours') || lowerTitle.contains('3 hours')) score += 20;
  if (durationSeconds >= 1800) score += 25;
  if (durationSeconds >= 3600) score += 35;
  for (final keyword in mood.englishKeywords) {
    if (lowerTitle.contains(keyword.toLowerCase())) score += 10;
  }
  if (viewCount >= 10000000) {
    score += 15;
  } else if (viewCount >= 1000000) {
    score += 10;
  } else if (viewCount >= 100000) {
    score += 5;
  }
  if (durationSeconds < 300) score -= 40;
  if (lowerTitle.contains('shorts')) score -= 50;
  if (lowerTitle.contains('official music video')) score -= 20;
  return score;
}

extension on VideoItem {
  VideoItem copyWith({int? score, List<String>? tags}) {
    return VideoItem(
      videoId: videoId,
      title: title,
      channelTitle: channelTitle,
      durationSeconds: durationSeconds,
      viewCount: viewCount,
      publishedText: publishedText,
      tags: tags ?? this.tags,
      score: score ?? this.score,
    );
  }
}

final mockCatalog = <String, List<VideoItem>>{
  'study_work': [
    mockVideo('jfKfPfyJRdk', 'lofi study playlist - beats to focus for 2 hours', 'Lofi Girl', 7200, 18400000, '1년 전', ['공부', '집중']),
    mockVideo('lTRiuFIWV54', 'Deep Focus Music for Coding and Work - 3 Hours', 'Focus Flow', 10800, 2450000, '8개월 전', ['작업', '코딩']),
    mockVideo('Dx5qFachd3A', 'study music no lyrics playlist 1 hour', 'Quiet Desk', 3600, 820000, '2년 전', ['공부']),
  ],
  'cafe_jazz': [
    mockVideo('neV3EPgvZ3g', 'coffee shop jazz music playlist - relaxing cafe 3 hours', 'Cafe Sounds', 10800, 9100000, '10개월 전', ['카페', '재즈']),
    mockVideo('HMnrl0tmd3k', 'bossa nova cafe music mix for brunch', 'Jazz Table', 5400, 1900000, '1년 전', ['브런치']),
    mockVideo('w9COHCrwNQs', 'relaxing cafe jazz 1 hour', 'Warm Cup', 3600, 420000, '6개월 전', ['카페']),
  ],
  'rainy_night': [
    mockVideo('DSGyEsJ17cI', 'rainy night jazz playlist - calm coffee shop rain', 'Rain Notes', 7200, 3200000, '1년 전', ['비', '밤']),
    mockVideo('kgx4WGK0oNU', 'rainy lofi music mix for late night', 'Window Lofi', 5400, 1300000, '7개월 전', ['감성']),
    mockVideo('UfcAVejslrU', 'calm piano rainy night 2 hours', 'Soft Piano Room', 7200, 710000, '2년 전', ['피아노']),
  ],
  'workout_edm': [
    mockVideo('GfQ3tQEU0hg', 'workout edm mix - high energy gym playlist 2 hours', 'Move Lab', 7200, 6100000, '5개월 전', ['운동', 'EDM']),
    mockVideo('qM5K3p8e4xA', 'gym phonk playlist for running', 'Pulse Drive', 4800, 2700000, '1년 전', ['헬스']),
    mockVideo('wKduBhZPwU8', 'high energy workout music mix', 'Cardio Club', 3900, 980000, '9개월 전', ['러닝']),
  ],
  'drive': [
    mockVideo('qM4DXtfjyek', 'city pop drive playlist - summer road trip mix', 'Road Radio', 7200, 4200000, '1년 전', ['드라이브']),
    mockVideo('MV_3Dpw-BRY', 'synthwave road trip mix 2 hours', 'Night Highway', 7200, 3500000, '2년 전', ['여행']),
    mockVideo('Yw9kKQdJ4Cc', 'summer drive music playlist', 'Open Window', 5400, 860000, '4개월 전', ['여름']),
  ],
  'sleep_piano': [
    mockVideo('1ZYbU82GVz4', 'sleep piano music playlist - relaxing piano 3 hours', 'Rest Keys', 10800, 7600000, '2년 전', ['수면', '피아노']),
    mockVideo('bP9gMpl1gyQ', 'ambient sleep music mix for deep rest', 'Night Calm', 7200, 2100000, '1년 전', ['휴식']),
    mockVideo('N2i0B0xK_8E', 'healing music for sleep 1 hour', 'Slow Room', 3600, 450000, '8개월 전', ['명상']),
  ],
  'morning': [
    mockVideo('lFcSrYw-ARY', 'morning acoustic playlist - fresh start music', 'Morning Table', 5400, 1250000, '1년 전', ['아침']),
    mockVideo('g0fwuAT5WL0', 'soft pop morning playlist 1 hour', 'Daily Light', 3600, 690000, '7개월 전', ['상쾌한']),
    mockVideo('x0i1ah-lgpI', 'fresh morning music mix', 'Sunny Notes', 4200, 980000, '9개월 전', ['시작']),
  ],
  'late_night': [
    mockVideo('5qap5aO4i9A', 'late night lofi playlist - chill night music', 'Quiet Hours', 7200, 12800000, '2년 전', ['밤', '감성']),
    mockVideo('DWcJFNfaw9c', 'midnight jazz playlist 2 hours', 'After Dark Jazz', 7200, 2400000, '1년 전', ['새벽']),
    mockVideo('7NOSDKb0HlU', 'chill ambient music mix for late night', 'Dim Light', 5400, 800000, '6개월 전', ['조용한']),
  ],
  'chill_lofi': [
    mockVideo('jfKfPfyJRdk', 'chill lofi playlist for calm afternoons', 'Lofi Girl', 7200, 18400000, '1년 전', ['로파이', '칠']),
    mockVideo('5qap5aO4i9A', 'lofi beats mix for soft focus', 'Quiet Hours', 7200, 12800000, '2년 전', ['로파이']),
    mockVideo('kgx4WGK0oNU', 'chillhop rainy room mix', 'Window Lofi', 5400, 1300000, '7개월 전', ['칠']),
  ],
  'classical_focus': [
    mockVideo('1ZYbU82GVz4', 'classical piano music for reading and focus 3 hours', 'Rest Keys', 10800, 7600000, '2년 전', ['클래식', '집중']),
    mockVideo('UfcAVejslrU', 'calm piano classical focus playlist 2 hours', 'Soft Piano Room', 7200, 710000, '2년 전', ['피아노']),
    mockVideo('N2i0B0xK_8E', 'mozart study music playlist 1 hour', 'Slow Room', 3600, 450000, '8개월 전', ['클래식']),
  ],
  'kpop_pop': [
    mockVideo('g0fwuAT5WL0', 'upbeat k-pop and pop hits playlist 1 hour', 'Daily Light', 3600, 690000, '7개월 전', ['케이팝', '팝']),
    mockVideo('x0i1ah-lgpI', 'fresh pop music mix for morning', 'Sunny Notes', 4200, 980000, '9개월 전', ['팝']),
    mockVideo('lFcSrYw-ARY', 'soft pop morning playlist', 'Morning Table', 5400, 1250000, '1년 전', ['팝']),
  ],
  'rock_energy': [
    mockVideo('GfQ3tQEU0hg', 'rock energy workout playlist 2 hours', 'Move Lab', 7200, 6100000, '5개월 전', ['록', '운동']),
    mockVideo('qM5K3p8e4xA', 'alternative rock mix for running', 'Pulse Drive', 4800, 2700000, '1년 전', ['록']),
    mockVideo('wKduBhZPwU8', 'high energy band music mix', 'Cardio Club', 3900, 980000, '9개월 전', ['메탈']),
  ],
  'meditation_ambient': [
    mockVideo('bP9gMpl1gyQ', 'ambient meditation music mix for deep rest', 'Night Calm', 7200, 2100000, '1년 전', ['명상', '휴식']),
    mockVideo('N2i0B0xK_8E', 'healing ambient music for breathing 1 hour', 'Slow Room', 3600, 450000, '8개월 전', ['명상']),
    mockVideo('1ZYbU82GVz4', 'soft ambient piano sleep playlist 3 hours', 'Rest Keys', 10800, 7600000, '2년 전', ['앰비언트']),
  ],
  'gaming_focus': [
    mockVideo('lTRiuFIWV54', 'gaming focus music for coding and grinding 3 hours', 'Focus Flow', 10800, 2450000, '8개월 전', ['게임', '집중']),
    mockVideo('MV_3Dpw-BRY', 'cyberpunk gaming background mix 2 hours', 'Night Highway', 7200, 3500000, '2년 전', ['게임']),
    mockVideo('Yw9kKQdJ4Cc', 'electronic focus playlist for gaming', 'Open Window', 5400, 860000, '4개월 전', ['집중']),
  ],
  'cooking_bossa': [
    mockVideo('HMnrl0tmd3k', 'bossa nova cooking playlist for brunch', 'Jazz Table', 5400, 1900000, '1년 전', ['요리', '보사노바']),
    mockVideo('neV3EPgvZ3g', 'coffee shop jazz kitchen playlist 3 hours', 'Cafe Sounds', 10800, 9100000, '10개월 전', ['카페']),
    mockVideo('w9COHCrwNQs', 'relaxing bossa nova for home cooking 1 hour', 'Warm Cup', 3600, 420000, '6개월 전', ['보사노바']),
  ],
  'sad_ballad': [
    mockVideo('DWcJFNfaw9c', 'sad ballad playlist for late night', 'After Dark Jazz', 7200, 2400000, '1년 전', ['슬픈', '발라드']),
    mockVideo('7NOSDKb0HlU', 'emotional quiet songs mix', 'Dim Light', 5400, 800000, '6개월 전', ['감성']),
    mockVideo('UfcAVejslrU', 'calm piano heartbreak playlist 2 hours', 'Soft Piano Room', 7200, 710000, '2년 전', ['피아노']),
  ],
  'nature_sound': [
    mockVideo('DSGyEsJ17cI', 'forest rain sounds playlist for sleep', 'Rain Notes', 7200, 3200000, '1년 전', ['자연', '비']),
    mockVideo('1ZYbU82GVz4', 'ocean waves and soft piano 3 hours', 'Rest Keys', 10800, 7600000, '2년 전', ['자연']),
    mockVideo('bP9gMpl1gyQ', 'nature ambient music mix for deep rest', 'Night Calm', 7200, 2100000, '1년 전', ['숲']),
  ],
  'party_dance': [
    mockVideo('GfQ3tQEU0hg', 'party dance playlist high energy 2 hours', 'Move Lab', 7200, 6100000, '5개월 전', ['파티', '댄스']),
    mockVideo('qM5K3p8e4xA', 'club edm mix for dancing', 'Pulse Drive', 4800, 2700000, '1년 전', ['댄스']),
    mockVideo('wKduBhZPwU8', 'upbeat dance music mix', 'Cardio Club', 3900, 980000, '9개월 전', ['운동']),
  ],
  'acoustic_folk': [
    mockVideo('lFcSrYw-ARY', 'cozy acoustic folk playlist', 'Morning Table', 5400, 1250000, '1년 전', ['어쿠스틱']),
    mockVideo('g0fwuAT5WL0', 'soft guitar morning playlist 1 hour', 'Daily Light', 3600, 690000, '7개월 전', ['기타']),
    mockVideo('x0i1ah-lgpI', 'fresh acoustic music mix', 'Sunny Notes', 4200, 980000, '9개월 전', ['포크']),
  ],
  'film_score': [
    mockVideo('MV_3Dpw-BRY', 'cinematic soundtrack playlist 2 hours', 'Night Highway', 7200, 3500000, '2년 전', ['영화', 'OST']),
    mockVideo('lTRiuFIWV54', 'epic orchestral music for deep work 3 hours', 'Focus Flow', 10800, 2450000, '8개월 전', ['몰입']),
    mockVideo('Yw9kKQdJ4Cc', 'film score study mix', 'Open Window', 5400, 860000, '4개월 전', ['사운드트랙']),
  ],
};

List<VideoItem> buildSmartRecommendations(
  List<VideoItem> candidates, {
  required String lastSearchText,
  required int searchCount,
  String spotlightChannel = 'Scapetune',
}) {
  final fallbackMood = lastSearchText.isEmpty ? moodPresets.first : matchMood(lastSearchText);
  final pool = candidates.isEmpty
      ? YouTubeSearchService().offlineResultsForQuery(lastSearchText.isEmpty ? fallbackMood.queries.first : lastSearchText, mood: fallbackMood)
      : candidates;
  final unique = <String, VideoItem>{};
  for (final item in pool) {
    unique[item.videoId] = item;
  }

  final normalizedSpotlight = spotlightChannel.trim().toLowerCase();
  final showSpotlight = searchCount > 0;
  final topByViews = unique.values
      .where((item) => normalizedSpotlight.isEmpty || !item.channelTitle.toLowerCase().contains(normalizedSpotlight))
      .toList()
    ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

  final result = topByViews.take(showSpotlight ? 2 : 3).toList();
  if (showSpotlight) {
    final spotlight = unique.values.cast<VideoItem?>().firstWhere(
          (item) => item != null && item.channelTitle.toLowerCase().contains(normalizedSpotlight),
          orElse: () => null,
        ) ??
        spotlightVideoForQuery(lastSearchText, fallbackMood, spotlightChannel: spotlightChannel);
    result.removeWhere((item) => item.videoId == spotlight.videoId);
    while (result.length < 2) {
      final next = topByViews.firstWhere(
        (item) => item.videoId != spotlight.videoId && !result.any((selected) => selected.videoId == item.videoId),
        orElse: () => spotlight,
      );
      if (next.videoId == spotlight.videoId) break;
      result.add(next);
    }
    result.insert(min(searchCount % 3, result.length), spotlight);
  }
  return result.take(3).toList(growable: false);
}

VideoItem spotlightVideoForQuery(String query, MoodPreset mood, {String spotlightChannel = 'Scapetune'}) {
  final seed = query.isEmpty ? mood.id : query;
  final index = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % _scapetuneSpotlights.length;
  final item = _scapetuneSpotlights[index];
  return item.copyWith(
    tags: {...item.tags, spotlightChannel, mood.category}.toList(),
    score: scoreVideo(title: item.title, durationSeconds: item.durationSeconds, viewCount: item.viewCount, mood: mood) + 30,
  );
}

final _scapetuneSpotlights = [
  mockVideo('jfKfPfyJRdk', 'Scapetune mood playlist - soft focus session', 'Scapetune', 7200, 920000, '3개월 전', ['Scapetune', '집중']),
  mockVideo('5qap5aO4i9A', 'Scapetune late night playlist - calm room mix', 'Scapetune', 7200, 760000, '5개월 전', ['Scapetune', '밤']),
  mockVideo('DSGyEsJ17cI', 'Scapetune rainy cafe playlist', 'Scapetune', 5400, 610000, '2개월 전', ['Scapetune', '카페']),
];

VideoItem mockVideo(
  String videoId,
  String title,
  String channelTitle,
  int durationSeconds,
  int viewCount,
  String publishedText,
  List<String> tags,
) {
  return VideoItem(
    videoId: videoId,
    title: title,
    channelTitle: channelTitle,
    durationSeconds: durationSeconds,
    viewCount: viewCount,
    publishedText: publishedText,
    tags: tags,
    score: 0,
  );
}

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
      const HomeScreen(),
      const ExploreScreen(),
      const LibraryScreen(),
      const SettingsScreen(),
    ];
    final playing = context.watch<MoodTubeState>().currentPlaying;
    _syncMiniController(playing);
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(child: screens[index]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playing != null && miniController != null) MiniPlayer(item: playing, controller: miniController!),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xf4f7f9fc),
              border: Border(top: BorderSide(color: DesignTokens.line)),
              boxShadow: [BoxShadow(color: Color(0x17101828), blurRadius: 24, offset: Offset(0, -10))],
            ),
            child: NavigationBar(
              height: 68,
              selectedIndex: index,
              onDestinationSelected: (value) => setState(() => index = value),
              destinations: [
                NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: text.home),
                NavigationDestination(icon: const Icon(Icons.search_outlined), selectedIcon: const Icon(Icons.search), label: text.explore),
                NavigationDestination(icon: const Icon(Icons.bookmarks_outlined), selectedIcon: const Icon(Icons.bookmarks), label: text.library),
                NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: text.settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _syncMiniController(VideoItem? item) {
    if (item == null) return;
    if (miniVideoId == item.videoId) return;
    miniController?.dispose();
    miniVideoId = item.videoId;
    miniController = YoutubePlayerController(
      initialVideoId: item.videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, controlsVisibleAtStart: true, enableCaption: false),
    );
  }

  @override
  void dispose() {
    miniController?.dispose();
    super.dispose();
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.item, required this.controller});

  final VideoItem item;
  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    final state = context.read<MoodTubeState>();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: const BoxDecoration(color: Color(0xf8f7f9fc), border: Border(top: BorderSide(color: DesignTokens.line))),
      child: Row(
        children: [
          SizedBox(
            width: 124,
            height: 70,
            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: YoutubePlayer(controller: controller)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
          ),
          IconButton(onPressed: state.clearCurrentPlaying, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key, required this.title, required this.subtitle, required this.accent, this.trailing});

  final String title;
  final String subtitle;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: softPanelDecoration(color: const Color(0xf7f9fbff)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusDot(color: accent),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 34, height: 0.98, fontWeight: FontWeight.w900, letterSpacing: 0, color: DesignTokens.ink)),
                const SizedBox(height: 8),
                Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, height: 1.35, fontWeight: FontWeight.w700, color: DesignTokens.sage)),
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

class SoftDial extends StatelessWidget {
  const SoftDial({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: const Color(0xfff5f7fb),
        shape: BoxShape.circle,
        border: Border.all(color: DesignTokens.line, width: 1.4),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(color: DesignTokens.sage, borderRadius: BorderRadius.circular(8)),
        ),
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
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.42), blurRadius: 12, spreadRadius: 1)],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool didRefreshAtEnd = false;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final featured = state.smartRecommendations;
    final homeMoods = state.homeMoodPresets;
    return SoftPage(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 16) {
            if (!didRefreshAtEnd) {
              didRefreshAtEnd = true;
              context.read<MoodTubeState>().refreshHomeMoods();
            }
          } else {
            didRefreshAtEnd = false;
          }
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          PremiumHeader(
            title: 'MoodTube',
            subtitle: text.homePrompt,
            accent: DesignTokens.peach,
            trailing: const SoftDial(),
          ),
          const SizedBox(height: 26),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeMoods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.48,
            ),
            itemBuilder: (context, index) => MoodCard(mood: homeMoods[index]),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Text(text.smartRecommendations, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: DesignTokens.ink))),
              if (state.lastSearchText.isNotEmpty)
                Flexible(
                  child: Text(
                    state.lastSearchText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: DesignTokens.sage),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...featured.map((item) => CompactVideoRow(item: item)),
        ],
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
          colors: [accent.withValues(alpha: 0.92), DesignTokens.violet.withValues(alpha: 0.78)],
        ),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.34), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Icon(_iconForMood(moodId), color: Colors.white, size: 19),
    );
  }

  IconData _iconForMood(String id) {
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
      _ => Icons.graphic_eq_rounded,
    };
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
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: softPanelDecoration(color: DesignTokens.panel, shadow: DesignTokens.cardShadow),
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
                  color: const Color(0xfff1f4f8),
                  borderRadius: BorderRadius.circular(8),
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
                  Container(width: 34, height: 4, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 9),
                  Text(
                    text.moodName(mood.id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, height: 1.12, fontWeight: FontWeight.w900, color: DesignTokens.ink),
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
          PremiumHeader(title: text.explore, subtitle: text.smartMoodMatching, accent: DesignTokens.cobalt),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: softPanelDecoration(color: DesignTokens.panel),
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _search(context),
            icon: const Icon(Icons.travel_explore),
            label: Text(text.findRecommendations),
          ),
          const SizedBox(height: 24),
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
        ],
      ),
    );
  }

  void _search(BuildContext context) {
    final languageCode = context.read<MoodTubeState>().effectiveLanguageCode(Localizations.localeOf(context));
    final fallback = AppText(languageCode).emptySearchFallback;
    final query = controller.text.trim().isEmpty ? fallback : controller.text.trim();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultsScreen(mood: matchMood(query), sourceText: query)));
  }
}

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
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: Text(widget.sourceText == null || widget.sourceText!.isEmpty ? text.moodName(widget.mood.id) : widget.sourceText!)),
      body: SoftPage(
        child: FutureBuilder<List<VideoItem>>(
          future: resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}', style: const TextStyle(color: DesignTokens.sage, fontWeight: FontWeight.w700)));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final results = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
              children: [
                Text(text.moodDescription(widget.mood.id), style: const TextStyle(fontSize: 17, height: 1.35, fontWeight: FontWeight.w800, color: DesignTokens.ink)),
                if (widget.sourceText != null && widget.sourceText!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${text.sourceMoodPrefix}: ${widget.sourceText}', style: const TextStyle(color: DesignTokens.sage)),
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
      color: DesignTokens.panelAlt,
      alignment: Alignment.center,
      child: const Icon(Icons.play_circle_fill_rounded, color: DesignTokens.cobalt, size: 34),
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
                child: Image.network(item.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ThumbnailFallback()),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const StatusDot(color: DesignTokens.peach),
                const SizedBox(width: 8),
                Text('Score ${item.score}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: DesignTokens.sage)),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, height: 1.22, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
            const SizedBox(height: 6),
            Text(
              '${item.channelTitle} · ${text.duration(item.durationSeconds)} · ${text.views(item.viewCount)} · ${text.published(item.publishedText)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.3, color: DesignTokens.muted),
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
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_add_outlined),
                    label: Text(saved ? text.saved : text.save),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.read<MoodTubeState>().setCurrentPlaying(item);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(item: item)));
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

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.item});

  final VideoItem item;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MoodTubeState>().setCurrentPlaying(widget.item);
    });
    controller = YoutubePlayerController(
      initialVideoId: widget.item.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        controlsVisibleAtStart: true,
        enableCaption: false,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.play());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    final saved = state.isSaved(widget.item.videoId);
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final player = YoutubePlayer(controller: controller);
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
      body: SoftPage(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: softPanelDecoration(color: DesignTokens.panelAlt),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: YoutubePlayerBuilder(
                  player: player,
                  builder: (context, player) => player,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.item.title, style: const TextStyle(fontSize: 22, height: 1.18, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
            const SizedBox(height: 8),
            Text(widget.item.channelTitle, style: const TextStyle(fontSize: 14, color: DesignTokens.sage, fontWeight: FontWeight.w700)),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: () => state.toggleSaved(widget.item),
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_add_outlined),
              label: Text(saved ? text.saved : text.savePlaylist),
            ),
            OutlinedButton.icon(
              onPressed: () {
                final mood = matchMood(widget.item.tags.join(' '));
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood)));
              },
              icon: const Icon(Icons.queue_music),
              label: Text(text.similarPlaylists),
            ),
            FilledButton.icon(
              onPressed: () => launchUrl(Uri.parse(widget.item.youtubeUrl), mode: LaunchMode.inAppBrowserView),
              icon: const Icon(Icons.open_in_new),
              label: Text(text.openInYouTube),
            ),
          ],
        ),
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
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

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
          PremiumHeader(title: text.library, subtitle: text.librarySubtitle, accent: DesignTokens.violet),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(child: Text(text.noSavedItems, style: const TextStyle(color: DesignTokens.sage, fontWeight: FontWeight.w700))),
            )
          else
            ...filtered.map((item) => CompactVideoRow(item: item, showDelete: true)),
        ],
      ),
    );
  }
}

class CompactVideoRow extends StatelessWidget {
  const CompactVideoRow({super.key, required this.item, this.showDelete = false});

  final VideoItem item;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: DesignTokens.panel,
      child: ListTile(
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(item.thumbnailUrl, width: 92, height: 58, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ThumbnailFallback()),
        ),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, height: 1.2, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${text.duration(item.durationSeconds)} · ${text.views(item.viewCount)}', style: const TextStyle(fontSize: 12.5, color: DesignTokens.muted, fontWeight: FontWeight.w600)),
        ),
        trailing: showDelete
            ? IconButton(
                onPressed: () => context.read<MoodTubeState>().toggleSaved(item),
                icon: const Icon(Icons.delete_outline),
              )
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(item: item))),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController apiKeyController;
  late final TextEditingController smartPinnedChannelController;

  @override
  void initState() {
    super.initState();
    final state = context.read<MoodTubeState>();
    apiKeyController = TextEditingController(text: state.apiKey);
    smartPinnedChannelController = TextEditingController(text: state.smartPinnedChannel);
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    smartPinnedChannelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    return SoftPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          PremiumHeader(title: text.settings, subtitle: text.settingsSubtitle, accent: DesignTokens.graphite),
          const SizedBox(height: 18),
          SettingsBlock(
            title: text.appDescriptionTitle,
            body: text.appDescriptionBody,
          ),
          SettingsBlock(
            title: text.policyTitle,
            body: text.policyBody,
          ),
          SettingFieldShell(
            label: text.language,
            helper: text.languageHelp,
            child: DropdownButtonFormField<String>(
              key: ValueKey(state.languageCode),
              initialValue: state.languageCode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: DesignTokens.ink),
              dropdownColor: DesignTokens.cream,
              items: languageOptions
                  .map((option) => DropdownMenuItem(
                        value: option.code,
                        child: Text(option.label(text)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) state.setLanguageCode(value);
              },
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: softPanelDecoration(color: DesignTokens.panelAlt),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(text.apiMode, style: const TextStyle(fontWeight: FontWeight.w900, color: DesignTokens.ink)),
              subtitle: Text(text.apiModeHelp, style: const TextStyle(color: DesignTokens.muted)),
              value: state.apiMode,
              onChanged: state.setApiMode,
            ),
          ),
          const SizedBox(height: 18),
          SettingFieldShell(
            label: text.apiKey,
            helper: text.apiKeyHelp,
            child: TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DesignTokens.ink),
              obscureText: true,
              onChanged: state.setApiKey,
            ),
          ),
          const SizedBox(height: 18),
          SettingFieldShell(
            label: text.smartPinnedChannel,
            helper: text.smartPinnedChannelHelp,
            child: TextField(
              controller: smartPinnedChannelController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: DesignTokens.ink),
              onChanged: state.setSmartPinnedChannel,
            ),
          ),
          const SizedBox(height: 18),
          Text(text.appVersion, style: const TextStyle(color: DesignTokens.sage, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class SettingFieldShell extends StatelessWidget {
  const SettingFieldShell({
    super.key,
    required this.label,
    required this.helper,
    required this.child,
  });

  final String label;
  final String helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: softPanelDecoration(color: DesignTokens.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, height: 1.1, fontWeight: FontWeight.w900, color: DesignTokens.sage)),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
          const SizedBox(height: 8),
          Text(helper, style: const TextStyle(fontSize: 12, height: 1.35, fontWeight: FontWeight.w600, color: DesignTokens.muted)),
        ],
      ),
    );
  }
}

class SettingsBlock extends StatelessWidget {
  const SettingsBlock({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: softPanelDecoration(color: DesignTokens.panelAlt),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600, color: DesignTokens.muted)),
        ],
      ),
    );
  }
}
