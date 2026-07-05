import 'dart:math';

import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/services/search_service.dart';

// 카탈로그의 모든 videoId는 실존 영상이어야 한다(죽은 ID는 회색 썸네일과
// 재생 오류를 만든다). 전체 검증: tools/check_catalog.sh (oEmbed 200 + 썸네일).
// 마지막 전수 검증: 2026-07-05.
final mockCatalog = <String, List<VideoItem>>{
  'study_work': [
    mockVideo('TURbeWK2wwg', '4 A.M Study Session [lofi hip hop]',
        'Lofi Girl', 7200, 18400000, '1년 전', ['공부', '집중']),
    mockVideo('lTRiuFIWV54', 'Deep Focus Music for Coding and Work - 3 Hours',
        'Focus Flow', 10800, 2450000, '8개월 전', ['작업', '코딩']),
    mockVideo('Dx5qFachd3A', 'study music no lyrics playlist 1 hour',
        'Quiet Desk', 3600, 820000, '2년 전', ['공부']),
    mockVideo(
        'jgpJVI3tDbY',
        'The Best of Classical Music - Mozart, Beethoven, Bach, Chopin',
        'Just Instrumental Music',
        7200,
        43000000,
        '2년 전',
        ['클래식', '공부', '집중']),
    mockVideo('Rb0UmrCXxVA', 'The Best of Mozart', 'HALIDONMUSIC', 7200,
        21000000, '3년 전', ['클래식', '집중', '코딩']),
    mockVideo(
        'oucITib5F6A',
        'Soft Café Background Music for Work & Study | scapetune',
        'Scapetune',
        7200,
        132000,
        '최근',
        ['Scapetune', '카페', '집중', '공부']),
  ],
  'cafe_jazz': [
    mockVideo(
        'neV3EPgvZ3g',
        'coffee shop jazz music playlist - relaxing cafe 3 hours',
        'Cafe Sounds',
        10800,
        9100000,
        '10개월 전',
        ['카페', '재즈']),
    mockVideo('HMnrl0tmd3k', 'bossa nova cafe music mix for brunch',
        'Jazz Table', 5400, 1900000, '1년 전', ['브런치']),
    mockVideo('w9COHCrwNQs', 'relaxing cafe jazz 1 hour', 'Warm Cup', 3600,
        420000, '6개월 전', ['카페']),
    mockVideo(
        'lP26UCnoH9s',
        'Coffee Shop Radio - 24/7 lofi & jazzy hip-hop beats',
        'STEEZYASFUCK',
        10800,
        8200000,
        '최근',
        ['카페', '재즈', '보사노바']),
    mockVideo(
        'oucITib5F6A',
        'Soft Café Background Music for Work & Study | scapetune',
        'Scapetune',
        7200,
        132000,
        '최근',
        ['Scapetune', '카페', '재즈', '집중']),
  ],
  'rainy_night': [
    mockVideo(
        'DSGyEsJ17cI',
        'rainy night jazz playlist - calm coffee shop rain',
        'Rain Notes',
        7200,
        3200000,
        '1년 전',
        ['비', '밤']),
    mockVideo('kgx4WGK0oNU', 'rainy lofi music mix for late night',
        'Window Lofi', 5400, 1300000, '7개월 전', ['감성']),
    mockVideo('UfcAVejslrU', 'calm piano rainy night 2 hours',
        'Soft Piano Room', 7200, 710000, '2년 전', ['피아노']),
    mockVideo(
        '4oStw0r33so',
        'peaceful piano radio - music to focus/study to',
        'Lofi Girl',
        10800,
        1850000,
        '최근',
        ['피아노', '비', '잔잔한']),
    mockVideo(
        'S_MOd40zlYU',
        'dark ambient radio - music to escape/dream to',
        'Lofi Girl',
        7200,
        2400000,
        '최근',
        ['밤', '비', '앰비언트']),
    mockVideo(
        'mPZkdNFkNps',
        'Rain Sounds on Window with Thunder - for Sleep & Study',
        'Relaxing Ambience ASMR',
        36000,
        15000000,
        '2년 전',
        ['비', '자연', '수면']),
    mockVideo(
        '0Y4n_mIxE5E',
        'A Quiet Café Playlist for Rainy Days | scapetune',
        'Scapetune',
        5400,
        96000,
        '최근',
        ['Scapetune', '비', '카페', '밤']),
  ],
  'workout_edm': [
    mockVideo(
        '36YnV9STBqc',
        'The Good Life Radio - 24/7 Relax House, Chillout & Happy Music',
        'The Good Life Radio',
        14400,
        6100000,
        '최근',
        ['운동', 'EDM']),
    mockVideo('gCYcHz2k5x0', 'Martin Garrix - Animals (Official Video)',
        'STMPD RCRDS', 305, 98000000, '1년 전', ['헬스', 'EDM']),
    mockVideo(
        '41RxXpCO8UU',
        'SYSTEM OVERRIDE Vol.01 | Dark Drum & Bass / Dubstep',
        'Scapetune',
        3600,
        112000,
        '최근',
        ['Scapetune', '운동', 'EDM', '파티']),
  ],
  'drive': [
    mockVideo(
        '36YnV9STBqc',
        'The Good Life Radio - 24/7 Relax House, Chillout & Happy Music',
        'The Good Life Radio',
        14400,
        6100000,
        '최근',
        ['드라이브']),
    mockVideo('MV_3Dpw-BRY', 'synthwave road trip mix 2 hours', 'Night Highway',
        7200, 3500000, '2년 전', ['여행']),
    mockVideo(
        'S_MOd40zlYU',
        'dark ambient radio - music to escape/dream to',
        'Lofi Girl',
        7200,
        2400000,
        '최근',
        ['드라이브', '밤']),
    mockVideo(
        'tNkZsRW7h2c',
        'Space Ambient Music LIVE 24/7 - Relaxing Background Music',
        'Relaxation Ambient Music',
        14400,
        4200000,
        '최근',
        ['드라이브', '게임', '앰비언트']),
    mockVideo(
        'BIQ20PFQdPY',
        'THE WORLD IS ONE STADIUM | Global Football Anthems 2026',
        'Scapetune',
        2700,
        145000,
        '최근',
        ['Scapetune', '드라이브', '파티', '신나는']),
  ],
  'sleep_piano': [
    mockVideo(
        '1ZYbU82GVz4',
        'sleep piano music playlist - relaxing piano 3 hours',
        'Rest Keys',
        10800,
        7600000,
        '2년 전',
        ['수면', '피아노']),
    mockVideo('bP9gMpl1gyQ', 'ambient sleep music mix for deep rest',
        'Night Calm', 7200, 2100000, '1년 전', ['휴식']),
    mockVideo('lE6RYpe9IT0', 'Relaxing Music with Nature Sounds - Waterfall HD',
        '321 Relaxing', 3600, 450000, '8개월 전', ['명상', '수면']),
    mockVideo(
        'tNkZsRW7h2c',
        'Space Ambient Music LIVE 24/7 - Relaxing Background Music',
        'Relaxation Ambient Music',
        14400,
        4200000,
        '최근',
        ['앰비언트', '수면']),
    mockVideo(
        '4oStw0r33so',
        'peaceful piano radio - music to focus/study to',
        'Lofi Girl',
        10800,
        1850000,
        '최근',
        ['피아노', '수면']),
    mockVideo(
        'rUxyKA_-grg',
        'lofi hip hop radio - beats to sleep/chill to',
        'Lofi Girl',
        28800,
        85000000,
        '최근',
        ['수면', '로파이', '밤']),
    mockVideo(
        'lzJv5IFcj-I',
        'scapetune radio chill music stream | lo-fi',
        'Scapetune',
        14400,
        64000,
        '최근',
        ['Scapetune', '수면', '로파이', '밤']),
  ],
  'morning': [
    mockVideo('lFcSrYw-ARY', 'morning acoustic playlist - fresh start music',
        'Morning Table', 5400, 1250000, '1년 전', ['아침']),
    mockVideo(
        '36YnV9STBqc',
        'The Good Life Radio - 24/7 Relax House, Chillout & Happy Music',
        'The Good Life Radio',
        14400,
        6100000,
        '최근',
        ['상쾌한', '팝']),
    mockVideo('xNN7iTA57jM', 'Forest Sounds - Woodland Ambience & Bird Song',
        'The Guild of Ambience', 10800, 6500000, '2년 전',
        ['아침', '자연', '새소리']),
    mockVideo(
        '5yx6BWlEVcY',
        'Chillhop Radio - jazzy & lofi hip hop beats',
        'Chillhop Music',
        14400,
        5400000,
        '최근',
        ['아침', '로파이', '상쾌한']),
    mockVideo(
        'MhsT1sf4Kak',
        'POV: You Found a Quiet Cafe Playlist | scapetune',
        'Scapetune',
        3600,
        78000,
        '최근',
        ['Scapetune', '아침', '카페', '산뜻한']),
  ],
  'late_night': [
    mockVideo('5qap5aO4i9A', 'late night lofi playlist - chill night music',
        'Quiet Hours', 7200, 12800000, '2년 전', ['밤', '감성']),
    mockVideo('DWcJFNfaw9c', 'midnight jazz playlist 2 hours',
        'After Dark Jazz', 7200, 2400000, '1년 전', ['새벽']),
    mockVideo('7NOSDKb0HlU', 'chill ambient music mix for late night',
        'Dim Light', 5400, 800000, '6개월 전', ['조용한']),
    mockVideo(
        'rUxyKA_-grg',
        'lofi hip hop radio - beats to sleep/chill to',
        'Lofi Girl',
        28800,
        85000000,
        '최근',
        ['수면', '로파이', '밤']),
    mockVideo(
        'DMgcQptIbMc',
        'scapetune radio chill music stream | lo-fi, city pop',
        'Scapetune',
        14400,
        184000,
        '최근',
        ['Scapetune', '밤', '로파이', '감성']),
  ],
  'chill_lofi': [
    mockVideo('TURbeWK2wwg', '4 A.M Study Session [lofi hip hop]',
        'Lofi Girl', 7200, 18400000, '1년 전', ['로파이', '칠']),
    mockVideo('5qap5aO4i9A', 'lofi beats mix for soft focus', 'Quiet Hours',
        7200, 12800000, '2년 전', ['로파이']),
    mockVideo('kgx4WGK0oNU', 'chillhop rainy room mix', 'Window Lofi', 5400,
        1300000, '7개월 전', ['칠']),
    mockVideo(
        'rUxyKA_-grg',
        'lofi hip hop radio - beats to sleep/chill to',
        'Lofi Girl',
        28800,
        85000000,
        '최근',
        ['수면', '로파이', '밤']),
    mockVideo(
        '5yx6BWlEVcY',
        'Chillhop Radio - jazzy & lofi hip hop beats',
        'Chillhop Music',
        14400,
        5400000,
        '최근',
        ['로파이', '칠', '재즈']),
    mockVideo(
        'lzJv5IFcj-I',
        'scapetune radio chill music stream | lo-fi',
        'Scapetune',
        14400,
        64000,
        '최근',
        ['Scapetune', '로파이', '칠', '밤']),
  ],
  'classical_focus': [
    mockVideo(
        '1ZYbU82GVz4',
        'classical piano music for reading and focus 3 hours',
        'Rest Keys',
        10800,
        7600000,
        '2년 전',
        ['클래식', '집중']),
    mockVideo('UfcAVejslrU', 'calm piano classical focus playlist 2 hours',
        'Soft Piano Room', 7200, 710000, '2년 전', ['피아노']),
    mockVideo(
        'tNkZsRW7h2c',
        'Space Ambient Music LIVE 24/7 - Relaxing Background Music',
        'Relaxation Ambient Music',
        14400,
        4200000,
        '최근',
        ['앰비언트', '집중', '피아노']),
    mockVideo(
        'WPni755-Krg',
        'Study Music Alpha Waves - Relaxing Studying Music',
        'Yellow Brick Cinema',
        10800,
        3100000,
        '2년 전',
        ['집중', '알파파', '공부']),
    mockVideo(
        'jgpJVI3tDbY',
        'The Best of Classical Music - Mozart, Beethoven, Bach, Chopin',
        'Just Instrumental Music',
        7200,
        43000000,
        '2년 전',
        ['클래식', '공부', '집중']),
    mockVideo('Rb0UmrCXxVA', 'The Best of Mozart', 'HALIDONMUSIC', 7200,
        21000000, '3년 전', ['클래식', '집중', '코딩']),
    mockVideo(
        'oucITib5F6A',
        'Soft Cafe Background Music for Work & Study | scapetune',
        'Scapetune',
        7200,
        132000,
        '최근',
        ['Scapetune', '카페', '집중', '클래식']),
  ],
  'kpop_pop': [
    mockVideo(
        '36YnV9STBqc',
        'The Good Life Radio - 24/7 Relax House, Chillout & Happy Music',
        'The Good Life Radio',
        14400,
        6100000,
        '최근',
        ['팝', '신나는']),
    mockVideo('gCYcHz2k5x0', 'Martin Garrix - Animals (Official Video)',
        'STMPD RCRDS', 305, 98000000, '1년 전', ['팝', 'EDM']),
    mockVideo('lFcSrYw-ARY', 'soft pop morning playlist', 'Morning Table', 5400,
        1250000, '1년 전', ['팝']),
    mockVideo(
        'BIQ20PFQdPY',
        'THE WORLD IS ONE STADIUM | Global Football Anthems 2026',
        'Scapetune',
        2700,
        145000,
        '최근',
        ['Scapetune', '파티', '신나는', '팝']),
  ],
  'rock_energy': [
    mockVideo(
        '36YnV9STBqc',
        'The Good Life Radio - 24/7 Relax House, Chillout & Happy Music',
        'The Good Life Radio',
        14400,
        6100000,
        '최근',
        ['에너지', '운동']),
    mockVideo('gCYcHz2k5x0', 'Martin Garrix - Animals (Official Video)',
        'STMPD RCRDS', 305, 98000000, '1년 전', ['에너지', 'EDM']),
    mockVideo(
        '41RxXpCO8UU',
        'SYSTEM OVERRIDE Vol.01 | Dark Drum & Bass / Dubstep',
        'Scapetune',
        3600,
        112000,
        '최근',
        ['Scapetune', '운동', '록', '에너지']),
  ],
  'meditation_ambient': [
    mockVideo('bP9gMpl1gyQ', 'ambient meditation music mix for deep rest',
        'Night Calm', 7200, 2100000, '1년 전', ['명상', '휴식']),
    mockVideo('lE6RYpe9IT0', 'Relaxing Music with Nature Sounds - Waterfall HD',
        '321 Relaxing', 3600, 450000, '8개월 전', ['명상', '자연', '휴식']),
    mockVideo('1ZYbU82GVz4', 'soft ambient piano sleep playlist 3 hours',
        'Rest Keys', 10800, 7600000, '2년 전', ['앰비언트']),
    mockVideo(
        'mPZkdNFkNps',
        'Rain Sounds on Window with Thunder - for Sleep & Study',
        'Relaxing Ambience ASMR',
        36000,
        15000000,
        '2년 전',
        ['비', '자연', '수면']),
    mockVideo('xNN7iTA57jM', 'Forest Sounds - Woodland Ambience & Bird Song',
        'The Guild of Ambience', 10800, 6500000, '2년 전',
        ['자연', '새소리', '휴식']),
    mockVideo(
        'lzJv5IFcj-I',
        'scapetune radio chill music stream | lo-fi',
        'Scapetune',
        14400,
        64000,
        '최근',
        ['Scapetune', '명상', '로파이', '휴식']),
  ],
  'gaming_focus': [
    mockVideo(
        'lTRiuFIWV54',
        'gaming focus music for coding and grinding 3 hours',
        'Focus Flow',
        10800,
        2450000,
        '8개월 전',
        ['게임', '집중']),
    mockVideo('MV_3Dpw-BRY', 'cyberpunk gaming background mix 2 hours',
        'Night Highway', 7200, 3500000, '2년 전', ['게임']),
    mockVideo(
        'S_MOd40zlYU',
        'dark ambient radio - music to escape/dream to',
        'Lofi Girl',
        7200,
        2400000,
        '최근',
        ['게임', '집중', '앰비언트']),
    mockVideo(
        'tNkZsRW7h2c',
        'Space Ambient Music LIVE 24/7 - Relaxing Background Music',
        'Relaxation Ambient Music',
        14400,
        4200000,
        '최근',
        ['게임', '앰비언트', '우주']),
    mockVideo(
        'DMgcQptIbMc',
        'scapetune radio chill music stream | lo-fi, city pop',
        'Scapetune',
        14400,
        184000,
        '최근',
        ['Scapetune', '게임', '집중', '로파이']),
  ],
  'cooking_bossa': [
    mockVideo('HMnrl0tmd3k', 'bossa nova cooking playlist for brunch',
        'Jazz Table', 5400, 1900000, '1년 전', ['요리', '보사노바']),
    mockVideo('neV3EPgvZ3g', 'coffee shop jazz kitchen playlist 3 hours',
        'Cafe Sounds', 10800, 9100000, '10개월 전', ['카페']),
    mockVideo('w9COHCrwNQs', 'relaxing bossa nova for home cooking 1 hour',
        'Warm Cup', 3600, 420000, '6개월 전', ['보사노바']),
    mockVideo(
        'lP26UCnoH9s',
        'Coffee Shop Radio - 24/7 lofi & jazzy hip-hop beats',
        'STEEZYASFUCK',
        10800,
        8200000,
        '최근',
        ['카페', '재즈', '요리']),
    mockVideo(
        'MhsT1sf4Kak',
        'POV: You Found a Quiet Cafe Playlist | scapetune',
        'Scapetune',
        3600,
        78000,
        '최근',
        ['Scapetune', '카페', '요리', '보사노바']),
  ],
  'sad_ballad': [
    mockVideo('DWcJFNfaw9c', 'sad ballad playlist for late night',
        'After Dark Jazz', 7200, 2400000, '1년 전', ['슬픈', '발라드']),
    mockVideo('7NOSDKb0HlU', 'emotional quiet songs mix', 'Dim Light', 5400,
        800000, '6개월 전', ['감성']),
    mockVideo('UfcAVejslrU', 'calm piano heartbreak playlist 2 hours',
        'Soft Piano Room', 7200, 710000, '2년 전', ['피아노']),
    mockVideo(
        'lzJv5IFcj-I',
        'scapetune radio chill music stream | lo-fi',
        'Scapetune',
        14400,
        64000,
        '최근',
        ['Scapetune', '슬픈', '로파이', '감성']),
  ],
  'nature_sound': [
    mockVideo('DSGyEsJ17cI', 'forest rain sounds playlist for sleep',
        'Rain Notes', 7200, 3200000, '1년 전', ['자연', '비']),
    mockVideo('1ZYbU82GVz4', 'ocean waves and soft piano 3 hours', 'Rest Keys',
        10800, 7600000, '2년 전', ['자연']),
    mockVideo('bP9gMpl1gyQ', 'nature ambient music mix for deep rest',
        'Night Calm', 7200, 2100000, '1년 전', ['숲']),
    mockVideo(
        'mPZkdNFkNps',
        'Rain Sounds on Window with Thunder - for Sleep & Study',
        'Relaxing Ambience ASMR',
        36000,
        15000000,
        '2년 전',
        ['비', '자연', '수면']),
    mockVideo('xNN7iTA57jM', 'Forest Sounds - Woodland Ambience & Bird Song',
        'The Guild of Ambience', 10800, 6500000, '2년 전',
        ['자연', '새소리', '휴식']),
    mockVideo(
        '0Y4n_mIxE5E',
        'A Quiet Cafe Playlist for Rainy Days | scapetune',
        'Scapetune',
        5400,
        96000,
        '최근',
        ['Scapetune', '자연', '비', '휴식']),
  ],
  'party_dance': [
    mockVideo(
        '36YnV9STBqc',
        'The Good Life Radio - 24/7 Relax House, Chillout & Happy Music',
        'The Good Life Radio',
        14400,
        6100000,
        '최근',
        ['파티', '댄스']),
    mockVideo('gCYcHz2k5x0', 'Martin Garrix - Animals (Official Video)',
        'STMPD RCRDS', 305, 98000000, '1년 전', ['댄스', 'EDM']),
    mockVideo(
        'BIQ20PFQdPY',
        'THE WORLD IS ONE STADIUM | Global Football Anthems 2026',
        'Scapetune',
        2700,
        145000,
        '최근',
        ['Scapetune', '파티', '댄스', '신나는']),
  ],
  'acoustic_folk': [
    mockVideo('lFcSrYw-ARY', 'cozy acoustic folk playlist', 'Morning Table',
        5400, 1250000, '1년 전', ['어쿠스틱']),
    mockVideo(
        '4oStw0r33so',
        'peaceful piano radio - music to focus/study to',
        'Lofi Girl',
        10800,
        1850000,
        '최근',
        ['피아노', '잔잔한']),
    mockVideo('lE6RYpe9IT0', 'Relaxing Music with Nature Sounds - Waterfall HD',
        '321 Relaxing', 3600, 450000, '8개월 전', ['자연', '어쿠스틱']),
    mockVideo(
        'MhsT1sf4Kak',
        'POV: You Found a Quiet Cafe Playlist | scapetune',
        'Scapetune',
        3600,
        78000,
        '최근',
        ['Scapetune', '어쿠스틱', '카페', '잔잔한']),
  ],
  'film_score': [
    mockVideo('MV_3Dpw-BRY', 'cinematic soundtrack playlist 2 hours',
        'Night Highway', 7200, 3500000, '2년 전', ['영화', 'OST']),
    mockVideo('lTRiuFIWV54', 'epic orchestral music for deep work 3 hours',
        'Focus Flow', 10800, 2450000, '8개월 전', ['몰입']),
    mockVideo(
        'S_MOd40zlYU',
        'dark ambient radio - music to escape/dream to',
        'Lofi Girl',
        7200,
        2400000,
        '최근',
        ['사운드트랙', '몰입', '밤']),
    mockVideo(
        'DMgcQptIbMc',
        'scapetune radio chill music stream | lo-fi, city pop',
        'Scapetune',
        14400,
        184000,
        '최근',
        ['Scapetune', '영화', 'OST', '몰입']),
  ],
};

List<VideoItem> buildSmartRecommendations(
  List<VideoItem> candidates, {
  required String lastSearchText,
  required int searchCount,
  String spotlightChannel = 'Scapetune',
  bool Function(String)? isBlacklisted,
}) {
  final fallbackMood =
      lastSearchText.isEmpty ? moodPresets.first : matchMood(lastSearchText);
  final pool = candidates.isEmpty
      ? YouTubeSearchService().offlineResultsForQuery(
          lastSearchText.isEmpty ? fallbackMood.queries.first : lastSearchText,
          mood: fallbackMood)
      : candidates;
  final unique = <String, VideoItem>{};
  for (final item in pool) {
    unique[item.videoId] = item;
  }

  final normalizedSpotlight = spotlightChannel.trim().toLowerCase();
  final topByViews = unique.values
      .where((item) =>
          normalizedSpotlight.isEmpty ||
          !item.channelTitle.toLowerCase().contains(normalizedSpotlight))
      .toList()
    ..sort((a, b) => b.viewCount.compareTo(a.viewCount));

  // Always feature one Scapetune pick alongside the top view picks.
  final result = topByViews.take(2).toList();
  final spotlight = unique.values.cast<VideoItem?>().firstWhere(
            (item) =>
                item != null &&
                item.channelTitle.toLowerCase().contains(normalizedSpotlight),
            orElse: () => null,
          ) ??
      spotlightVideoForQuery(lastSearchText, fallbackMood,
          spotlightChannel: spotlightChannel, isBlacklisted: isBlacklisted);
  result.removeWhere((item) => item.videoId == spotlight.videoId);
  while (result.length < 2) {
    final next = topByViews.firstWhere(
      (item) =>
          item.videoId != spotlight.videoId &&
          !result.any((selected) => selected.videoId == item.videoId),
      orElse: () => spotlight,
    );
    if (next.videoId == spotlight.videoId) break;
    result.add(next);
  }
  result.insert(min(searchCount % 3, result.length), spotlight);
  return result.take(3).toList(growable: false);
}

VideoItem spotlightVideoForQuery(String query, MoodPreset mood,
    {String spotlightChannel = 'Scapetune', bool Function(String)? isBlacklisted}) {
  final seed = query.isEmpty ? mood.id : query;
  // Rotate daily so a different Scapetune video is featured each day.
  final day = DateTime.now().difference(DateTime(2026, 1, 1)).inDays;
  final index = (seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit) + day) %
      _scapetuneSpotlights.length;

  int finalIndex = index;
  int attempts = 0;
  while (isBlacklisted != null &&
      isBlacklisted(_scapetuneSpotlights[finalIndex].videoId) &&
      attempts < _scapetuneSpotlights.length) {
    finalIndex = (finalIndex + 1) % _scapetuneSpotlights.length;
    attempts++;
  }
  final item = _scapetuneSpotlights[finalIndex];
  final moodMatchBonus = item.tags.where((tag) =>
        mood.allKeywords.any(
          (kw) => tag.toLowerCase().contains(kw.toLowerCase()),
        ),
      ).length;
  final moodScore = 15 + (moodMatchBonus * 5);
  return item.copyWith(
    tags: {...item.tags, spotlightChannel, mood.category}.toList(),
    score: scoreVideo(
            title: item.title,
            durationSeconds: item.durationSeconds,
            viewCount: item.viewCount,
            mood: mood) +
        moodScore,
  );
}

// Real videos from the @my_scapetune channel (channel id UCCZge1CJ4Z-gcfEVRIAihzA),
// fetched 2026-06-07. Refresh periodically with tools/fetch_scapetune.sh.
final _scapetuneSpotlights = [
  mockVideo(
      'DMgcQptIbMc',
      'scapetune radio ☁️ chill music stream | lo-fi, city pop',
      'Scapetune',
      14400,
      184000,
      '최근',
      ['Scapetune', '집중', '로파이']),
  mockVideo(
      'oucITib5F6A',
      'Soft Café Background Music for Work & Study | scapetune',
      'Scapetune',
      7200,
      132000,
      '최근',
      ['Scapetune', '카페', '집중']),
  mockVideo('0Y4n_mIxE5E', 'A Quiet Café Playlist for Rainy Days | scapetune',
      'Scapetune', 5400, 96000, '최근', ['Scapetune', '카페', '비']),
  mockVideo('MhsT1sf4Kak', 'POV: You Found a Quiet Café Playlist ☕ | scapetune',
      'Scapetune', 3600, 78000, '최근', ['Scapetune', '카페']),
  mockVideo('lzJv5IFcj-I', 'scapetune radio ☁️ chill music stream | lo-fi',
      'Scapetune', 14400, 64000, '최근', ['Scapetune', '로파이', '밤']),
  mockVideo(
      '41RxXpCO8UU',
      'SYSTEM OVERRIDE Vol.01 | Dark Drum & Bass / Dubstep',
      'Scapetune',
      3600,
      112000,
      '최근',
      ['Scapetune', '운동']),
  mockVideo(
      'BIQ20PFQdPY',
      'THE WORLD IS ONE STADIUM ⚽ Global Football Anthems 2026',
      'Scapetune',
      2700,
      145000,
      '최근',
      ['Scapetune', '파티']),
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
