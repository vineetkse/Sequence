import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the first frame until we have local storage ready.
  widgetsBinding.deferFirstFrame();

  final prefs = await SharedPreferences.getInstance();

  widgetsBinding.allowFirstFrame();
  runApp(SequenceApp(prefs: prefs));
}
