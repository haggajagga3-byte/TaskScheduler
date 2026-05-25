import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';

class BlockAppsScreen extends StatefulWidget {
  const BlockAppsScreen({super.key});

  @override
  State<BlockAppsScreen> createState() => _BlockAppsScreenState();
}

class _BlockAppsScreenState extends State<BlockAppsScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, bool> _blockedApps = {};
  bool _isLoading = true;

  static const _storageKey = 'blocked_apps';

  static const List<_AppItem> _socialApps = [
    _AppItem(
      name: 'Instagram',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFFE1306C),
    ),
    _AppItem(
      name: 'Facebook',
      icon: Icons.facebook_rounded,
      color: Color(0xFF1877F2),
    ),
    _AppItem(
      name: 'TikTok',
      icon: Icons.music_note_rounded,
      color: Color(0xFF010101),
    ),
    _AppItem(
      name: 'Snapchat',
      icon: Icons.camera_rounded,
      color: Color(0xFFFFFC00),
    ),
    _AppItem(
      name: 'Twitter/X',
      icon: Icons.tag_rounded,
      color: Color(0xFF1DA1F2),
    ),
    _AppItem(
      name: 'WhatsApp',
      icon: Icons.chat_rounded,
      color: Color(0xFF25D366),
    ),
  ];

  static const List<_AppItem> _entertainmentApps = [
    _AppItem(
      name: 'YouTube',
      icon: Icons.play_circle_rounded,
      color: Color(0xFFFF0000),
    ),
    _AppItem(
      name: 'Netflix',
      icon: Icons.movie_rounded,
      color: Color(0xFFE50914),
    ),
    _AppItem(
      name: 'Spotify',
      icon: Icons.music_video_rounded,
      color: Color(0xFF1DB954),
    ),
    _AppItem(
      name: 'Reddit',
      icon: Icons.forum_rounded,
      color: Color(0xFFFF4500),
    ),
    _AppItem(
      name: 'Twitch',
      icon: Icons.live_tv_rounded,
      color: Color(0xFF9146FF),
    ),
    _AppItem(
      name: 'Discord',
      icon: Icons.headset_rounded,
      color: Color(0xFF5865F2),
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBlockedApps();
  }

  Future<void> _loadBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    final map = <String, bool>{};
    for (final app in [..._socialApps, ..._entertainmentApps]) {
      map[app.name] = saved.contains(app.name);
    }
    if (mounted) {
      setState(() {
        _blockedApps = map;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleApp(String appName) async {
    final newValue = !(_blockedApps[appName] ?? false);
    setState(() => _blockedApps[appName] = newValue);

    final prefs = await SharedPreferences.getInstance();
    final blocked = _blockedApps.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    await prefs.setStringList(_storageKey, blocked);
  }

  int get _blockedCount => _blockedApps.values.where((v) => v).length;

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Block Apps',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stay focused by blocking distracting apps',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Stats card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withAlpha(200),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$_blockedCount apps blocked',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _blockedCount > 0
                                            ? 'Focus mode is active'
                                            : 'Toggle apps below to block them',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Social Media section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Text(
                        'Social Media',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final app = _socialApps[index];
                        return _AppToggleTile(
                          app: app,
                          isBlocked: _blockedApps[app.name] ?? false,
                          onToggle: () => _toggleApp(app.name),
                        );
                      }, childCount: _socialApps.length),
                    ),
                  ),

                  // Entertainment section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Text(
                        'Entertainment',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final app = _entertainmentApps[index];
                        return _AppToggleTile(
                          app: app,
                          isBlocked: _blockedApps[app.name] ?? false,
                          onToggle: () => _toggleApp(app.name),
                        );
                      }, childCount: _entertainmentApps.length),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AppToggleTile extends StatelessWidget {
  final _AppItem app;
  final bool isBlocked;
  final VoidCallback onToggle;

  const _AppToggleTile({
    required this.app,
    required this.isBlocked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBlocked
                ? theme.colorScheme.primary.withAlpha(80)
                : theme.colorScheme.outline.withAlpha(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 20 : 8),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: app.color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(app.icon, color: app.color, size: 22),
          ),
          title: Text(
            app.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            isBlocked ? 'Blocked during focus' : 'Not blocked',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: isBlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(120),
            ),
          ),
          trailing: Switch(
            value: isBlocked,
            onChanged: (_) => onToggle(),
            activeThumbColor: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _AppItem {
  final String name;
  final IconData icon;
  final Color color;
  const _AppItem({required this.name, required this.icon, required this.color});
}
