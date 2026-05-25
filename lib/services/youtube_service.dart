import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String description;

  const YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.description,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  factory YouTubeVideo.fromMap(Map<String, dynamic> map) {
    final snippet = map['snippet'] as Map<String, dynamic>? ?? {};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final medium =
        (thumbnails['medium'] ?? thumbnails['default'])
            as Map<String, dynamic>? ??
        {};
    final idMap = map['id'] as Map<String, dynamic>? ?? {};

    return YouTubeVideo(
      videoId: idMap['videoId'] as String? ?? '',
      title: snippet['title'] as String? ?? 'Untitled',
      channelTitle: snippet['channelTitle'] as String? ?? '',
      thumbnailUrl: medium['url'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
    );
  }
}

class YouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';
  static const String _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  Future<List<YouTubeVideo>> searchVideos(
    String query, {
    int maxResults = 12,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': maxResults.toString(),
          'key': _apiKey,
          'safeSearch': 'strict',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map((item) => YouTubeVideo.fromMap(item as Map<String, dynamic>))
            .where((v) => v.videoId.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

// Static fallback videos for when API is unavailable
class FallbackVideos {
  static List<YouTubeVideo> studyMath() => [
    const YouTubeVideo(
      videoId: 'OmJ-4B-mS-Y',
      title: 'Algebra Basics: What Is Algebra?',
      channelTitle: 'Math Antics',
      thumbnailUrl: 'https://i.ytimg.com/vi/OmJ-4B-mS-Y/mqdefault.jpg',
      description: 'Learn algebra fundamentals',
    ),
    const YouTubeVideo(
      videoId: 'NybHckSEQBI',
      title: 'Calculus 1 - Full College Course',
      channelTitle: 'freeCodeCamp.org',
      thumbnailUrl: 'https://i.ytimg.com/vi/NybHckSEQBI/mqdefault.jpg',
      description: 'Complete calculus course',
    ),
    const YouTubeVideo(
      videoId: 'WUvTyaaNkzM',
      title: 'The Map of Mathematics',
      channelTitle: 'Domain of Science',
      thumbnailUrl: 'https://i.ytimg.com/vi/WUvTyaaNkzM/mqdefault.jpg',
      description: 'Overview of all mathematics',
    ),
  ];

  static List<YouTubeVideo> studyCoding() => [
    const YouTubeVideo(
      videoId: 'rfscVS0vtbw',
      title: 'Learn Python - Full Course for Beginners',
      channelTitle: 'freeCodeCamp.org',
      thumbnailUrl: 'https://i.ytimg.com/vi/rfscVS0vtbw/mqdefault.jpg',
      description: 'Complete Python tutorial',
    ),
    const YouTubeVideo(
      videoId: 'PkZNo7MFNFg',
      title: 'Learn JavaScript - Full Course for Beginners',
      channelTitle: 'freeCodeCamp.org',
      thumbnailUrl: 'https://i.ytimg.com/vi/PkZNo7MFNFg/mqdefault.jpg',
      description: 'Complete JavaScript tutorial',
    ),
    const YouTubeVideo(
      videoId: 'qw--VYLpxG4',
      title: 'Flutter Tutorial for Beginners',
      channelTitle: 'Net Ninja',
      thumbnailUrl: 'https://i.ytimg.com/vi/qw--VYLpxG4/mqdefault.jpg',
      description: 'Learn Flutter development',
    ),
  ];

  static List<YouTubeVideo> studyScience() => [
    const YouTubeVideo(
      videoId: 'OWXoRSIxyIU',
      title: 'Quantum Physics for Beginners',
      channelTitle: 'Kurzgesagt',
      thumbnailUrl: 'https://i.ytimg.com/vi/OWXoRSIxyIU/mqdefault.jpg',
      description: 'Introduction to quantum physics',
    ),
    const YouTubeVideo(
      videoId: 'Xc4xYacTu-E',
      title: 'Biology: Cell Structure',
      channelTitle: 'Nucleus Medical Media',
      thumbnailUrl: 'https://i.ytimg.com/vi/Xc4xYacTu-E/mqdefault.jpg',
      description: 'Cell biology explained',
    ),
    const YouTubeVideo(
      videoId: 'ZihywtixUYo',
      title: 'Chemistry: Periodic Table Explained',
      channelTitle: 'TED-Ed',
      thumbnailUrl: 'https://i.ytimg.com/vi/ZihywtixUYo/mqdefault.jpg',
      description: 'Understanding the periodic table',
    ),
  ];

  static List<YouTubeVideo> workoutBeginner() => [
    const YouTubeVideo(
      videoId: 'UItWltVZZmE',
      title: '10 Min Beginner Workout - No Equipment',
      channelTitle: 'FitnessBlender',
      thumbnailUrl: 'https://i.ytimg.com/vi/UItWltVZZmE/mqdefault.jpg',
      description: 'Beginner full body workout',
    ),
    const YouTubeVideo(
      videoId: 'cbKkB3POqaY',
      title: '20 Min Full Body Workout - Beginner',
      channelTitle: 'MommaStrong',
      thumbnailUrl: 'https://i.ytimg.com/vi/cbKkB3POqaY/mqdefault.jpg',
      description: '20 minute beginner workout',
    ),
  ];

  static List<YouTubeVideo> workoutHome() => [
    const YouTubeVideo(
      videoId: 'oAPCPjnU1wA',
      title: '30 Min Home Workout - No Equipment',
      channelTitle: 'POPSUGAR Fitness',
      thumbnailUrl: 'https://i.ytimg.com/vi/oAPCPjnU1wA/mqdefault.jpg',
      description: 'Home workout no equipment needed',
    ),
    const YouTubeVideo(
      videoId: 'vc1E5CfRfos',
      title: 'Full Body Home Workout',
      channelTitle: 'Chloe Ting',
      thumbnailUrl: 'https://i.ytimg.com/vi/vc1E5CfRfos/mqdefault.jpg',
      description: 'Complete home workout routine',
    ),
  ];

  static List<YouTubeVideo> workoutAdvanced() => [
    const YouTubeVideo(
      videoId: 'U9kFQCpKkAk',
      title: 'Advanced HIIT Workout - 45 Minutes',
      channelTitle: 'FitnessBlender',
      thumbnailUrl: 'https://i.ytimg.com/vi/U9kFQCpKkAk/mqdefault.jpg',
      description: 'High intensity interval training',
    ),
    const YouTubeVideo(
      videoId: 'ml6cT4AZdqI',
      title: 'Advanced Strength Training',
      channelTitle: 'AthleanX',
      thumbnailUrl: 'https://i.ytimg.com/vi/ml6cT4AZdqI/mqdefault.jpg',
      description: 'Advanced strength training program',
    ),
  ];
}
