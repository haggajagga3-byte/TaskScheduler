import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/message_model.dart';
import '../../models/task_model.dart';
import '../../services/database_service.dart';
import '../../services/openrouter_service.dart';
import '../../theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final OpenRouterService _openRouter = OpenRouterService();
  final DatabaseService _db = DatabaseService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _requestLock = false;
  int _savedTaskCount = 0;
  bool _showSavedBanner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeConversation() async {
    if (!mounted || _requestLock) return;
    // Send a hidden initial trigger to get AI greeting
    await _sendToAI([], isInitial: true);
  }

  Future<void> _sendMessage(String text) async {
    if (_requestLock) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _inputController.clear();

    final userMsg = MessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    await _sendToAI(_messages);
  }

  Future<void> _sendToAI(
    List<MessageModel> context, {
    bool isInitial = false,
  }) async {
    _requestLock = true;

    final apiMessages = List<MessageModel>.from(context);
    if (isInitial) {
      apiMessages.add(
        MessageModel(
          id: 'init',
          role: MessageRole.user,
          content:
              'Hello! I want you to help me create a personalized daily timetable.',
          timestamp: DateTime.now(),
        ),
      );
    }

    try {
      final response = await _openRouter.sendMessage(apiMessages);

      if (!mounted) {
        _requestLock = false;
        return;
      }

      // Try to detect JSON timetable
      final parsedTasks = _tryParseTasksFromJson(response.trim());

      final assistantMsg = MessageModel(
        id: 'assistant_${DateTime.now().microsecondsSinceEpoch}',
        role: MessageRole.assistant,
        content: parsedTasks != null && parsedTasks.isNotEmpty
            ? '✅ Your personalized timetable has been created! I\'ve added ${parsedTasks.length} tasks to your schedule. Head back to the home screen to see them.'
            : response,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(assistantMsg);
        _isLoading = false;
        _requestLock = false;
      });

      if (parsedTasks != null && parsedTasks.isNotEmpty) {
        await _saveParsedTasks(parsedTasks);
      }

      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        _requestLock = false;
        return;
      }

      final errorMsg = MessageModel(
        id: 'error_${DateTime.now().microsecondsSinceEpoch}',
        role: MessageRole.assistant,
        content: '⚠️ Error: ${e.toString().replaceAll('Exception: ', '')}',
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMsg);
        _isLoading = false;
        _requestLock = false;
      });
      _scrollToBottom();
    }
  }

  List<TaskModel>? _tryParseTasksFromJson(String text) {
    if (!text.startsWith('[') && !text.startsWith('{')) return null;
    try {
      final jsonStart = text.indexOf('[');
      final jsonEnd = text.lastIndexOf(']');
      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) return null;

      final jsonStr = text.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return null;

      final tasks = <TaskModel>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final title = item['title'] as String? ?? '';
          if (title.isEmpty) continue;
          tasks.add(
            TaskModel(
              title: title,
              description: item['description'] as String? ?? '',
              category: item['category'] as String? ?? 'Study',
              startTime: item['startTime'] as String? ?? '09:00',
              endTime: item['endTime'] as String? ?? '10:00',
              day: item['day'] as String? ?? 'Today',
              createdAt: DateTime.now(),
            ),
          );
        }
      }
      return tasks.isEmpty ? null : tasks;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveParsedTasks(List<TaskModel> tasks) async {
    try {
      await _db.insertTasks(tasks);
      if (mounted) {
        setState(() {
          _savedTaskCount = tasks.length;
          _showSavedBanner = true;
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _showSavedBanner = false);
        });
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withAlpha(180),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Timetable',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Powered by AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Saved banner
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showSavedBanner
                ? Container(
                    key: const ValueKey('banner'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: AppTheme.tertiary.withAlpha(30),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.tertiary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_savedTaskCount tasks saved to your schedule!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-banner')),
          ),

          // Messages list
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 48,
                          color: theme.colorScheme.primary.withAlpha(100),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Starting AI conversation...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildTypingIndicator(theme);
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg, theme, isDark);
                    },
                  ),
          ),

          // Input bar
          _buildInputBar(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + i * 200),
                  builder: (context, value, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(
                            (value * 200).toInt(),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, ThemeData theme, bool isDark) {
    final isUser = msg.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isUser ? Colors.white : theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withAlpha(60)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              enabled: !_isLoading,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: _isLoading ? null : _sendMessage,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: _isLoading
                    ? 'AI is thinking...'
                    : 'Type your message...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
                filled: true,
                fillColor: isDark
                    ? AppTheme.surfaceVariantDark
                    : AppTheme.surfaceVariantLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: _isLoading
                ? Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => _sendMessage(_inputController.text),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
