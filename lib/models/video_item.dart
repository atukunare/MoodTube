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

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  String get durationText {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    return '${minutes}m';
  }

  String get viewsText {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    }
    if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    }
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

extension VideoItemCopyWith on VideoItem {
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
