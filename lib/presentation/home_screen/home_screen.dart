import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/task_model.dart';
import '../../routes/app_routes.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_skeleton_widget.dart';
import '../../main.dart';
import './widgets/add_task_bottom_sheet_widget.dart';
import './widgets/task_list_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final DatabaseService _db = DatabaseService();
  List<TaskModel> _todayTasks = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final tasks = await _db.getTodayTasks();
      if (mounted) {
        setState(() {
          _todayTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheetWidget(onTaskAdded: _loadTasks),
    );
  }

  void _openAIChat() {
    context.push(AppRoutes.aiChatScreen);
  }

  void _openTaskDetail(TaskModel task) {
    context.push(AppRoutes.taskDetailScreen, extra: task);
  }

  Future<void> _toggleComplete(TaskModel task) async {
    await _db.markTaskCompleted(task.id!, !task.isCompleted);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeNotifier = ThemeModeNotifier.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTasks,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  140,
                                ),
                              ),
                            ),
                            Text(
                              'Task Scheduler',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: themeNotifier?.onToggle,
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: _todayTasks.length.toString(),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        label: 'Done',
                        value: _todayTasks
                            .where((t) => t.isCompleted)
                            .length
                            .toString(),
                        color: AppTheme.tertiary,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        label: 'Pending',
                        value: _todayTasks
                            .where((t) => !t.isCompleted)
                            .length
                            .toString(),
                        color: AppTheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildActionButtons(theme),
                ),
              ),

              // Today's Tasks header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    "Today's Tasks",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Task list
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: const SliverToBoxAdapter(
                    child: TaskListSkeletonWidget(),
                  ),
                )
              else if (_todayTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: EmptyStateWidget(
                      iconName: 'task_alt_rounded',
                      title: 'No tasks yet',
                      subtitle:
                          'Create your first task manually or let AI build\na timetable for your day.',
                      buttonLabel: 'Add Manual Task',
                      onAction: _openAddTaskSheet,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = _todayTasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskListItemWidget(
                          task: task,
                          accentColor: AppTheme.getTaskAccentColor(index),
                          onTap: () => _openTaskDetail(task),
                          onToggleComplete: () => _toggleComplete(task),
                        ),
                      );
                    }, childCount: _todayTasks.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _openAddTaskSheet,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Manual Task'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openAIChat,
            icon: const Icon(Icons.auto_awesome_rounded, size: 20),
            label: const Text('Generate AI Timetable'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(
                color: theme.colorScheme.primary.withAlpha(102),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 40 : 20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
