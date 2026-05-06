import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/brief_analysis.dart';

class OpenAIException implements Exception {
  final String message;
  final int? statusCode;

  const OpenAIException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class OpenAIService {
  Future<BriefAnalysis> analyzeBrief({
    required String briefContent,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const OpenAIException(AppConstants.errApiKeyRequired);
    }
    if (briefContent.trim().isEmpty) {
      throw const OpenAIException(AppConstants.errBriefEmpty);
    }

    final body = jsonEncode({
      'model': AppConstants.openAiModel,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': AppConstants.systemPrompt},
        {
          'role': 'user',
          'content': 'Analyze the following client brief:\n\n---\n$briefContent\n---',
        },
      ],
      'temperature': 0,
      'max_tokens': AppConstants.openAiMaxTokens,
    });

    final response = await http
        .post(
          Uri.parse(AppConstants.openAiBaseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(
          const Duration(seconds: AppConstants.requestTimeoutSeconds),
          onTimeout: () => throw const OpenAIException(AppConstants.errTimeout),
        );

    _assertStatus(response);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['choices'][0]['message']['content'] as String;

    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      return BriefAnalysis.fromJson(json);
    } on FormatException {
      throw const OpenAIException(AppConstants.errInvalidResponse);
    }
  }

  void _assertStatus(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;
      case 401:
        throw const OpenAIException(AppConstants.errInvalidApiKey, statusCode: 401);
      case 402:
        throw const OpenAIException(AppConstants.errInsufficientCredits, statusCode: 402);
      case 429:
        throw const OpenAIException(AppConstants.errRateLimit, statusCode: 429);
      default:
        final body = jsonDecode(response.body);
        final msg = body['error']?['message'] as String? ?? 'Unknown error.';
        throw OpenAIException('OpenAI error: $msg', statusCode: response.statusCode);
    }
  }
}
