import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/brief_analysis.dart';
import '../services/openai_service.dart';

enum AnalysisState { idle, loading, success, error }

class BriefProvider extends ChangeNotifier {
  final OpenAIService _service = OpenAIService();

  AnalysisState _state = AnalysisState.idle;
  BriefAnalysis? _analysis;
  String _errorMessage = '';
  String _apiKey = '';

  AnalysisState get state => _state;
  BriefAnalysis? get analysis => _analysis;
  String get errorMessage => _errorMessage;
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.isNotEmpty;

  BriefProvider() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(AppConstants.prefsApiKey) ?? '';
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = key.trim();
    await prefs.setString(AppConstants.prefsApiKey, _apiKey);
    notifyListeners();
  }

  Future<void> analyzeBrief(String content) async {
    _state = AnalysisState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _analysis = await _service.analyzeBrief(
        briefContent: content,
        apiKey: _apiKey,
      );
      _state = AnalysisState.success;
    } on OpenAIException catch (e) {
      _errorMessage = e.message;
      _state = AnalysisState.error;
    } catch (e) {
      _errorMessage = '${AppConstants.errUnexpected}${e.toString()}';
      _state = AnalysisState.error;
    }

    notifyListeners();
  }

  void reset() {
    _state = AnalysisState.idle;
    _analysis = null;
    _errorMessage = '';
    notifyListeners();
  }
}
