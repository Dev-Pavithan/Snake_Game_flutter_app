import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hapticServiceProvider = Provider((ref) => HapticService());

class HapticService {
  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  Future<void> heavyVibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }
}
