import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../localization/locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<LocaleController>();

    final current = controller.locale?.languageCode;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(l10n.settingsTitle)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(l10n.language),
                        subtitle: Text(l10n.languageSystem),
                        leading: const Icon(Icons.translate_rounded),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String?>(
                        value: null,
                        groupValue: current,
                        onChanged: (_) => controller.setSystem(),
                        title: Text(l10n.languageSystem),
                      ),
                      RadioListTile<String?>(
                        value: 'en',
                        groupValue: current,
                        onChanged: (_) => controller.setLocale(const Locale('en')),
                        title: Text(l10n.languageEnglish),
                      ),
                      RadioListTile<String?>(
                        value: 'hi',
                        groupValue: current,
                        onChanged: (_) => controller.setLocale(const Locale('hi')),
                        title: Text(l10n.languageHindi),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

