import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'package:moodtube/data/mock_catalog.dart';
import 'package:moodtube/models/mood_preset.dart';
import 'package:moodtube/models/video_item.dart';

// Max YouTube Data API searches per device per day. Beyond this the app uses
// only the internal catalog, so the shared API quota stays under control.
const kDailyApiSearchLimit = 12;

// HTTP request timeout for YouTube API calls.
const kHttpTimeout = Duration(seconds: 15);

/// Throws an Exception if no network connectivity is available.
Future<void> _requireNetwork() async {
  final result = await Connectivity().checkConnectivity();
  final hasConnection = result.any((r) =>
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet);
  if (!hasConnection) {
    throw Exception('No internet connection');
  }
}

// Injected at build time via --dart-define=YOUTUBE_API_KEY=... or
// --dart-define-from-file=dart_defines.json (see dart_defines.json.example).
// Empty in the public source tree; without a key the app uses mockCatalog only.
const kBundledYouTubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');

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
          // Use the offline Scapetune catalog for the spotlight slot so each
          // Explore search spends only one search.list unit (not two +
          // channels.list). Keeps the shared YouTube quota under control.
          final spotlight = spotlightVideoForQuery(query, mood,
              spotlightChannel: spotlightChannel);
          return _mergeResults([...results, spotlight])
            ..sort((a, b) => b.score.compareTo(a.score));
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
    // Atmosphere moods (mood_*) map to several activity catalogs; activity
    // moods use their own catalog entry.
    final moodKeys = atmosphereToActivities[matchedMood.id] ?? [matchedMood.id];
    final moodVideoIds = moodKeys
        .expand((k) => mockCatalog[k] ?? const <VideoItem>[])
        .map((item) => item.videoId)
        .toSet();
    final allItems =
        _mergeResults(mockCatalog.values.expand((items) => items).toList());
    final scored = allItems.map((item) {
      final baseScore = scoreVideo(
        title: item.title,
        durationSeconds: item.durationSeconds,
        viewCount: item.viewCount,
        mood: matchedMood,
      );
      final queryScore = _queryScore(item, query) +
          _queryScore(item, matchedMood.queries.first);
      final moodBoost = moodVideoIds.contains(item.videoId) ? 180 : 0;
      return item.copyWith(
        tags: {...item.tags, matchedMood.category}.toList(),
        score: baseScore + queryScore + moodBoost,
      );
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    if (includeSpotlight) {
      final spotlight = spotlightVideoForQuery(query, matchedMood,
          spotlightChannel: spotlightChannel);
      scored.insert(min(searchCount % 3, scored.length), spotlight);
    }
    return _mergeResults(scored).take(12).toList();
  }

  Future<http.Response> _retryGet(Uri uri, {int maxAttempts = 3}) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        await _requireNetwork();
        final response = await http.get(uri).timeout(kHttpTimeout);
        // Retry on transient 5xx server errors or 429 rate limit errors
        if ((response.statusCode >= 500 || response.statusCode == 429) &&
            attempts < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempts));
          continue;
        }
        return response;
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
  }

  Future<List<VideoItem>> _searchApiQuery({
    required String query,
    required String apiKey,
    required MoodPreset mood,
    required String sourceQuery,
    String? preferredChannel,
    int maxResults = 15,
  }) async {
    final params = <String, String>{
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'videoEmbeddable': 'true',
      'maxResults': '$maxResults',
      'key': apiKey,
    };
    final searchUri =
        Uri.https('www.googleapis.com', '/youtube/v3/search', params);
    final searchResponse = await _retryGet(searchUri);
    if (searchResponse.statusCode != 200) {
      throw Exception('YouTube search failed');
    }
    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
    final items = List<Map<String, dynamic>>.from(searchJson['items'] as List);
    final ids = items.map((item) => item['id']['videoId'] as String).join(',');
    if (ids.isEmpty) return [];

    final videosUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'snippet,contentDetails,statistics',
      'id': ids,
      'key': apiKey,
    });
    final videosResponse = await _retryGet(videosUri);
    if (videosResponse.statusCode != 200) {
      throw Exception('YouTube videos failed');
    }
    final videosJson = jsonDecode(videosResponse.body) as Map<String, dynamic>;
    final videos = List<Map<String, dynamic>>.from(videosJson['items'] as List);

    final mapped = videos
        .map((video) {
          final snippet = video['snippet'] as Map<String, dynamic>;
          final stats = video['statistics'] as Map<String, dynamic>;
          final details = video['contentDetails'] as Map<String, dynamic>;
          final duration = _parseIsoDuration(details['duration'] as String);
          final views =
              int.tryParse(stats['viewCount']?.toString() ?? '0') ?? 0;
          final title = snippet['title'] as String;
          final channelTitle = snippet['channelTitle'] as String;
          final preferredBoost = preferredChannel != null &&
                  channelTitle
                      .toLowerCase()
                      .contains(preferredChannel.toLowerCase())
              ? 120
              : 0;
          return VideoItem(
            videoId: video['id'] as String,
            title: title,
            channelTitle: channelTitle,
            durationSeconds: duration,
            viewCount: views,
            publishedText: _publishedLabel(snippet['publishedAt'] as String),
            tags: mood.koreanKeywords.take(2).toList(),
            score: scoreVideo(
                    title: title,
                    durationSeconds: duration,
                    viewCount: views,
                    mood: mood) +
                _queryScoreTitle(title, sourceQuery) +
                preferredBoost,
          );
        })
        .where((item) => item.durationSeconds >= 300 && item.score > -10)
        .toList()
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

  int _queryScore(VideoItem item, String query) => _queryScoreTitle(
      '${item.title} ${item.channelTitle} ${item.tags.join(' ')}', query);

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
    final match =
        RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(value);
    if (match == null) return 0;
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    return hours * 3600 + minutes * 60 + seconds;
  }

  /// Locale-neutral relative labels. [AppText.published] formats these for
  /// ko/en/zh. Catalog entries still use Korean tokens; both are supported.
  String _publishedLabel(String publishedAt) {
    final date = DateTime.tryParse(publishedAt);
    if (date == null) return 'rel:unknown';
    final days = DateTime.now().difference(date).inDays;
    final years = max(0, days ~/ 365);
    if (years > 0) return 'rel:y:$years';
    final months = max(1, days ~/ 30);
    return 'rel:m:$months';
  }
}
