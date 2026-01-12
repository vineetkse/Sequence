import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) {
    final code = _prefs.getString(_key);
    _locale = code == null ? null : Locale(code);
  }

  static const _key = 'sequence.locale';
  final SharedPreferences _prefs;

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> setSystem() async {
    _locale = null;
    await _prefs.remove(_key);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }
}

