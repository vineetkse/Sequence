import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/routine_repository.dart';
import 'data/session_repository.dart';
import 'localization/locale_controller.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SequenceApp extends StatelessWidget {
  const SequenceApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
        ChangeNotifierProvider(create: (_) => RoutineRepository(prefs)..load()),
        ChangeNotifierProvider(create: (_) => SessionRepository(prefs)..load()),
      ],
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          final router = AppRouter.build(context);
          return MaterialApp.router(
            title: 'Sequence',
            theme: AppTheme.light(),
            routerConfig: router,
            locale: localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

