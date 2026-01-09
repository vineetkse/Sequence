import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sequence/l10n/app_localizations.dart';

import '../../data/routine_repository.dart';
import '../../data/session_repository.dart';
import '../../services/completion_feedback.dart';
import '../../services/notification_service.dart';
import 'routine_player_controller.dart';

class RoutinePlayerScreen extends StatefulWidget {
  const RoutinePlayerScreen({super.key, required this.routineId});

  final String routineId;

  @override
  State<RoutinePlayerScreen> createState() => _RoutinePlayerScreenState();
}

class _RoutinePlayerScreenState extends State<RoutinePlayerScreen> {
  bool _logged = false;
  late final _lifecycle = _PlayerLifecycleBridge(
    onBackground: () async {
      final controller = context.read<RoutinePlayerController>();
      final notifs = context.read<NotificationService>();
      controller.onAppBackgrounded();
      await notifs.cancelAll();
      await notifs.scheduleSetCompletions(
            routine: controller.routine,
            stepIndex: controller.stepIndex,
            setIndexWithinStep: controller.setIndexWithinStep,
            remainingSecondsInCurrentSet: controller.remainingSeconds,
          );
    },
    onForeground: () async {
      final notifs = context.read<NotificationService>();
      final controller = context.read<RoutinePlayerController>();
      await notifs.cancelAll();
      await controller.onAppResumed();
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycle);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routine = context.watch<RoutineRepository>().byId(widget.routineId);

    if (routine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not found')),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => RoutinePlayerController(
        routine: routine,
        feedback: const CompletionFeedback(),
      ),
      child: Consumer<RoutinePlayerController>(
        builder: (context, controller, _) {
          if (!_logged && controller.status == PlayerStatus.finished) {
            _logged = true;
            final startedAt = controller.startedAt ?? DateTime.now();
            context.read<SessionRepository>().addSession(
                  routineId: routine.id,
                  startedAt: startedAt,
                  endedAt: DateTime.now(),
                  totalSeconds: routine.totalSeconds,
                );
          }

          final scheme = Theme.of(context).colorScheme;
          final progress = routine.totalSeconds == 0
              ? 0.0
              : controller.computeCompletedSeconds() / routine.totalSeconds;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.nowPlaying),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.85),
                    scheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        routine.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.currentStep.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.setOf(controller.currentSetNumber, controller.currentSetTotal),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 18),
                              Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Text(
                                    _formatCountdown(l10n, controller.remainingSeconds),
                                    key: ValueKey(controller.remainingSeconds),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${l10n.totalTime}: ${_formatMinutesSeconds(controller.totalRemainingSeconds)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      _Controls(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});

  final RoutinePlayerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.status == PlayerStatus.finished) {
      return FilledButton.icon(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.check_rounded),
        label: Text(l10n.done),
      );
    }

    final isRunning = controller.status == PlayerStatus.running;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final notifs = context.read<NotificationService>();
              await notifs.cancelAll();
              if (isRunning) {
                controller.pause();
                return;
              }
              controller.start();
              // If user immediately backgrounds, notifications will take over;
              // scheduling is done on background transition.
            },
            icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
            label: Text(isRunning ? l10n.pause : (controller.status == PlayerStatus.paused ? l10n.resume : l10n.start)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () async {
              await context.read<NotificationService>().cancelAll();
              await controller.skip();
            },
            icon: const Icon(Icons.fast_forward_rounded),
            label: Text(l10n.skip),
          ),
        ),
      ],
    );
  }
}

String _formatCountdown(AppLocalizations l10n, int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return l10n.minutesSeconds(m.toString(), s.toString().padLeft(2, '0'));
}

String _formatMinutesSeconds(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

class _PlayerLifecycleBridge with WidgetsBindingObserver {
  _PlayerLifecycleBridge({required this.onBackground, required this.onForeground});

  final Future<void> Function() onBackground;
  final Future<void> Function() onForeground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onForeground();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        onBackground();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}

