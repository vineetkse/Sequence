import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/models.dart';

class NotificationService extends ChangeNotifier {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool get ready => _ready;

  static const _channelId = 'sequence_set_complete';
  static const _channelName = 'Set completion';
  static const _channelDescription = 'Plays a sound when a set completes.';

  Future<void> init() async {
    tz.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    const settings = InitializationSettings(android: android, iOS: darwin, macOS: darwin, linux: linux);

    await _plugin.initialize(settings);

    await _createAndroidChannel();
    await requestPermissions();

    _ready = true;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, sound: true, badge: false);

    final macos = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    await macos?.requestPermissions(alert: true, sound: true, badge: false);
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Schedules a sound notification for each upcoming set completion.
  ///
  /// Note: there are OS-level caps on the number of scheduled notifications;
  /// we keep it bounded.
  Future<void> scheduleSetCompletions({
    required Routine routine,
    required int stepIndex,
    required int setIndexWithinStep,
    required int remainingSecondsInCurrentSet,
    DateTime? now,
  }) async {
    if (!_ready) return;

    final baseNow = now ?? DateTime.now();
    final plan = _buildUpcomingSetPlan(
      routine: routine,
      stepIndex: stepIndex,
      setIndexWithinStep: setIndexWithinStep,
      remainingSecondsInCurrentSet: remainingSecondsInCurrentSet,
    );

    // Keep it safe (Android AlarmManager/iOS pending list can be capped).
    const maxNotifs = 96;
    final bounded = plan.take(maxNotifs).toList(growable: false);

    final rnd = Random(baseNow.millisecondsSinceEpoch);
    for (final item in bounded) {
      final id = 100000 + rnd.nextInt(900000);
      final when = baseNow.add(Duration(seconds: item.secondsFromNow));
      await _plugin.zonedSchedule(
        id,
        routine.title,
        '${item.stepName} • Set ${item.setNumber}/${item.setTotal}',
        tz.TZDateTime.from(when, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(presentSound: true),
          macOS: const DarwinNotificationDetails(presentSound: true),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> _createAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
      ),
    );
  }
}

class _SetPlanItem {
  const _SetPlanItem({
    required this.secondsFromNow,
    required this.stepName,
    required this.setNumber,
    required this.setTotal,
  });

  final int secondsFromNow;
  final String stepName;
  final int setNumber;
  final int setTotal;
}

List<_SetPlanItem> _buildUpcomingSetPlan({
  required Routine routine,
  required int stepIndex,
  required int setIndexWithinStep,
  required int remainingSecondsInCurrentSet,
}) {
  final out = <_SetPlanItem>[];
  var t = max(1, remainingSecondsInCurrentSet);

  for (var si = stepIndex; si < routine.steps.length; si++) {
    final step = routine.steps[si];
    final startSet = (si == stepIndex) ? setIndexWithinStep : 0;
    final firstRemaining = (si == stepIndex) ? max(1, remainingSecondsInCurrentSet) : step.secondsPerSet;

    for (var setIdx = startSet; setIdx < step.sets; setIdx++) {
      final isFirst = (si == stepIndex && setIdx == startSet);
      final delta = isFirst ? firstRemaining : step.secondsPerSet;
      t = (out.isEmpty ? delta : (out.last.secondsFromNow + delta));
      out.add(
        _SetPlanItem(
          secondsFromNow: t,
          stepName: step.name,
          setNumber: setIdx + 1,
          setTotal: step.sets,
        ),
      );
    }
  }

  return out;
}

