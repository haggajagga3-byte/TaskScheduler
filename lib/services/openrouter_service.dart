import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class OpenRouterService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _model =
      'baidu/cobuddy:free';
  static const String _apiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  static const String systemPrompt =
      '''You are a smart, conversational AI timetable planner — like a blend of ChatGPT and Motion AI. Your job is to help users build a personalized daily schedule.

Start by warmly greeting the user and asking about their goals for today or the week. Through natural conversation, gather:
- What subjects/tasks they need to work on
- How much time they have available
- Their energy levels and focus patterns
- Any deadlines or priorities
- Preferred break frequency

Ask one or two questions at a time — keep it natural and conversational. DO NOT ask a long list of questions at once.

When you have gathered enough information (usually after 4-6 exchanges), generate a timetable in this EXACT JSON format only — no other text, no markdown, just the raw JSON array:

[
  {
    "title": "Task Name",
    "description": "Brief description of what to do",
    "category": "Study",
    "startTime": "HH:MM",
    "endTime": "HH:MM",
    "day": "Monday"
  }
]

Categories must be one of: Study, Workout, Work, Personal, Other.
Times must be in 24-hour HH:MM format.
Day must be the full day name (Monday, Tuesday, etc.) or "Today".

IMPORTANT: Only output the JSON array when you are ready to generate the timetable. All other responses must be plain conversational text. Never output JSON during the conversation phase.''';

  /// Send a message using standard http.post (no streaming).
  /// Returns the AI response string or throws a descriptive error.
  Future<String> sendMessage(List<MessageModel> messages) async {
    final apiMessages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      ...messages
          .where((m) => m.role != MessageRole.system)
          .map((m) => m.toApiMap()),
    ];

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://taskschedu6442.builtwithrocket.new',
            'X-Title': 'Task Scheduler',
          },
          body: jsonEncode({
            'model': _model,
            'messages': apiMessages,
            'stream': false,
            'max_tokens': 2000,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 60));

    // Debug logging
    print('[OpenRouter] Status: ${response.statusCode}');
    print('[OpenRouter] Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final content = choices[0]['message']['content'] as String? ?? '';
        return content;
      }
      throw Exception('No choices in response');
    } else if (response.statusCode == 401) {
      throw Exception(
        '401: Invalid API Key. Please check your OpenRouter key.',
      );
    } else if (response.statusCode == 429) {
      throw Exception('429: Quota exceeded. Please wait and try again.');
    } else if (response.statusCode == 400) {
      throw Exception('400: Invalid request. ${response.body}');
    } else if (response.statusCode == 500) {
      throw Exception('500: OpenRouter server error. Try again later.');
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
