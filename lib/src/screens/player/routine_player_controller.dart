import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models.dart';
import '../../services/completion_feedback.dart';

enum PlayerStatus { ready, running, paused, finished }

class RoutinePlayerController extends ChangeNotifier {
  RoutinePlayerController({
    required this.routine,
    required CompletionFeedback feedback,
  }) : _feedback = feedback {
    _remainingSeconds = _currentStep.secondsPerSet;
  }

  final Routine routine;
  final CompletionFeedback _feedback;

  Timer? _timer;
  DateTime? _startedAt;
  DateTime? _backgroundedAt;
  PlayerStatus _status = PlayerStatus.ready;

  int _stepIndex = 0;
  int _setIndexWithinStep = 0; // 0-based
  int _remainingSeconds = 0;

  PlayerStatus get status => _status;
  int get stepIndex => _stepIndex;
  int get setIndexWithinStep => _setIndexWithinStep;
  int get remainingSeconds => _remainingSeconds;
  DateTime? get startedAt => _startedAt;

  RoutineStep get _currentStep => routine.steps[_stepIndex];

  RoutineStep get currentStep => _currentStep;
  int get currentSetNumber => _setIndexWithinStep + 1;
  int get currentSetTotal => _currentStep.sets;

  int get totalRemainingSeconds {
    var total = _remainingSeconds;
    // remaining sets in current step (excluding current running set)
    final remainingSets = (_currentStep.sets - 1) - _setIndexWithinStep;
    total += remainingSets * _currentStep.secondsPerSet;
    // remaining steps
    for (var i = _stepIndex + 1; i < routine.steps.length; i++) {
      total += routine.steps[i].totalSeconds;
    }
    return total;
  }

  void start() {
    if (_status == PlayerStatus.running) return;
    _startedAt ??= DateTime.now();
    _status = PlayerStatus.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    if (_status != PlayerStatus.running) return;
    _status = PlayerStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> skip() async {
    if (_status == PlayerStatus.finished) return;
    await _advanceSet(playFeedback: true);
  }

  void onAppBackgrounded() {
    if (_status == PlayerStatus.running) {
      _backgroundedAt = DateTime.now();
    }
  }

  Future<void> onAppResumed() async {
    if (_status != PlayerStatus.running) return;
    final bg = _backgroundedAt;
    _backgroundedAt = null;
    if (bg == null) return;

    final deltaSeconds = DateTime.now().difference(bg).inSeconds;
    if (deltaSeconds <= 0) return;

    await fastForward(deltaSeconds);
  }

  Future<void> fastForward(int deltaSeconds) async {
    var remaining = deltaSeconds;
    while (remaining > 0 && _status == PlayerStatus.running) {
      if (remaining < _remainingSeconds) {
        _remainingSeconds -= remaining;
        remaining = 0;
        break;
      }

      remaining -= _remainingSeconds;
      await _advanceSet(playFeedback: false);
      if (_status != PlayerStatus.finished) {
        // _advanceSet resets _remainingSeconds for next set/step.
      }
    }
    notifyListeners();
  }

  Future<void> _tick() async {
    if (_status != PlayerStatus.running) return;
    _remainingSeconds -= 1;
    if (_remainingSeconds <= 0) {
      await _advanceSet(playFeedback: true);
    } else {
      notifyListeners();
    }
  }

  Future<void> _advanceSet({required bool playFeedback}) async {
    if (playFeedback) {
      await _feedback.playSetComplete();
    }

    // next set within same step
    if (_setIndexWithinStep + 1 < _currentStep.sets) {
      _setIndexWithinStep += 1;
      _remainingSeconds = _currentStep.secondsPerSet;
      notifyListeners();
      return;
    }

    // next step
    if (_stepIndex + 1 < routine.steps.length) {
      _stepIndex += 1;
      _setIndexWithinStep = 0;
      _remainingSeconds = _currentStep.secondsPerSet;
      notifyListeners();
      return;
    }

    // done
    _status = PlayerStatus.finished;
    _timer?.cancel();
    notifyListeners();
  }

  int computeCompletedSeconds() => routine.totalSeconds - totalRemainingSeconds;

  void disposeController() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

