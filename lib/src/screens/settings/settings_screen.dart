import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sequence/l10n/app_localizations.dart';

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
                      RadioGroup<String?>(
                        groupValue: current,
                        onChanged: (value) {
                          switch (value) {
                            case null:
                              controller.setSystem();
                              break;
                            case 'en':
                              controller.setLocale(const Locale('en'));
                              break;
                            case 'hi':
                              controller.setLocale(const Locale('hi'));
                              break;
                            default:
                              controller.setSystem();
                          }
                        },
                        child: Column(
                          children: [
                            RadioListTile<String?>(
                              value: null,
                              title: Text(l10n.languageSystem),
                            ),
                            RadioListTile<String?>(
                              value: 'en',
                              title: Text(l10n.languageEnglish),
                            ),
                            RadioListTile<String?>(
                              value: 'hi',
                              title: Text(l10n.languageHindi),
                            ),
                          ],
                        ),
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

