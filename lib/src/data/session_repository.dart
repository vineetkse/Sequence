import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models.dart';

class SessionRepository extends ChangeNotifier {
  SessionRepository(this._prefs);

  static const _key = 'sequence.sessions';
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  final List<SessionLog> _sessions = [];
  List<SessionLog> get sessions => List.unmodifiable(_sessions);

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    _sessions
      ..clear()
      ..addAll(raw == null ? const <SessionLog>[] : SessionLog.decodeList(raw));
    _sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    notifyListeners();
  }

  Future<void> addSession({
    required String routineId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int totalSeconds,
  }) async {
    _sessions.insert(
      0,
      SessionLog(
        id: _uuid.v4(),
        routineId: routineId,
        startedAt: startedAt,
        endedAt: endedAt,
        totalSeconds: totalSeconds,
      ),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() => _prefs.setString(_key, SessionLog.encodeList(_sessions));
}

