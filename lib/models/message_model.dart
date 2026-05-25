enum MessageRole { user, assistant, system }

class MessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  const MessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  MessageModel copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toApiMap() {
    return {'role': _roleToString(role), 'content': content};
  }

  static String _roleToString(MessageRole role) {
    switch (role) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String? ?? DateTime.now().toIso8601String(),
      role: _roleFromString(map['role'] as String? ?? 'user'),
      content: map['content'] as String? ?? '',
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static MessageRole _roleFromString(String v) {
    switch (v) {
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': _roleToString(role),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
