import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/youtube_service.dart';
import '../../theme/app_theme.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with AutomaticKeepAliveClientMixin {
  final YouTubeService _ytService = YouTubeService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Mathematics';
  List<YouTubeVideo> _videos = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  static const _categories = ['Mathematics', 'Coding', 'Science'];

  static const _categoryQueries = {
    'Mathematics': 'mathematics tutorial for students',
    'Coding': 'programming tutorial beginners',
    'Science': 'science education explained',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCategoryVideos(_selectedCategory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryVideos(String category) async {
    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });

    final query = _categoryQueries[category] ?? category;
    final results = await _ytService.searchVideos(query, maxResults: 10);

    if (mounted) {
      setState(() {
        _videos = results.isNotEmpty ? results : _getFallbackVideos(category);
        _isLoading = false;
      });
    }
  }

  Future<void> _searchVideos(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await _ytService.searchVideos(query.trim(), maxResults: 12);

    if (mounted) {
      setState(() {
        _videos = results;
        _isLoading = false;
      });
    }
  }

  List<YouTubeVideo> _getFallbackVideos(String category) {
    switch (category) {
      case 'Mathematics':
        return FallbackVideos.studyMath();
      case 'Coding':
        return FallbackVideos.studyCoding();
      case 'Science':
        return FallbackVideos.studyScience();
      default:
        return FallbackVideos.studyMath();
    }
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Study',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Learn from the best educational content',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchVideos,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search educational videos...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(100),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _loadCategoryVideos(_selectedCategory);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.surfaceVariantDark
                      : AppTheme.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category chips
            if (!_hasSearched)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        _loadCategoryVideos(cat);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark
                                    ? AppTheme.surfaceVariantDark
                                    : AppTheme.surfaceVariantLight),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withAlpha(80),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 14),

            // Videos list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _videos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withAlpha(80),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No videos found',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _videos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _VideoCard(
                          video: _videos[index],
                          onTap: () => _openVideo(_videos[index].youtubeUrl),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final YouTubeVideo video;
  final VoidCallback onTap;

  const _VideoCard({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: video.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: 110,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 110,
                        height: 80,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 28,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 110,
                        height: 80,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.video_library_rounded,
                          size: 28,
                        ),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(
                        Icons.play_circle_outline_rounded,
                        size: 28,
                      ),
                    ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.channelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withAlpha(140),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Open in YouTube',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
