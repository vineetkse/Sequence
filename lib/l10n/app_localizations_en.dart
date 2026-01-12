// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sequence';

  @override
  String get tabRoutines => 'Routines';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabSettings => 'Settings';

  @override
  String get routinesEmptyTitle => 'No routines yet';

  @override
  String get routinesEmptyBody =>
      'Create your first exercise or meditation sequence.';

  @override
  String get createRoutine => 'Create routine';

  @override
  String get routineTitle => 'Title';

  @override
  String get routineType => 'Type';

  @override
  String get routineTypeExercise => 'Exercise';

  @override
  String get routineTypeMeditation => 'Meditation';

  @override
  String get steps => 'Steps';

  @override
  String get addStep => 'Add step';

  @override
  String get stepName => 'Step name';

  @override
  String get sets => 'Sets';

  @override
  String get setDuration => 'Set duration';

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String minutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get cancel => 'Cancel';

  @override
  String get start => 'Start';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String setOf(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String get reportsTitle => 'Exercise report';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get totalTime => 'Total time';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'Hindi';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDeleteTitle => 'Delete routine?';

  @override
  String get confirmDeleteBody =>
      'This will remove the routine and keep past history.';

  @override
  String get confirm => 'Confirm';
}
