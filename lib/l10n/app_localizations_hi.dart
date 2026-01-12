// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'सीक्वेंस';

  @override
  String get tabRoutines => 'रूटीन';

  @override
  String get tabReports => 'रिपोर्ट';

  @override
  String get tabSettings => 'सेटिंग्स';

  @override
  String get routinesEmptyTitle => 'अभी कोई रूटीन नहीं';

  @override
  String get routinesEmptyBody =>
      'अपना पहला एक्सरसाइज़ या मेडिटेशन सीक्वेंस बनाएं।';

  @override
  String get createRoutine => 'रूटीन बनाएं';

  @override
  String get routineTitle => 'शीर्षक';

  @override
  String get routineType => 'प्रकार';

  @override
  String get routineTypeExercise => 'एक्सरसाइज़';

  @override
  String get routineTypeMeditation => 'ध्यान';

  @override
  String get steps => 'स्टेप्स';

  @override
  String get addStep => 'स्टेप जोड़ें';

  @override
  String get stepName => 'स्टेप का नाम';

  @override
  String get sets => 'सेट';

  @override
  String get setDuration => 'सेट अवधि';

  @override
  String secondsShort(int seconds) {
    return '$secondsसे';
  }

  @override
  String minutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get save => 'सेव';

  @override
  String get edit => 'एडिट';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get start => 'शुरू करें';

  @override
  String get resume => 'जारी रखें';

  @override
  String get pause => 'रोकें';

  @override
  String get skip => 'स्किप';

  @override
  String get done => 'पूर्ण';

  @override
  String get nowPlaying => 'चल रहा है';

  @override
  String setOf(int current, int total) {
    return 'सेट $current / $total';
  }

  @override
  String get reportsTitle => 'एक्सरसाइज़ रिपोर्ट';

  @override
  String get daily => 'दैनिक';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get totalTime => 'कुल समय';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम';

  @override
  String get languageEnglish => 'अंग्रेज़ी';

  @override
  String get languageHindi => 'हिंदी';

  @override
  String get delete => 'डिलीट';

  @override
  String get confirmDeleteTitle => 'रूटीन डिलीट करें?';

  @override
  String get confirmDeleteBody =>
      'यह रूटीन हट जाएगा, लेकिन पुरानी हिस्ट्री रहेगी।';

  @override
  String get confirm => 'कन्फर्म';
}
