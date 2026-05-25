import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/task_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FocusModeOverlayWidget extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onExit;

  const FocusModeOverlayWidget({
    super.key,
    required this.task,
    required this.onExit,
  });

  @override
  State<FocusModeOverlayWidget> createState() => _FocusModeOverlayWidgetState();
}

class _FocusModeOverlayWidgetState extends State<FocusModeOverlayWidget>
    with TickerProviderStateMixin {
  // TODO: Replace with [Riverpod/Bloc] for production
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Enter fullscreen / immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _confirmExit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Focus Mode?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'You have been focused for ${_formatTime(_elapsedSeconds)}. Are you sure you want to exit?',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Stay Focused',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onExit();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(widget.task.category);

    return Material(
      color: const Color(0xFF0D0D1A),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Focus Mode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(179),
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: _confirmExit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withAlpha(38),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Exit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Animated timer orb
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      categoryColor.withAlpha(102),
                      categoryColor.withAlpha(26),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                  border: Border.all(
                    color: categoryColor.withAlpha(128),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_elapsedSeconds),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        'elapsed',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withAlpha(128),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Task name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                widget.task.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(38),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: categoryColor.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Text(
                '${widget.task.startTime} – ${widget.task.endTime}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
            ),

            const Spacer(),

            // Pause / Resume button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isPaused = !_isPaused),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withAlpha(102),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: _isPaused
                              ? 'play_arrow_rounded'
                              : 'pause_rounded',
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
