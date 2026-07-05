import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moodtube/data/mock_catalog.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';
import 'package:moodtube/services/search_service.dart';

class MoodTubeState extends ChangeNotifier {
  final YouTubeSearchService searchService = YouTubeSearchService();
  final List<VideoItem> _saved = [];
  final Map<String, int> _moodSearchCounts = {};
  final List<String> _recentSearches = [];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<VideoItem> _lastSearchResults = [];
  VideoItem? currentPlaying;
  int homeRefreshSeed = 0;
  bool apiMode =
      true; // use the YouTube API (gated by daily cap), else internal
  String apiKey = kBundledYouTubeApiKey;
  String smartPinnedChannel = 'Scapetune';
  // YouTube API daily budget (per device). App is internal-catalog-first.
  int apiSearchesToday = 0;
  String apiSearchDate = '';
  String languageCode = 'auto';
  ThemeMode themeMode = ThemeMode.system;
  String lastSearchText = '';
  int searchCount = 0;
  // v0.1.3: A/B badge copy variant ('A' = Featured, 'B' = mood channel).
  // Assigned randomly once on first load and persisted.
  String badgeVariant = 'A';
  int _miniPlayerResumeToken = 0;
  final Set<String> _blacklistedVideoIds = {};

  List<VideoItem> get saved => List.unmodifiable(_saved);
  int get miniPlayerResumeToken => _miniPlayerResumeToken;
  List<String> get blacklistedVideoIds => _blacklistedVideoIds.toList();

  bool isBlacklisted(String videoId) => _blacklistedVideoIds.contains(videoId);

  Future<void> blacklistVideo(String videoId) async {
    if (_blacklistedVideoIds.add(videoId)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'blacklistedVideoIds', _blacklistedVideoIds.toList());
      // 만약 현재 재생 중인 곡이 블랙리스트에 추가되면 재생 중지
      if (currentPlaying?.videoId == videoId) {
        clearCurrentPlaying();
      }
      notifyListeners();
    }
  }

  Future<void> clearBlacklist() async {
    if (_blacklistedVideoIds.isNotEmpty) {
      _blacklistedVideoIds.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('blacklistedVideoIds');
      notifyListeners();
    }
  }

  List<VideoItem> get smartRecommendations {
    final candidates = _lastSearchResults.isNotEmpty
        ? _lastSearchResults
        : searchService.offlineResultsForQuery(
            lastSearchText.isEmpty ? 'study focus' : lastSearchText,
            mood: lastSearchText.isEmpty
                ? moodPresets.first
                : matchMood(lastSearchText),
            includeSpotlight: shouldShowSpotlight,
            spotlightChannel: smartPinnedChannel,
          );
    final filtered = candidates
        .where((item) => !_blacklistedVideoIds.contains(item.videoId))
        .toList();
    return buildSmartRecommendations(
      filtered,
      lastSearchText: lastSearchText,
      searchCount: searchCount,
      spotlightChannel: smartPinnedChannel,
      isBlacklisted: isBlacklisted,
    );
  }

  // Always surface a Scapetune pick (the user's own channel) — even on the
  // first open before any search.
  bool get shouldShowSpotlight => true;
  Locale? get appLocale => languageCode == 'auto' ? null : Locale(languageCode);

  List<MoodPreset> get homeMoodPresets {
    final ordered = [...moodPresets];
    ordered.sort((a, b) {
      final countCompare = (_moodSearchCounts[b.id] ?? 0)
          .compareTo(_moodSearchCounts[a.id] ?? 0);
      if (countCompare != 0) return countCompare;
      final aIndex = moodPresets.indexOf(a);
      final bIndex = moodPresets.indexOf(b);
      if ((_moodSearchCounts[a.id] ?? 0) == 0 &&
          (_moodSearchCounts[b.id] ?? 0) == 0) {
        return ((aIndex + homeRefreshSeed) % moodPresets.length)
            .compareTo((bIndex + homeRefreshSeed) % moodPresets.length);
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

  void requestMiniPlayerResume(VideoItem item) {
    if (currentPlaying?.videoId != item.videoId) return;
    _miniPlayerResumeToken += 1;
    notifyListeners();
  }

  String effectiveLanguageCode(Locale locale) {
    if (languageCode == 'ko') return 'ko';
    if (languageCode == 'en') return 'en';
    if (languageCode == 'zh') return 'zh';
    // auto: follow device language
    final code = locale.languageCode;
    if (code == 'ko') return 'ko';
    if (code == 'zh') return 'zh';
    return 'en';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    apiMode = prefs.getBool('apiMode') ?? true;
    apiKey = prefs.getString('apiKey') ?? kBundledYouTubeApiKey;
    apiSearchDate = prefs.getString('apiSearchDate') ?? '';
    apiSearchesToday = prefs.getInt('apiSearchesToday') ?? 0;
    smartPinnedChannel =
        prefs.getString('smartPinnedChannel') ?? smartPinnedChannel;
    languageCode = prefs.getString('languageCode') ?? 'auto';
    themeMode = _themeModeFromString(prefs.getString('themeMode'));
    lastSearchText = prefs.getString('lastSearchText') ?? '';
    searchCount = prefs.getInt('searchCount') ?? 0;
    _moodSearchCounts
      ..clear()
      ..addAll(_decodeSearchCounts(prefs.getString('moodSearchCounts')));
    final raw = prefs.getStringList('savedItems') ?? [];
    _saved
      ..clear()
      ..addAll(raw.map((item) => VideoItem.fromJson(jsonDecode(item))));
    _recentSearches
      ..clear()
      ..addAll(prefs.getStringList('recentSearches') ?? []);
    _blacklistedVideoIds
      ..clear()
      ..addAll(prefs.getStringList('blacklistedVideoIds') ?? []);
    var bv = prefs.getString('badgeVariant');
    if (bv == null) {
      bv = Random().nextBool() ? 'A' : 'B';
      await prefs.setString('badgeVariant', bv);
    }
    badgeVariant = bv;
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

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
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
    HapticFeedback.lightImpact();
    if (isSaved(item.videoId)) {
      _saved.removeWhere((savedItem) => savedItem.videoId == item.videoId);
    } else {
      _saved.insert(0, item);
    }
    await _persistSaved();
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;
    _recentSearches.remove(text);
    _recentSearches.insert(0, text);
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', _recentSearches);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', []);
    notifyListeners();
  }

  Future<List<VideoItem>> searchMoodAndRemember(MoodPreset mood) async {
    await _rememberSearch(mood.queries.first, mood);
    // Mood browsing/dial play stays on the curated internal catalog (no API
    // call) to conserve the shared quota. Only free-text Explore search uses
    // the YouTube API (see searchTextAndRemember).
    final results = await searchService.searchMood(
      mood: mood,
      apiMode: false,
      apiKey: apiKey,
      includeSpotlight: shouldShowSpotlight,
      searchCount: searchCount,
      spotlightChannel: smartPinnedChannel,
    );
    final filtered = results
        .where((item) => !_blacklistedVideoIds.contains(item.videoId))
        .toList();
    _lastSearchResults = filtered;
    notifyListeners();
    return filtered;
  }

  Future<void> rollbackApiCall() async {
    if (apiSearchesToday > 0) {
      apiSearchesToday -= 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('apiSearchesToday', apiSearchesToday);
      notifyListeners();
    }
  }

  Future<List<VideoItem>> searchTextAndRemember(String rawText) async {
    final query =
        rawText.trim().isEmpty ? 'study focus playlist' : rawText.trim();
    final mood = matchMood(query);
    await _rememberSearch(query, mood);
    if (rawText.trim().isNotEmpty) {
      await addRecentSearch(rawText.trim());
    }
    final useApi = await _allowApiCall();
    List<VideoItem> results = [];
    try {
      results = await searchService.searchText(
        query: query,
        mood: mood,
        apiMode: useApi,
        apiKey: apiKey,
        includeSpotlight: shouldShowSpotlight,
        searchCount: searchCount,
        spotlightChannel: smartPinnedChannel,
      );
      if (useApi && results.isEmpty) {
        await rollbackApiCall();
      }
    } catch (_) {
      if (useApi) {
        await rollbackApiCall();
      }
      rethrow;
    }
    final filtered = results
        .where((item) => !_blacklistedVideoIds.contains(item.videoId))
        .toList();
    _lastSearchResults = filtered;
    notifyListeners();
    return filtered;
  }

  // App defaults to the internal catalog. The YouTube API is only ever used
  // when API mode is on AND a key is set AND today's call budget isn't spent.
  // This caps per-device API usage so the shared quota can't be blown.
  Future<bool> _allowApiCall() async {
    if (!apiMode || apiKey.isEmpty) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (apiSearchDate != today) {
      apiSearchDate = today;
      apiSearchesToday = 0;
    }
    if (apiSearchesToday >= kDailyApiSearchLimit) return false;
    apiSearchesToday += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiSearchDate', apiSearchDate);
    await prefs.setInt('apiSearchesToday', apiSearchesToday);
    return true;
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

  // ── v0.1.3: Local tracking ──
  static const String _trackingKey = 'moodtube_tracking';

  Future<Map<String, Map<String, dynamic>>> _loadTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_trackingKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
          (k, v) => MapEntry(k, (v as Map<String, dynamic>).cast<String, dynamic>()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveTracking(Map<String, Map<String, dynamic>> data) async {
    // Keep tracking database under 50 items to avoid shared preferences storage bloat
    if (data.length > 50) {
      final sortedKeys = data.keys.toList()
        ..sort((a, b) {
          final aTime = data[a]?['lastImpression'] as String? ?? '';
          final bTime = data[b]?['lastImpression'] as String? ?? '';
          return aTime.compareTo(bTime);
        });
      while (data.length > 50 && sortedKeys.isNotEmpty) {
        data.remove(sortedKeys.removeAt(0));
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trackingKey, jsonEncode(data));
  }

  Future<void> trackImpression(String videoId, String channelTitle,
      {String source = 'smart_pick'}) async {
    if (channelTitle != 'Scapetune') return;
    final data = await _loadTracking();
    final now = DateTime.now().toIso8601String();
    final record = data.putIfAbsent(videoId, () => {
      'videoId': videoId,
      'channel': channelTitle,
      'impressions': 0,
      'clicks': 0,
      'ctr': 0.0,
      'lastImpression': now,
      'source': source,
    });
    record['impressions'] = (record['impressions'] as int) + 1;
    record['lastImpression'] = now;
    final clicks = record['clicks'] as int;
    final impressions = record['impressions'] as int;
    record['ctr'] = impressions > 0 ? clicks / impressions : 0.0;
    await _saveTracking(data);
  }

  Future<void> trackClick(String videoId, String channelTitle,
      {String source = 'smart_pick'}) async {
    if (channelTitle != 'Scapetune') return;
    final data = await _loadTracking();
    final now = DateTime.now().toIso8601String();
    final record = data.putIfAbsent(videoId, () => {
      'videoId': videoId,
      'channel': channelTitle,
      'impressions': 0,
      'clicks': 0,
      'ctr': 0.0,
      'lastImpression': now,
      'source': source,
    });
    record['clicks'] = (record['clicks'] as int) + 1;
    record['lastImpression'] = now;
    final clicks = record['clicks'] as int;
    final impressions = record['impressions'] as int;
    record['ctr'] = impressions > 0 ? clicks / impressions : 0.0;
    await _saveTracking(data);
  }

  Future<Map<String, Map<String, dynamic>>> getTrackingData() async {
    return _loadTracking();
  }
}
