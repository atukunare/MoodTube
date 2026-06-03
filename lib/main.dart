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
  static const background = Color(0xffc7d8d1);
  static const backgroundDeep = Color(0xff8fa79f);
  static const panel = Color(0xeef3f1e8);
  static const panelAlt = Color(0xdde2eee7);
  static const mint = Color(0xff9fc8bd);
  static const sage = Color(0xff5f7771);
  static const ink = Color(0xff24302d);
  static const muted = Color(0xff6b7771);
  static const peach = Color(0xffefa45c);
  static const cream = Color(0xfffff6e6);
  static const line = Color(0x99ffffff);
  static const darkLine = Color(0x2624302d);

  static List<BoxShadow> get softShadow => const [
        BoxShadow(color: Color(0x2f1f2a27), blurRadius: 24, offset: Offset(0, 16)),
        BoxShadow(color: Color(0x99ffffff), blurRadius: 14, offset: Offset(-6, -6)),
      ];

  static List<BoxShadow> get smallShadow => const [
        BoxShadow(color: Color(0x241f2a27), blurRadius: 14, offset: Offset(0, 8)),
        BoxShadow(color: Color(0x88ffffff), blurRadius: 9, offset: Offset(-4, -4)),
      ];
}

BoxDecoration softPanelDecoration({Color color = DesignTokens.panel}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: DesignTokens.line),
    boxShadow: DesignTokens.softShadow,
  );
}

class SoftBackdrop extends StatelessWidget {
  const SoftBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xffd7e4de), Color(0xffaebfb8), Color(0xffd8d4c5)],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -70,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 260,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0x889fc8bd),
                  borderRadius: BorderRadius.circular(90),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            right: -100,
            child: Transform.rotate(
              angle: 0.55,
              child: Container(
                width: 300,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0x77fff6e6),
                  borderRadius: BorderRadius.circular(80),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -95,
            left: -40,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 340,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0x6690aaa1),
                  borderRadius: BorderRadius.circular(110),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
              backgroundColor: Color(0xddedf4ef),
              selectedColor: Color(0xfff0b475),
              labelStyle: TextStyle(color: DesignTokens.sage, fontSize: 12, fontWeight: FontWeight.w700),
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
              backgroundColor: const Color(0xeeedf2e8),
              indicatorColor: const Color(0xffffd7a3),
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
              fillColor: const Color(0xeef5f2e8),
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
                foregroundColor: DesignTokens.ink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignTokens.ink,
                backgroundColor: const Color(0x99f7f4ea),
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
  String get smartPinnedChannel => isKo ? '스마트 추천 고정 채널명' : 'Pinned Smart Picks channel';
  String get smartPinnedChannelHelp => isKo
      ? '조회수 상위 2개와 이 채널의 플레이리스트 1개를 홈에 보여줍니다.'
      : 'Home shows the top 2 playlists by views plus 1 playlist from this channel.';
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

class MoodTubeState extends ChangeNotifier {
  final YouTubeSearchService searchService = YouTubeSearchService();
  final List<VideoItem> _saved = [];
  bool apiMode = false;
  String apiKey = '';
  String smartPinnedChannel = 'Rain Notes';
  String languageCode = 'auto';

  List<VideoItem> get saved => List.unmodifiable(_saved);
  List<VideoItem> get smartRecommendations => buildSmartRecommendations(smartPinnedChannel);
  Locale? get appLocale => languageCode == 'auto' ? null : Locale(languageCode);

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
    smartPinnedChannel = value.trim();
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

  Future<List<VideoItem>> findForMood(MoodPreset mood) {
    return searchService.searchMood(
      mood: mood,
      apiMode: apiMode,
      apiKey: apiKey,
    );
  }

  Future<List<VideoItem>> findForFreeText(String text) {
    final mood = matchMood(text);
    return findForMood(mood);
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
];

MoodPreset matchMood(String input) {
  final normalized = input.toLowerCase();
  var best = moodPresets.first;
  var bestScore = -1;
  for (final mood in moodPresets) {
    final score = mood.allKeywords.where((keyword) => normalized.contains(keyword.toLowerCase())).length;
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
  }) async {
    if (apiMode && apiKey.isNotEmpty) {
      try {
        return await _searchApi(mood, apiKey);
      } catch (_) {
        return _mockResults(mood);
      }
    }
    return _mockResults(mood);
  }

  Future<List<VideoItem>> _searchApi(MoodPreset mood, String apiKey) async {
    final query = mood.queries.first;
    final searchUri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'videoEmbeddable': 'true',
      'maxResults': '12',
      'key': apiKey,
    });
    final searchResponse = await http.get(searchUri);
    if (searchResponse.statusCode != 200) throw Exception('YouTube search failed');
    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(searchJson['items'] as List);
    final ids = items.map((item) => item['id']['videoId'] as String).join(',');

    final videosUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'snippet,contentDetails,statistics',
      'id': ids,
      'key': apiKey,
    });
    final videosResponse = await http.get(videosUri);
    if (videosResponse.statusCode != 200) throw Exception('YouTube videos failed');
    final videosJson = jsonDecode(videosResponse.body) as Map<String, dynamic>;
    final videos = List<Map<String, dynamic>>.from(videosJson['items'] as List);

    return videos.map((video) {
      final snippet = video['snippet'] as Map<String, dynamic>;
      final stats = video['statistics'] as Map<String, dynamic>;
      final details = video['contentDetails'] as Map<String, dynamic>;
      final duration = _parseIsoDuration(details['duration'] as String);
      final views = int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0;
      final title = snippet['title'] as String;
      return VideoItem(
        videoId: video['id'] as String,
        title: title,
        channelTitle: snippet['channelTitle'] as String,
        durationSeconds: duration,
        viewCount: views,
        publishedText: _publishedLabel(snippet['publishedAt'] as String),
        tags: mood.koreanKeywords.take(2).toList(),
        score: scoreVideo(title: title, durationSeconds: duration, viewCount: views, mood: mood),
      );
    }).where((item) => item.score > 0).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  List<VideoItem> _mockResults(MoodPreset mood) {
    final base = mockCatalog[mood.id] ?? mockCatalog['study_work']!;
    return base
        .map((item) => item.copyWith(
              tags: {...item.tags, mood.category}.toList(),
              score: scoreVideo(
                title: item.title,
                durationSeconds: item.durationSeconds,
                viewCount: item.viewCount,
                mood: mood,
              ),
            ))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
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
};

List<VideoItem> buildSmartRecommendations(String pinnedChannelName) {
  final allItems = mockCatalog.values.expand((items) => items).toList();
  final normalizedPinnedChannel = pinnedChannelName.trim().toLowerCase();
  VideoItem? forcedItem;
  if (normalizedPinnedChannel.isNotEmpty) {
    for (final item in allItems) {
      if (item.channelTitle.toLowerCase() == normalizedPinnedChannel) {
        forcedItem = item;
        break;
      }
    }
  }
  final topByViews = allItems
      .where((item) => forcedItem == null || item.videoId != forcedItem.videoId)
      .toList()
    ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

  return [
    ...topByViews.take(2),
    if (forcedItem != null) forcedItem,
  ];
}

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

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const LibraryScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(child: screens[index]),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xeeedf2e8),
          border: Border(top: BorderSide(color: DesignTokens.line)),
          boxShadow: [BoxShadow(color: Color(0x241f2a27), blurRadius: 18, offset: Offset(0, -8))],
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
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final featured = context.watch<MoodTubeState>().smartRecommendations;
    return SoftPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          const Text('MoodTube', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 0, color: DesignTokens.ink)),
          const SizedBox(height: 6),
          Text(text.homePrompt, style: const TextStyle(fontSize: 18, height: 1.35, fontWeight: FontWeight.w700, color: DesignTokens.sage)),
          const SizedBox(height: 26),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moodPresets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.48,
            ),
            itemBuilder: (context, index) => MoodCard(mood: moodPresets[index]),
          ),
          const SizedBox(height: 32),
          Text(text.smartRecommendations, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
          const SizedBox(height: 14),
          ...featured.map((item) => CompactVideoRow(item: item)),
        ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: softPanelDecoration(color: const Color(0xeef0f2e6)),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: DesignTokens.peach,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x5524302d), blurRadius: 8, offset: Offset(2, 3))],
                ),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Text(mood.emoji, style: const TextStyle(fontSize: 30)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                text.moodName(mood.id),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, height: 1.12, fontWeight: FontWeight.w900, color: DesignTokens.ink),
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
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return SoftPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 34),
        children: [
          Text(text.explore, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
          const SizedBox(height: 6),
          Text(text.smartMoodMatching, style: const TextStyle(fontSize: 15, height: 1.35, color: DesignTokens.sage)),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: text.searchHint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(context),
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
                .map((text) => ActionChip(
                      label: Text(text),
                      onPressed: () {
                        controller.text = text;
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
    final textLabels = AppText.of(context);
    final text = controller.text.trim();
    final mood = matchMood(text.isEmpty ? textLabels.emptySearchFallback : text);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultsScreen(mood: mood, sourceText: text)));
  }
}

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.mood, this.sourceText});

  final MoodPreset mood;
  final String? sourceText;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final state = context.watch<MoodTubeState>();
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: Text(text.moodName(mood.id))),
      body: SoftPage(
        child: FutureBuilder<List<VideoItem>>(
          future: state.findForMood(mood),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final results = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
              children: [
                Text(text.moodDescription(mood.id), style: const TextStyle(fontSize: 17, height: 1.35, fontWeight: FontWeight.w800, color: DesignTokens.ink)),
                if (sourceText != null && sourceText!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${text.sourceMoodPrefix}: $sourceText', style: const TextStyle(color: DesignTokens.sage)),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(item.thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
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
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PlayerScreen(item: item)),
                    ),
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
              decoration: softPanelDecoration(color: const Color(0xe8edf2e8)),
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
              onPressed: () => launchUrl(Uri.parse(widget.item.youtubeUrl), mode: LaunchMode.externalApplication),
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
          Text(text.library, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
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
          child: Image.network(item.thumbnailUrl, width: 92, height: 58, fit: BoxFit.cover),
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
          Text(text.settings, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: DesignTokens.ink)),
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
            decoration: softPanelDecoration(color: const Color(0xe8edf2e8)),
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
      decoration: softPanelDecoration(color: const Color(0xeef5f2e8)),
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
      decoration: softPanelDecoration(color: const Color(0xe8edf2e8)),
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
