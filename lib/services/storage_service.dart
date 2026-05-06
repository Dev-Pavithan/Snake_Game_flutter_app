import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  static const String _highscoreKey = 'high_score';

  Future<int> getHighscore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highscoreKey) ?? 0;
  }

  Future<void> saveHighscore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highscoreKey, score);
  }
}
