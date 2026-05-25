import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './widgets/custom_error_widget.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;
      Future.delayed(const Duration(seconds: 5), () {
        hasShownError = false;
      });
      return CustomErrorWidget(errorDetails: details);
    }
    return const SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return ThemeModeNotifier(
          themeMode: _themeMode,
          onToggle: _toggleTheme,
          child: MaterialApp.router(
            title: 'Task Scheduler',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeMode,
            // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            // 🚨 END CRITICAL SECTION
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}

class ThemeModeNotifier extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggle;

  const ThemeModeNotifier({
    super.key,
    required this.themeMode,
    required this.onToggle,
    required super.child,
  });

  static ThemeModeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeNotifier>();
  }

  @override
  bool updateShouldNotify(ThemeModeNotifier oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}
