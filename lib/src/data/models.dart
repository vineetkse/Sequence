import 'dart:convert';

enum RoutineKind { exercise, meditation }

RoutineKind routineKindFromString(String v) {
  switch (v) {
    case 'exercise':
      return RoutineKind.exercise;
    case 'meditation':
      return RoutineKind.meditation;
  }
  return RoutineKind.exercise;
}

String routineKindToString(RoutineKind kind) => switch (kind) {
      RoutineKind.exercise => 'exercise',
      RoutineKind.meditation => 'meditation',
    };

class RoutineStep {
  RoutineStep({
    required this.id,
    required this.name,
    required this.sets,
    required this.secondsPerSet,
  });

  final String id;
  final String name;
  final int sets;
  final int secondsPerSet;

  int get totalSeconds => sets * secondsPerSet;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'secondsPerSet': secondsPerSet,
      };

  static RoutineStep fromJson(Map<String, Object?> json) => RoutineStep(
        id: json['id'] as String,
        name: json['name'] as String,
        sets: (json['sets'] as num).toInt(),
        secondsPerSet: (json['secondsPerSet'] as num).toInt(),
      );
}

class Routine {
  Routine({
    required this.id,
    required this.title,
    required this.kind,
    required this.steps,
    required this.createdAt,
  });

  final String id;
  final String title;
  final RoutineKind kind;
  final List<RoutineStep> steps;
  final DateTime createdAt;

  int get totalSeconds => steps.fold(0, (acc, s) => acc + s.totalSeconds);

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'kind': routineKindToString(kind),
        'createdAt': createdAt.toIso8601String(),
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  static Routine fromJson(Map<String, Object?> json) => Routine(
        id: json['id'] as String,
        title: json['title'] as String,
        kind: routineKindFromString(json['kind'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        steps: (json['steps'] as List)
            .cast<Map>()
            .map((e) => RoutineStep.fromJson(e.cast<String, Object?>()))
            .toList(growable: false),
      );

  static String encodeList(List<Routine> routines) =>
      jsonEncode(routines.map((r) => r.toJson()).toList());

  static List<Routine> decodeList(String raw) {
    final data = (jsonDecode(raw) as List).cast<Map>();
    return data.map((e) => Routine.fromJson(e.cast<String, Object?>())).toList();
  }
}

class SessionLog {
  SessionLog({
    required this.id,
    required this.routineId,
    required this.startedAt,
    required this.endedAt,
    required this.totalSeconds,
  });

  final String id;
  final String routineId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int totalSeconds;

  Map<String, Object?> toJson() => {
        'id': id,
        'routineId': routineId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'totalSeconds': totalSeconds,
      };

  static SessionLog fromJson(Map<String, Object?> json) => SessionLog(
        id: json['id'] as String,
        routineId: json['routineId'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        totalSeconds: (json['totalSeconds'] as num).toInt(),
      );

  static String encodeList(List<SessionLog> sessions) =>
      jsonEncode(sessions.map((s) => s.toJson()).toList());

  static List<SessionLog> decodeList(String raw) {
    final data = (jsonDecode(raw) as List).cast<Map>();
    return data
        .map((e) => SessionLog.fromJson(e.cast<String, Object?>()))
        .toList();
  }
}

