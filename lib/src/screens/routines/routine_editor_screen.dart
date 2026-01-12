import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:sequence/l10n/app_localizations.dart';

import '../../data/models.dart';
import '../../data/routine_repository.dart';

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({super.key, this.routineId});

  final String? routineId;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _uuid = const Uuid();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  RoutineKind _kind = RoutineKind.exercise;
  final List<_EditableStep> _steps = [];

  @override
  void initState() {
    super.initState();
    final repo = context.read<RoutineRepository>();
    final existing = widget.routineId == null ? null : repo.byId(widget.routineId!);

    _titleController = TextEditingController(text: existing?.title ?? '');
    _kind = existing?.kind ?? RoutineKind.exercise;
    _steps
      ..clear()
      ..addAll(
        (existing?.steps ?? const <RoutineStep>[])
            .map((s) => _EditableStep.fromStep(s))
            .toList(growable: true),
      );

    if (_steps.isEmpty) {
      _steps.add(_EditableStep.blank(_uuid.v4()));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createRoutine),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.routineTitle),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.routineTitle : null,
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(labelText: l10n.routineType),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RoutineKind>(
                  value: _kind,
                  isExpanded: true,
                  onChanged: (v) => setState(() => _kind = v ?? RoutineKind.exercise),
                  items: [
                    DropdownMenuItem(value: RoutineKind.exercise, child: Text(l10n.routineTypeExercise)),
                    DropdownMenuItem(value: RoutineKind.meditation, child: Text(l10n.routineTypeMeditation)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(l10n.steps, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _steps.add(_EditableStep.blank(_uuid.v4()))),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addStep),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StepEditorCard(
                  index: index,
                  step: step,
                  onDelete: _steps.length <= 1 ? null : () => setState(() => _removeStepAt(index)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _removeStepAt(int index) {
    final step = _steps.removeAt(index);
    step.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final title = _titleController.text.trim();

    final steps = <RoutineStep>[];
    for (final s in _steps) {
      final name = s.name.text.trim();
      if (name.isEmpty) continue;
      final sets = int.tryParse(s.sets.text) ?? 1;
      final seconds = int.tryParse(s.secondsPerSet.text) ?? 30;
      steps.add(
        RoutineStep(
          id: s.id,
          name: name,
          sets: sets.clamp(1, 99),
          secondsPerSet: seconds.clamp(5, 60 * 60),
        ),
      );
    }

    if (steps.isEmpty) return;

    await context.read<RoutineRepository>().upsertRoutine(
          id: widget.routineId,
          title: title,
          kind: _kind,
          steps: steps,
        );

    if (mounted) context.pop();
  }
}

class _StepEditorCard extends StatelessWidget {
  const _StepEditorCard({
    required this.index,
    required this.step,
    required this.onDelete,
  });

  final int index;
  final _EditableStep step;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${index + 1}', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: l10n.delete,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: step.name,
              decoration: InputDecoration(labelText: l10n.stepName),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.stepName : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: step.sets,
                    decoration: InputDecoration(labelText: l10n.sets),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: step.secondsPerSet,
                    decoration: InputDecoration(labelText: '${l10n.setDuration} (${l10n.secondsShort(30)})'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableStep {
  _EditableStep({
    required this.id,
    required this.name,
    required this.sets,
    required this.secondsPerSet,
  });

  factory _EditableStep.fromStep(RoutineStep s) => _EditableStep(
        id: s.id,
        name: TextEditingController(text: s.name),
        sets: TextEditingController(text: '${s.sets}'),
        secondsPerSet: TextEditingController(text: '${s.secondsPerSet}'),
      );

  factory _EditableStep.blank(String id) => _EditableStep(
        id: id,
        name: TextEditingController(),
        sets: TextEditingController(text: '3'),
        secondsPerSet: TextEditingController(text: '30'),
      );

  final String id;
  final TextEditingController name;
  final TextEditingController sets;
  final TextEditingController secondsPerSet;

  void dispose() {
    name.dispose();
    sets.dispose();
    secondsPerSet.dispose();
  }
}

