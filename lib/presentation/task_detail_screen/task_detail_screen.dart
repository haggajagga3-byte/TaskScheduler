import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/task_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/status_badge_widget.dart';
import '../home_screen/widgets/add_task_bottom_sheet_widget.dart';
import './widgets/focus_mode_overlay_widget.dart';
import './widgets/task_detail_action_button_widget.dart';
import './widgets/time_pill_badge_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel? task;
  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  final DatabaseService _db = DatabaseService();
  late TaskModel _task;
  bool _focusModeEnabled = false;
  bool _isDeleting = false;
  bool _showFocusOverlay = false;

  @override
  void initState() {
    super.initState();
    _task =
        widget.task ??
        TaskModel(
          title: 'Task Not Found',
          description: '',
          category: 'Other',
          startTime: '00:00',
          endTime: '00:00',
          day: 'Today',
          createdAt: DateTime.now(),
        );
  }

  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheetWidget(
        onTaskAdded: () async {
          // Reload updated task
          final tasks = await _db.getAllTasks();
          final updated = tasks.firstWhere(
            (t) => t.id == _task.id,
            orElse: () => _task,
          );
          if (mounted) setState(() => _task = updated);
        },
        existingTask: _task,
      ),
    );
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Task',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${_task.title}"? This cannot be undone.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (_task.id == null) {
      if (mounted) context.pop();
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await _db.deleteTask(_task.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${_task.title}" removed from your schedule'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.pop(true); // pass true to signal refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
      }
    }
  }

  void _startFocusMode() {
    setState(() => _showFocusOverlay = true);
  }

  void _exitFocusMode() {
    setState(() {
      _showFocusOverlay = false;
      _focusModeEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = AppTheme.getCategoryColor(_task.category);

    return WillPopScope(
      onWillPop: () async {
        if (_showFocusOverlay) {
          // Block back navigation during focus mode
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Stack(
          children: [
            _buildMainContent(theme, categoryColor),
            if (_showFocusOverlay)
              FocusModeOverlayWidget(task: _task, onExit: _exitFocusMode),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, Color categoryColor) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close / back
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'close_rounded',
                          color: theme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Edit
                  GestureDetector(
                    onTap: _openEditSheet,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'edit_rounded',
                          color: theme.colorScheme.onSurface,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Time pill badge — centered
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Center(
                child: TimePillBadgeWidget(
                  startTime: _task.startTime,
                  endTime: _task.endTime,
                ),
              ),
            ),
          ),

          // Task title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                _task.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Description
          if (_task.description.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  _task.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Category + Day badges
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusBadgeWidget(
                    label: _task.category,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 8),
                  StatusBadgeWidget(
                    label: _task.day,
                    color: theme.colorScheme.primary.withAlpha(179),
                  ),
                  if (_task.isCompleted) ...[
                    const SizedBox(width: 8),
                    StatusBadgeWidget(
                      label: 'Completed',
                      color: AppTheme.success,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Divider(
                color: theme.colorScheme.outlineVariant,
                thickness: 1,
              ),
            ),
          ),

          // "Plan" section label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Task Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // Detail info cards (plan items style)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDetailCard(
                  theme,
                  color: categoryColor,
                  title: 'Time',
                  value: '${_task.startTime} – ${_task.endTime}',
                  iconName: 'access_time_rounded',
                ),
                const SizedBox(height: 10),
                _buildDetailCard(
                  theme,
                  color: const Color(0xFF43D9A2),
                  title: 'Category',
                  value: _task.category,
                  iconName: 'label_rounded',
                ),
                const SizedBox(height: 10),
                _buildDetailCard(
                  theme,
                  color: const Color(0xFFF59E0B),
                  title: 'Day',
                  value: _task.day,
                  iconName: 'calendar_today_rounded',
                ),
                if (_task.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildDetailCard(
                    theme,
                    color: const Color(0xFF64B5F6),
                    title: 'Description',
                    value: _task.description,
                    iconName: 'info_outline_rounded',
                  ),
                ],
              ]),
            ),
          ),

          // Focus Mode Toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildFocusModeToggle(theme),
            ),
          ),

          // Action buttons
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Start Task / Focus Mode button
                if (_focusModeEnabled)
                  TaskDetailActionButtonWidget(
                    label: 'Start Focus Mode',
                    iconName: 'timer_rounded',
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    onTap: _startFocusMode,
                  ),
                if (_focusModeEnabled) const SizedBox(height: 12),

                // Edit Task
                TaskDetailActionButtonWidget(
                  label: 'Edit Task',
                  iconName: 'edit_rounded',
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.primary,
                  onTap: _openEditSheet,
                ),
                const SizedBox(height: 12),

                // Remove Task
                TaskDetailActionButtonWidget(
                  label: _isDeleting ? 'Removing...' : 'Remove Task',
                  iconName: 'delete_outline_rounded',
                  backgroundColor: AppTheme.error.withAlpha(26),
                  foregroundColor: AppTheme.error,
                  onTap: _isDeleting ? null : _deleteTask,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    ThemeData theme, {
    required Color color,
    required String title,
    required String value,
    required String iconName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            // Show time range on right for time card
            title == 'Time' ? '${_task.startTime} - ${_task.endTime}' : '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusModeToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'lock_rounded',
                color: theme.colorScheme.primary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Mode',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Block navigation during task',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _focusModeEnabled,
            onChanged: (v) => setState(() => _focusModeEnabled = v),
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
