import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../theme/app_theme.dart';

class ChatInputBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSend;
  final bool isStreaming;

  const ChatInputBarWidget({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isStreaming,
  });

  @override
  State<ChatInputBarWidget> createState() => _ChatInputBarWidgetState();
}

class _ChatInputBarWidgetState extends State<ChatInputBarWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom > 0
            ? 12
            : MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(77),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isStreaming,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: widget.isStreaming
                      ? 'AI is thinking...'
                      : 'Message AI Planner...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                onSubmitted: widget.isStreaming ? null : (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: widget.isStreaming ? null : _handleSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (_hasText && !widget.isStreaming)
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: widget.isStreaming
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'send_rounded',
                          color: (_hasText && !widget.isStreaming)
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
