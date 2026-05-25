import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimetableSavedBannerWidget extends StatefulWidget {
  final int taskCount;
  final VoidCallback onDismiss;
  final VoidCallback onViewTasks;

  const TimetableSavedBannerWidget({
    super.key,
    required this.taskCount,
    required this.onDismiss,
    required this.onViewTasks,
  });

  @override
  State<TimetableSavedBannerWidget> createState() =>
      _TimetableSavedBannerWidgetState();
}

class _TimetableSavedBannerWidgetState extends State<TimetableSavedBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<double>(
      begin: -20,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D7A4F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D7A4F).withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Timetable Saved!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.taskCount} tasks added to your schedule',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withAlpha(217),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onViewTasks,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Colors.white.withAlpha(102),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'View',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: widget.onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withAlpha(179),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
