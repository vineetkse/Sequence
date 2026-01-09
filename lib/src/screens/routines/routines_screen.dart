import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/routine_repository.dart';
import '../../widgets/gradient_card.dart';
import '../player/routine_player_screen.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routines = context.watch<RoutineRepository>().routines;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(l10n.appName),
          actions: [
            IconButton(
              tooltip: l10n.createRoutine,
              onPressed: () => context.push('/routines/new'),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (routines.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 56),
                    const SizedBox(height: 14),
                    Text(l10n.routinesEmptyTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      l10n.routinesEmptyBody,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => context.push('/routines/new'),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.createRoutine),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.separated(
              itemBuilder: (context, index) => _RoutineCard(routine: routines[index]),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: routines.length,
            ),
          ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final subtitle = '${routine.steps.length} ${l10n.steps.toLowerCase()} • ${_formatSeconds(routine.totalSeconds)}';

    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      openBuilder: (context, _) => RoutinePlayerScreen(routineId: routine.id),
      closedBuilder: (context, open) => GradientCard(
        onTap: open,
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            PopupMenuButton<_RoutineAction>(
              onSelected: (a) async {
                switch (a) {
                  case _RoutineAction.edit:
                    if (context.mounted) context.push('/routines/${routine.id}/edit');
                    break;
                  case _RoutineAction.delete:
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.confirmDeleteTitle),
                        content: Text(l10n.confirmDeleteBody),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirm)),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await context.read<RoutineRepository>().deleteRoutine(routine.id);
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: _RoutineAction.edit, child: Text(l10n.edit)),
                PopupMenuItem(value: _RoutineAction.delete, child: Text(l10n.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _RoutineAction { edit, delete }

String _formatSeconds(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m}m ${s}s';
}

