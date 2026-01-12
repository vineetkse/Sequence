import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

class RoutineRepository extends ChangeNotifier {
  RoutineRepository(this._prefs);

  static const _key = 'sequence.routines';
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  final List<Routine> _routines = [];
  List<Routine> get routines => List.unmodifiable(_routines);

  Routine? byId(String id) {
    for (final r in _routines) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    _routines
      ..clear()
      ..addAll(raw == null ? const <Routine>[] : Routine.decodeList(raw));
    _routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Seed with a nice example on first launch.
    if (_routines.isEmpty) {
      final now = DateTime.now();
      _routines.add(
        Routine(
          id: _uuid.v4(),
          title: 'Morning Flow',
          kind: RoutineKind.exercise,
          createdAt: now,
          steps: [
            RoutineStep(id: _uuid.v4(), name: 'Warm up', sets: 2, secondsPerSet: 30),
            RoutineStep(id: _uuid.v4(), name: 'Breathing', sets: 3, secondsPerSet: 20),
          ],
        ),
      );
      await _persist();
    }

    notifyListeners();
  }

  Future<void> upsertRoutine({
    required String? id,
    required String title,
    required RoutineKind kind,
    required List<RoutineStep> steps,
  }) async {
    final now = DateTime.now();
    final routine = Routine(
      id: id ?? _uuid.v4(),
      title: title.trim(),
      kind: kind,
      steps: steps,
      createdAt: now,
    );

    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index == -1) {
      _routines.insert(0, routine);
    } else {
      _routines[index] = routine;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() => _prefs.setString(_key, Routine.encodeList(_routines));
}

