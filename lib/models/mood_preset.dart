import 'package:flutter/material.dart';

import 'package:moodtube/l10n/app_text.dart';
import 'package:moodtube/theme/tokens.dart';

class LanguageOption {
  const LanguageOption(this.code, this.labelKey);

  final String code;
  final String labelKey;

  String label(AppText text) {
    return switch (labelKey) {
      'auto' => text.automatic,
      'en' => text.english,
      'ko' => text.korean,
      'zh' => text.chinese,
      _ => labelKey,
    };
  }
}

const languageOptions = [
  LanguageOption('auto', 'auto'),
  LanguageOption('en', 'en'),
  LanguageOption('ko', 'ko'),
  LanguageOption('zh', 'zh'),
];

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

const moodPresets = [
  MoodPreset(
    id: 'study_work',
    name: '공부 / 작업',
    emoji: '📚',
    category: '공부',
    description: '집중이 필요한 시간에 어울리는 플레이리스트입니다.',
    koreanKeywords: ['공부', '작업', '집중', '코딩', '업무'],
    englishKeywords: [
      'study',
      'focus',
      'work',
      'coding',
      'deep focus',
      'no lyrics'
    ],
    queries: [
      'lofi study playlist',
      'deep focus music',
      'coding music playlist',
      'study music no lyrics'
    ],
  ),
  MoodPreset(
    id: 'cafe_jazz',
    name: '카페 재즈',
    emoji: '☕',
    category: '카페',
    description: '카페에 앉아 있는 듯 잔잔한 플레이리스트입니다.',
    koreanKeywords: ['카페', '재즈', '브런치', '커피', '잔잔한'],
    englishKeywords: ['cafe', 'jazz', 'coffee shop', 'relaxing', 'bossa nova'],
    queries: [
      'cafe jazz playlist',
      'coffee shop jazz music',
      'relaxing cafe jazz 1 hour',
      'bossa nova cafe music'
    ],
  ),
  MoodPreset(
    id: 'rainy_night',
    name: '비 오는 밤',
    emoji: '🌧',
    category: '좋아요',
    description: '비 오는 밤에 어울리는 플레이리스트입니다.',
    koreanKeywords: ['비', '비오는', '밤', '감성', '차분한', '우울'],
    englishKeywords: ['rainy night', 'rain', 'calm', 'jazz', 'lofi', 'piano'],
    queries: [
      'rainy night jazz playlist',
      'rainy lofi music',
      'calm piano rainy night',
      'coffee shop rainy jazz'
    ],
  ),
  MoodPreset(
    id: 'workout_edm',
    name: '운동 EDM',
    emoji: '⚡',
    category: '운동',
    description: '운동 흐름을 끌어올리는 에너지 높은 플레이리스트입니다.',
    koreanKeywords: ['운동', '헬스', '러닝', '신나는', '강한'],
    englishKeywords: [
      'workout',
      'gym',
      'running',
      'edm',
      'phonk',
      'high energy'
    ],
    queries: [
      'workout edm mix',
      'gym phonk playlist',
      'running music mix',
      'high energy workout music'
    ],
  ),
  MoodPreset(
    id: 'drive',
    name: '드라이브',
    emoji: '🚗',
    category: '드라이브',
    description: '도로 위 기분을 살려주는 플레이리스트입니다.',
    koreanKeywords: ['드라이브', '여행', '도로', '여름'],
    englishKeywords: ['drive', 'road trip', 'city pop', 'synthwave', 'summer'],
    queries: [
      'city pop drive playlist',
      'synthwave road trip mix',
      'summer drive music',
      'road trip playlist'
    ],
  ),
  MoodPreset(
    id: 'sleep_piano',
    name: '수면 피아노',
    emoji: '🌙',
    category: '수면',
    description: '잠들기 전 편안하게 틀어두기 좋은 플레이리스트입니다.',
    koreanKeywords: ['수면', '잠', '휴식', '명상', '편안한'],
    englishKeywords: ['sleep', 'piano', 'ambient', 'healing', 'relaxing'],
    queries: [
      'sleep piano music',
      'relaxing piano playlist',
      'ambient sleep music',
      'healing music for sleep'
    ],
  ),
  MoodPreset(
    id: 'morning',
    name: '아침 시작',
    emoji: '🌤',
    category: '좋아요',
    description: '하루를 산뜻하게 열어주는 플레이리스트입니다.',
    koreanKeywords: ['아침', '시작', '산뜻한', '상쾌한'],
    englishKeywords: ['morning', 'fresh', 'acoustic', 'soft pop'],
    queries: [
      'morning acoustic playlist',
      'fresh morning music',
      'soft pop morning playlist'
    ],
  ),
  MoodPreset(
    id: 'late_night',
    name: '감성 밤',
    emoji: '✨',
    category: '좋아요',
    description: '늦은 밤 조용히 듣기 좋은 플레이리스트입니다.',
    koreanKeywords: ['밤', '새벽', '감성', '조용한'],
    englishKeywords: ['late night', 'chill', 'lofi', 'jazz', 'ambient'],
    queries: [
      'late night lofi playlist',
      'chill night music',
      'midnight jazz playlist'
    ],
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
    queries: [
      'classical music for focus playlist',
      'piano reading music 2 hours'
    ],
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
    queries: [
      'rock energy playlist',
      'alternative rock mix',
      'workout rock playlist'
    ],
  ),
  MoodPreset(
    id: 'meditation_ambient',
    name: '명상 앰비언트',
    emoji: '🫧',
    category: '수면',
    description: '명상과 호흡에 어울리는 앰비언트 플레이리스트입니다.',
    koreanKeywords: ['명상', '호흡', '앰비언트', '휴식'],
    englishKeywords: ['meditation', 'ambient', 'breathing', 'calm', 'healing'],
    queries: [
      'ambient meditation playlist',
      'breathing music mix',
      'calm ambient music'
    ],
  ),
  MoodPreset(
    id: 'gaming_focus',
    name: '게임 집중',
    emoji: '🎮',
    category: '공부',
    description: '게임이나 반복 작업에 어울리는 집중 플레이리스트입니다.',
    koreanKeywords: ['게임', '집중', '사이버', '작업'],
    englishKeywords: [
      'gaming',
      'focus',
      'cyberpunk',
      'electronic',
      'background'
    ],
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
    queries: [
      'sad ballad playlist',
      'emotional songs playlist',
      'quiet heartbreak mix'
    ],
  ),
  MoodPreset(
    id: 'nature_sound',
    name: '자연 사운드',
    emoji: '🌲',
    category: '수면',
    description: '자연 소리와 함께 쉬고 싶을 때 어울리는 플레이리스트입니다.',
    koreanKeywords: ['자연', '숲', '비', '파도', '휴식'],
    englishKeywords: ['nature', 'forest', 'rain sounds', 'ocean', 'relaxing'],
    queries: [
      'nature sounds playlist',
      'forest rain sounds 3 hours',
      'ocean waves sleep music'
    ],
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
    englishKeywords: [
      'film score',
      'soundtrack',
      'cinematic',
      'epic',
      'orchestral'
    ],
    queries: [
      'film score playlist',
      'cinematic soundtrack mix',
      'epic orchestral music'
    ],
  ),
];

// Atmosphere / energy moods for the home mood dial, ordered left -> right
// from calm & quiet to exciting & energetic (per design reference).
const dialMoodPresets = [
  MoodPreset(
    id: 'mood_calm',
    name: '차분한',
    emoji: '🤍',
    category: '무드',
    description: '잔잔하고 조용한 음악으로 마음을 가라앉혀요.',
    koreanKeywords: ['차분', '잔잔', '조용', '휴식', '로파이'],
    englishKeywords: ['calm', 'peaceful', 'relax', 'quiet', 'lofi'],
    queries: [
      'calm relaxing music playlist',
      'peaceful lofi playlist',
      'quiet ambient music',
      '잔잔한 음악 모음'
    ],
  ),
  MoodPreset(
    id: 'mood_melancholy',
    name: '우울한',
    emoji: '🌧️',
    category: '무드',
    description: '차분히 가라앉은 감성에 어울리는 음악이에요.',
    koreanKeywords: ['우울', '감성', '슬픈', '발라드', '비'],
    englishKeywords: ['melancholy', 'sad', 'emotional', 'ballad', 'rainy'],
    queries: [
      'sad emotional playlist',
      'melancholy piano playlist',
      'rainy day sad songs',
      '감성 발라드 모음'
    ],
  ),
  MoodPreset(
    id: 'mood_dreamy',
    name: '몽환적인',
    emoji: '☁️',
    category: '무드',
    description: '몽환적이고 공간감 있는 음악으로 떠나봐요.',
    koreanKeywords: ['몽환', '드림팝', '앰비언트', '공간', '꿈'],
    englishKeywords: [
      'dreamy',
      'dream pop',
      'ambient',
      'ethereal',
      'chillwave'
    ],
    queries: [
      'dreamy ambient playlist',
      'dream pop playlist',
      'ethereal chillwave music',
      '몽환적인 음악 모음'
    ],
  ),
  MoodPreset(
    id: 'mood_energetic',
    name: '에너지',
    emoji: '⚡',
    category: '무드',
    description: '활기를 끌어올리는 에너지 넘치는 음악이에요.',
    koreanKeywords: ['에너지', '활기', '업비트', '운동', '동기부여'],
    englishKeywords: ['energetic', 'upbeat', 'workout', 'motivation', 'pump'],
    queries: [
      'energetic upbeat playlist',
      'workout motivation music',
      'high energy edm playlist',
      '신나는 운동 음악'
    ],
  ),
  MoodPreset(
    id: 'mood_exciting',
    name: '신나는',
    emoji: '🎉',
    category: '무드',
    description: '신나고 텐션을 올려주는 음악이에요.',
    koreanKeywords: ['신나는', '파티', '댄스', '텐션', '흥'],
    englishKeywords: ['exciting', 'party', 'dance', 'hype', 'feel good'],
    queries: [
      'party dance hits playlist',
      'feel good upbeat songs',
      'hype dance party mix',
      '신나는 파티 음악'
    ],
  ),
];

// Per-atmosphere accent color for the dial nodes (calm-blue -> hot-pink).
Color atmosphereAccent(String id) {
  switch (id) {
    case 'mood_calm':
      return DesignTokens.auraBlue;
    case 'mood_melancholy':
      return DesignTokens.cobalt;
    case 'mood_dreamy':
      return DesignTokens.violet;
    case 'mood_energetic':
      return DesignTokens.peach;
    case 'mood_exciting':
      return DesignTokens.rose;
    default:
      return DesignTokens.violet;
  }
}

// Maps each atmosphere/energy mood to the curated activity moods whose internal
// (already-fetched) playlists fit it — so the dial recommends from the local
// catalog without needing the YouTube API.
const atmosphereToActivities = <String, List<String>>{
  'mood_calm': [
    'chill_lofi',
    'sleep_piano',
    'meditation_ambient',
    'study_work'
  ],
  'mood_melancholy': ['sad_ballad', 'rainy_night', 'late_night'],
  'mood_dreamy': ['meditation_ambient', 'nature_sound', 'chill_lofi'],
  'mood_energetic': ['workout_edm', 'rock_energy', 'gaming_focus'],
  'mood_exciting': ['party_dance', 'kpop_pop', 'workout_edm'],
};

MoodPreset matchMood(String input) {
  final normalized = input.toLowerCase();
  var best = moodPresets.first;
  var bestScore = -1;
  for (final mood in moodPresets) {
    var score = 0;
    for (final keyword in mood.allKeywords) {
      final normalizedKeyword = keyword.toLowerCase();
      if (normalized.contains(normalizedKeyword)) {
        score += normalizedKeyword.length > 3 ? 2 : 1;
      }
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
  if (lowerTitle.contains('1 hour') ||
      lowerTitle.contains('2 hours') ||
      lowerTitle.contains('3 hours')) {
    score += 20;
  }
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
