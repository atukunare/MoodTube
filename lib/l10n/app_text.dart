import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moodtube/state/mood_tube_state.dart';

class AppText {
  const AppText(this.languageCode);

  final String languageCode;

  static AppText of(BuildContext context) {
    final state = context.watch<MoodTubeState>();
    final locale = Localizations.localeOf(context);
    return AppText(state.effectiveLanguageCode(locale));
  }

  bool get isKo => languageCode == 'ko';
  bool get isZh => languageCode == 'zh';

  /// Pick a localized string for the current language (ko / en / zh).
  String _pick(String ko, String en, String zh) => isZh ? zh : (isKo ? ko : en);

  String get home => _pick('홈', 'Home', '首页');
  String get explore => _pick('탐색', 'Explore', '探索');
  String get library => _pick('보관함', 'Library', '收藏');
  String get settings => _pick('설정', 'Settings', '设置');
  String get homePrompt => _pick('오늘은 어떤 분위기의 음악이 필요하세요?',
      'What kind of music mood do you need today?', '今天想听什么氛围的音乐？');
  String get smartRecommendations => _pick('스마트 추천', 'Smart Picks', '智能推荐');
  String get smartMoodMatching => _pick(
      '기분을 검색해 딱 맞는 음악을 찾아보세요.',
      'Search a mood, find the right music.',
      '搜索心情，找到合适的音乐。');
  String get searchHint =>
      _pick('예: 비 오는 밤 재즈', 'Example: rainy night jazz', '例如：雨夜爵士');
  String get findRecommendations => _pick('추천 찾기', 'Find picks', '查找推荐');
  String get sourceMoodPrefix => _pick('입력한 분위기', 'Entered mood', '输入的氛围');
  String get saved => _pick('저장됨', 'Saved', '已保存');
  String get save => _pick('저장', 'Save', '保存');
  String get play => _pick('재생', 'Play', '播放');
  String get savePlaylist => _pick('저장하기', 'Save', '保存');
  String get similarPlaylists =>
      _pick('비슷한 플레이리스트', 'Similar playlists', '相似的播放列表');
  String get openInYouTube =>
      _pick('유튜브에서 열기', 'Open in YouTube', '在 YouTube 中打开');
  String get noSavedItems =>
      _pick('아직 저장한 플레이리스트가 없습니다.', 'No saved playlists yet.', '还没有保存的播放列表。');
  String get librarySubtitle => _pick('저장한 분위기를 한눈에 정리하세요.',
      'Keep your saved moods beautifully organized.', '一目了然地整理你保存的氛围。');
  String get settingsSubtitle =>
      _pick('언어와 테마를 조정하세요.', 'Adjust language and theme.', '调整语言和主题。');
  String get appDescriptionTitle =>
      _pick('앱 설명', 'About MoodTube', '关于 MoodTube');
  String get appDescriptionBody => _pick(
      'MoodTube는 분위기를 고르면 유튜브 안의 긴 음악 플레이리스트를 찾아주는 앱입니다.',
      'MoodTube helps you find long music playlists on YouTube by mood.',
      'MoodTube 帮你按心情找到 YouTube 上的长音乐播放列表。');
  String get policyTitle => _pick('정책 안내', 'Policy notice', '政策说明');
  String get policyBody => _pick(
      'MoodTube는 유튜브 영상을 직접 저장하거나 다운로드하지 않습니다. 모든 재생은 공식 유튜브 플레이어를 통해 이루어집니다.',
      'MoodTube does not save or download YouTube videos. All playback happens through the official YouTube player.',
      'MoodTube 不会直接保存或下载 YouTube 视频。所有播放都通过官方 YouTube 播放器进行。');
  String get genericError => _pick('결과를 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
      "Couldn't load results. Please try again in a moment.", '无法加载结果，请稍后再试。');
  String get featuredChannel => _pick('추천 채널', 'Featured', '推荐频道');
  String get refreshMoods => _pick('무드 새로고침', 'Refresh moods', '刷新心情');
  String get language => _pick('언어', 'Language', '语言');
  String get languageHelp => _pick(
      '기기 언어를 따르거나 앱 언어를 직접 고를 수 있습니다.',
      'Follow the device language or choose an app language.',
      '跟随设备语言，或自行选择应用语言。');
  String get automatic => _pick('자동', 'Auto', '自动');
  String get theme => _pick('테마', 'Theme', '主题');
  String get themeHelp => _pick('시스템을 따르거나 라이트/다크를 직접 고를 수 있습니다.',
      'Follow the system, or pick light/dark.', '跟随系统，或自行选择浅色/深色。');
  String get themeSystem => _pick('시스템', 'System', '系统');
  String get themeLight => _pick('라이트', 'Light', '浅色');
  String get themeDark => _pick('다크', 'Dark', '深色');
  String get english => _pick('영어', 'English', '英语');
  String get korean => _pick('한국어', 'Korean', '韩语');
  String get chinese => _pick('중국어', 'Chinese', '中文');
  String get appVersion =>
      _pick('앱 버전 0.1.2', 'App version 0.1.2', '应用版本 0.1.2');
  String get unknownUploadDate =>
      _pick('업로드일 정보 없음', 'Upload date unavailable', '无上传日期信息');
  String get all => _pick('전체', 'All', '全部');
  String get saveFromExplore =>
      _pick('탐색에서 저장하기', 'Save from Explore', '从探索中保存');
  String get openMoodDial => _pick('무드 다이얼 열기', 'Open mood dial', '打开心情转盘');
  String get searchLabel => _pick('검색', 'Search', '搜索');
  String get profile => _pick('프로필', 'Profile', '个人资料');
  // Mood dial + home/explore section copy (kept 3-way for ko/en/zh parity).
  String get dialTitle =>
      _pick('오늘 어떤 분위기로 들을까요?', 'What mood would you like today?', '今天想听什么氛围？');
  String get dialSubtitle => _pick('무드 다이얼로 지금 내 기분을 선택해보세요',
      'Pick how you feel right now with the mood dial', '用心情转盘选择此刻的心情');
  String moodVibes(String name) =>
      _pick('$name 분위기', '$name vibes', '$name 氛围');
  String get findPlaylists => _pick('플레이리스트 찾기', 'Find playlists', '查找播放列表');
  String get smartPicks => _pick('스마트 픽', 'Smart Picks', '智能精选');
  String get smartPicksSubtitle =>
      _pick('지금 듣기 좋은 맞춤 추천', 'Picks worth playing right now', '此刻适合聆听的精选推荐');
  // Home Smart Picks subtitle after a search — never show the raw query text.
  String smartPicksBasedOn(String moodName) => _pick(
      "'$moodName' 무드 기준 추천", "Based on your '$moodName' mood", "基于'$moodName'心情的推荐");
  // Eyebrow label for the full-width Scapetune banner under the mood grid.
  String get todaysChannelPick =>
      _pick('오늘의 채널 픽', "Today's channel pick", '今日频道精选');
  String get seeAll => _pick('모두 보기', 'See all', '查看全部');
  String get browseByMood => _pick('무드로 둘러보기', 'Browse by mood', '按心情浏览');
  String get tryReco => _pick('추천 검색어', 'Try searching', '推荐搜索词');
  String get quickMoods => _pick('무드로 빠르게', 'Quick moods', '快速心情');
  String get recentSearches => _pick('최근 검색어', 'Recent Searches', '最近搜索');
  String get clearAll => _pick('모두 지우기', 'Clear All', '全部清除');

  // v0.1.3: A/B badge copy variants
  String get badgeFeatured => _pick('추천 채널', 'Featured', '推荐频道');
  String get badgeMoodChannel =>
      _pick('이 분위기엔 이 채널', 'This mood, this channel', '这种氛围适合这个频道');

  // v0.1.3: "YouTube에서 열기" overlay
  String get overlaySeeMore =>
      _pick('이 채널의 다른 영상도 보기', 'See more from this channel', '查看更多该频道的视频');

  // v0.1.3: Error snackbar messages
  String get playErrorRestricted => _pick(
        '이 영상은 재생할 수 없어 차단되었습니다 (다음 곡 자동 스킵)',
        'This video is restricted and has been skipped.',
        '此视频受限，已自动跳过。',
      );
  String get playErrorGeneric => _pick(
        '오류가 발생하여 다음 곡을 재생합니다.',
        'An error occurred. Playing the next video.',
        '发生错误。正在播放下一个视频。',
      );

  // v0.1.3: Reset play error blacklist options
  String get resetPlayErrorLabel => _pick('재생 오류 목록 초기화', 'Reset Play Errors', '重置播放错误列表');
  String get resetPlayErrorHelp => _pick(
        '재생 오류로 인해 자동 차단된 영상 목록을 모두 비우고 다시 추천에 포함시킵니다.',
        'Clear all automatically blocked videos and restore them to recommendations.',
        '清除所有自动屏蔽의 视频并重新将其包含在推荐中。',
      );
  String get blockedVideosCount => _pick('차단된 영상 수', 'Blocked videos', '已屏蔽视频数');
  String get resetButtonText => _pick('초기화', 'Reset', '重置');
  String get resetPlayErrorSuccess => _pick(
        '차단된 영상 목록이 성공적으로 초기화되었습니다.',
        'Successfully reset blocked videos list.',
        '已成功重置屏蔽视频列表。',
      );

  // v0.1.3: Library empty state subtitle
  String get libraryEmptySubtitle => _pick(
        '탐색에서 마음에 드는 플레이리스트를 저장해보세요.',
        'Save playlists you like from Explore.',
        '从探索中保存你喜欢的播放列表吧。',
      );

  List<String> get searchExamples => isZh
      ? ['雨夜爵士', '运动时的 EDM', '咖啡馆音乐', '编程专注音乐']
      : (isKo
          ? ['비 오는 밤 재즈', '운동할 때 EDM', '카페에서 들을 음악', '코딩 집중 음악']
          : [
              'rainy night jazz',
              'workout EDM',
              'music for a cafe',
              'coding focus music'
            ]);

  // Hidden fallback query when the search box is empty. Kept in en/ko keywords
  // so the offline mock catalog still matches for zh users too.
  String get emptySearchFallback => isKo ? '공부 집중' : 'study focus';

  String duration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final mm = minutes.toString().padLeft(2, '0');
    if (isKo) {
      if (hours > 0) return '$hours시간 $mm분';
      return '$minutes분';
    }
    if (isZh) {
      if (hours > 0) return '$hours小时$mm分';
      return '$minutes分钟';
    }
    if (hours > 0) return '${hours}h ${mm}m';
    return '${minutes}m';
  }

  // Compact scaled number: one decimal only while it adds information
  // (1.4만), never a trailing ".0" (8500만, not 8500.0만).
  static String _scaled(double value) {
    final text = value < 100 ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  String views(int viewCount) {
    if (isKo) {
      if (viewCount >= 100000000) {
        return '${_scaled(viewCount / 100000000)}억회';
      }
      if (viewCount >= 10000) {
        return '${_scaled(viewCount / 10000)}만회';
      }
      return '$viewCount회';
    }
    if (isZh) {
      if (viewCount >= 100000000) {
        return '${_scaled(viewCount / 100000000)}亿次播放';
      }
      if (viewCount >= 10000) {
        return '${_scaled(viewCount / 10000)}万次播放';
      }
      return '$viewCount次播放';
    }
    if (viewCount >= 1000000) {
      return '${_scaled(viewCount / 1000000)}M views';
    }
    if (viewCount >= 1000) {
      return '${_scaled(viewCount / 1000)}K views';
    }
    return '$viewCount views';
  }

  // Compact view count without the trailing unit, e.g. "128K" / "12만" / "12万".
  String _compactCount(int value) {
    if (isKo) {
      if (value >= 100000000) {
        return '${_scaled(value / 100000000)}억';
      }
      if (value >= 10000) return '${_scaled(value / 10000)}만';
      if (value >= 1000) return '${_scaled(value / 1000)}천';
      return '$value';
    }
    if (isZh) {
      if (value >= 100000000) {
        return '${_scaled(value / 100000000)}亿';
      }
      if (value >= 10000) return '${_scaled(value / 10000)}万';
      if (value >= 1000) return '${_scaled(value / 1000)}千';
      return '$value';
    }
    if (value >= 1000000) return '${_scaled(value / 1000000)}M';
    if (value >= 1000) return '${_scaled(value / 1000)}K';
    return '$value';
  }

  // Honest cumulative-plays label: "128K회 재생" / "128K plays" / "128K次播放".
  String listeners(int viewCount) {
    final count = _compactCount(viewCount);
    return _pick('$count회 재생', '$count plays', '$count次播放');
  }

  // Localized "today" header label, e.g. "5월 24일 토요일" / "Sat, May 24" / "5月24日 周六".
  String todayLabel() {
    final now = DateTime.now();
    if (isKo) {
      const days = ['월', '화', '수', '목', '금', '토', '일'];
      return '${now.month}월 ${now.day}일 ${days[now.weekday - 1]}요일';
    }
    if (isZh) {
      const days = ['一', '二', '三', '四', '五', '六', '日'];
      return '${now.month}月${now.day}日 周${days[now.weekday - 1]}';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  // Clock-style duration like "3:02:14" or "45:30".
  String clockDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    if (h > 0) return '$h:${two(m)}:${two(s)}';
    return '$m:${two(s)}';
  }

  String published(String value) {
    final clean = value.trim();
    if (clean == '최근') {
      return _pick('최근', 'Recent', '最近');
    }
    if (clean == '업로드일 정보 없음') {
      return _pick('업로드일 정보 없음', 'No upload date', '无上传日期');
    }
    final yearMatch = RegExp(r'^(\d+)년 전$').firstMatch(clean);
    if (yearMatch != null) {
      final years = yearMatch.group(1)!;
      if (isKo) return value;
      if (isZh) return '$years年前';
      return '$years ${years == '1' ? 'year' : 'years'} ago';
    }
    final monthMatch = RegExp(r'^(\d+)개월 전$').firstMatch(clean);
    if (monthMatch != null) {
      final months = monthMatch.group(1)!;
      if (isKo) return value;
      if (isZh) return '$months个月前';
      return '$months ${months == '1' ? 'month' : 'months'} ago';
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
    final zh = {
      'all': '全部',
      'study': '学习',
      'cafe': '咖啡',
      'sleep': '睡眠',
      'workout': '运动',
      'drive': '驾车',
      'likes': '喜欢',
    };
    return (isZh ? zh : (isKo ? ko : en))[key] ?? key;
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
    if (isZh) {
      const koToZh = {
        '공부': '学习',
        '집중': '专注',
        '작업': '工作',
        '코딩': '编程',
        '카페': '咖啡',
        '재즈': '爵士',
        '브런치': '早午餐',
        '비': '雨',
        '밤': '夜晚',
        '감성': '情绪',
        '피아노': '钢琴',
        '운동': '运动',
        '헬스': '健身',
        '러닝': '跑步',
        '드라이브': '驾车',
        '여행': '旅行',
        '여름': '夏天',
        '수면': '睡眠',
        '휴식': '休息',
        '명상': '冥想',
        '아침': '早晨',
        '상쾌한': '清爽',
        '시작': '开始',
        '새벽': '凌晨',
        '조용한': '安静',
        '좋아요': '喜欢',
        '로파이': 'Lofi',
        '클래식': '古典',
        '케이팝': 'K-pop',
        '팝': '流行',
        '록': '摇滚',
        '메탈': '金属',
        '게임': '游戏',
        '요리': '烹饪',
        '보사노바': '波萨诺瓦',
        '발라드': '抒情',
        '슬픈': '伤感',
        '자연': '自然',
        '숲': '森林',
        '파티': '派对',
        '댄스': '舞曲',
        '어쿠스틱': '原声',
        '영화': '电影',
        'OST': 'OST',
        'Scapetune': 'Scapetune',
      };
      return koToZh[value] ?? value;
    }
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
      'mood_calm': '차분한',
      'mood_melancholy': '우울한',
      'mood_dreamy': '몽환적인',
      'mood_energetic': '에너지',
      'mood_exciting': '신나는',
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
      'mood_calm': 'Calm',
      'mood_melancholy': 'Melancholy',
      'mood_dreamy': 'Dreamy',
      'mood_energetic': 'Energy',
      'mood_exciting': 'Exciting',
    };
    final zh = {
      'study_work': '学习 / 工作',
      'cafe_jazz': '咖啡爵士',
      'rainy_night': '雨夜',
      'workout_edm': '运动 EDM',
      'drive': '驾车',
      'sleep_piano': '睡眠钢琴',
      'morning': '清晨开始',
      'late_night': '深夜情绪',
      'chill_lofi': '轻松 Lofi',
      'classical_focus': '古典专注',
      'kpop_pop': 'K-pop / 流行',
      'rock_energy': '摇滚能量',
      'meditation_ambient': '冥想氛围',
      'gaming_focus': '游戏专注',
      'cooking_bossa': '烹饪波萨',
      'sad_ballad': '伤感抒情',
      'nature_sound': '自然声音',
      'party_dance': '派对舞曲',
      'acoustic_folk': '原声民谣',
      'film_score': '电影配乐',
      'mood_calm': '平静',
      'mood_melancholy': '忧郁',
      'mood_dreamy': '梦幻',
      'mood_energetic': '活力',
      'mood_exciting': '兴奋',
    };
    return (isZh ? zh : (isKo ? ko : en))[id] ?? id;
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
      'mood_calm': '잔잔하고 조용한 음악으로 마음을 가라앉혀요.',
      'mood_melancholy': '차분히 가라앉은 감성에 어울리는 음악이에요.',
      'mood_dreamy': '몽환적이고 공간감 있는 음악으로 떠나봐요.',
      'mood_energetic': '활기를 끌어올리는 에너지 넘치는 음악이에요.',
      'mood_exciting': '신나고 텐션을 올려주는 음악이에요.',
    };
    final en = {
      'study_work':
          'Playlists for focus-heavy study, work, and coding sessions.',
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
      'mood_calm': 'Calm, quiet music to settle your mind.',
      'mood_melancholy': 'Music for soft, melancholic moments.',
      'mood_dreamy': 'Dreamy, spacious music to drift away to.',
      'mood_energetic': 'Upbeat, energetic music to lift you up.',
      'mood_exciting': 'Exciting, high-energy music to get you going.',
    };
    final zh = {
      'study_work': '适合需要专注的学习、工作时段的播放列表。',
      'cafe_jazz': '宛如坐在安静咖啡馆的轻松播放列表。',
      'rainy_night': '适合雨夜的播放列表。',
      'workout_edm': '提升运动节奏的高能播放列表。',
      'drive': '点亮路上心情的播放列表。',
      'sleep_piano': '睡前放松聆听的轻柔播放列表。',
      'morning': '清新开启一天的播放列表。',
      'late_night': '深夜安静聆听的播放列表。',
      'chill_lofi': '随手播放的 Lofi / 轻松播放列表。',
      'classical_focus': '适合专注与阅读的古典播放列表。',
      'kpop_pop': '轻快熟悉的流行风播放列表。',
      'rock_energy': '需要能量时刻的摇滚播放列表。',
      'meditation_ambient': '适合冥想与呼吸的氛围播放列表。',
      'gaming_focus': '适合游戏或重复工作的专注播放列表。',
      'cooking_bossa': '做饭或做家务时播放的播放列表。',
      'sad_ballad': '想安静沉浸情绪时的播放列表。',
      'nature_sound': '想伴着自然声音休息时的播放列表。',
      'party_dance': '想提振心情时的舞曲播放列表。',
      'acoustic_folk': '舒适的原声 / 民谣风播放列表。',
      'film_score': '带来沉浸感的电影音乐播放列表。',
      'mood_calm': '用平静安静的音乐让心情沉淀下来。',
      'mood_melancholy': '适合柔和忧郁情绪的音乐。',
      'mood_dreamy': '用梦幻而有空间感的音乐去远行。',
      'mood_energetic': '充满活力、提振状态的音乐。',
      'mood_exciting': '让人兴奋、提升氛围的音乐。',
    };
    return (isZh ? zh : (isKo ? ko : en))[id] ?? id;
  }
}
