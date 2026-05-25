import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/ai_chat_screen/ai_chat_screen.dart';
import '../presentation/task_detail_screen/task_detail_screen.dart';
import '../presentation/study_screen/study_screen.dart';
import '../presentation/workout_screen/workout_screen.dart';
import '../presentation/block_apps_screen/block_apps_screen.dart';
import '../widgets/app_scaffold.dart';
import '../models/task_model.dart';

class AppRoutes {
  static const String initial = '/';
  static const String aiChatScreen = '/ai-chat-screen';
  static const String taskDetailScreen = '/task-detail-screen';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.initial,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/study',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: StudyScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/workout',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: WorkoutScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/block-apps',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: BlockAppsScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.aiChatScreen,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AiChatScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: AppRoutes.taskDetailScreen,
      pageBuilder: (context, state) {
        final task = state.extra as TaskModel?;
        return CustomTransitionPage(
          key: state.pageKey,
          child: TaskDetailScreen(task: task),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
  ],
);
