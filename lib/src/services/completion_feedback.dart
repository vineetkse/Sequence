import 'package:flutter/services.dart';

class CompletionFeedback {
  const CompletionFeedback();

  Future<void> playSetComplete() async {
    // Cross-platform “click” system sound; avoids bundling audio assets.
    SystemSound.play(SystemSoundType.click);
    await HapticFeedback.mediumImpact();
  }
}

