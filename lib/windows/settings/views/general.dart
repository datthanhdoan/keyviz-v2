import 'package:flutter/material.dart';
import 'package:keyviz/windows/settings/widgets/hotkey_input.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/language_provider.dart';
import 'package:keyviz/l10n/app_localizations.dart';

import '../widgets/widgets.dart';

class GeneralTabView extends StatelessWidget {
  const GeneralTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelItem(
          title: "Language / Ngôn ngữ",
          subtitle: "Choose your preferred language / Chọn ngôn ngữ ưa thích",
          action: Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return DropdownButton<String>(
                value: languageProvider.locale.languageCode,
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: 'vi',
                    child: Text('Tiếng Việt'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLocale(Locale(value));
                  }
                },
              );
            },
          ),
        ),
        const Divider(),
        PanelItem(
          title: context.tr('hotkey_filter'),
          subtitle: context.tr('filter_letters_numbers'),
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.filterHotkeys,
            builder: (_, filterHotkeys, __) => XSwitch(
              value: filterHotkeys,
              onChange: (bool value) {
                context.keyEvent.filterHotkeys = value;
              },
            ),
          ),
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.filterHotkeys,
          builder: (_, filterHotkeys, __) => PanelItem(
            asRow: false,
            enabled: filterHotkeys,
            title: context.tr('ignore_keys'),
            subtitle: context.tr('ignore_modifier_keys'),
            action: const _IgnoreKeyOptions(),
          ),
        ),
        const Divider(),
        PanelItem(
          title: context.tr('show_history'),
          subtitle: context.tr('show_previous_keypresses'),
          action: Selector<KeyEventProvider, VisualizationHistoryMode>(
            selector: (_, keyEvent) => keyEvent.historyMode,
            builder: (context, historyMode, __) {
              return XDropdown<VisualizationHistoryMode>(
                value: historyMode,
                options: VisualizationHistoryMode.values,
                onChanged: (value) {
                  context.keyEvent.historyMode = value;
                },
              );
            },
          ),
        ),
        const Divider(),
        PanelItem(
          asRow: false,
          title: context.tr('toggle_shortcut'),
          subtitle: context.tr('press_to_toggle'),
          action: HotkeyInput(
            initialValue: context.keyEvent.keyvizToggleShortcut,
            onChanged: (value) => context.keyEvent.keyvizToggleShortcut = value,
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(top: defaultPadding),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showDialog(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withOpacity(.2),
                textStyle: context.textTheme.labelSmall,
                padding: const EdgeInsets.all(defaultPadding * .5),
                minimumSize: const Size(defaultPadding, defaultPadding * 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultPadding * .6),
                ),
              ),
              child: Text(context.tr('reset_to_defaults')),
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('confirm_reset')),
        backgroundColor: context.colorScheme.primaryContainer,
        titleTextStyle: context.textTheme.titleLarge,
        actions: [
          OutlinedButton(
            onPressed: () {
              // revert to defaults
              context.keyEvent.revertToDefaults();
              context.keyStyle.reverToDefaults();

              Navigator.of(context).pop();
            },
            child: Text(context.tr('reset')),
          ),
          OutlinedButton(
            onPressed: Navigator.of(context).pop,
            child: Text(context.tr('cancel')),
          ),
        ],
        elevation: 0,
      ),
    );
  }
}

class _IgnoreKeyOptions extends StatelessWidget {
  const _IgnoreKeyOptions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding * .5),
      decoration: BoxDecoration(
        color: context.isDark
            ? context.colorScheme.primaryContainer
            : context.colorScheme.background,
        borderRadius: BorderRadius.circular(defaultPadding * .5),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Row(
        children: [
          for (final modifierKey in ModifierKey.values)
            Selector<KeyEventProvider, bool>(
              selector: (_, keyEvent) => keyEvent.ignoreKeys[modifierKey]!,
              builder: (context, ignoring, __) => _KeyOption(
                name: modifierKey.keyLabel,
                ignoring: ignoring,
                onTap: () {
                  context.keyEvent.setModifierKeyIgnoring(
                    modifierKey,
                    !ignoring,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _KeyOption extends StatelessWidget {
  const _KeyOption({
    required this.name,
    required this.ignoring,
    required this.onTap,
  });

  final String name;
  final bool ignoring;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        ignoring ? context.colorScheme.tertiary.withOpacity(.35) : Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: defaultPadding * 1.5,
          margin: const EdgeInsets.only(
            right: defaultPadding * .5,
            bottom: defaultPadding * .2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding * .5),
          decoration: BoxDecoration(
            color: ignoring
                ? context.colorScheme.secondaryContainer
                : context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(defaultPadding * .4),
            border: Border.all(color: bgColor),
            boxShadow: [
              BoxShadow(
                color: bgColor,
                offset: const Offset(0, defaultPadding * .2),
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(
              color: context.isDark && !ignoring ? Colors.white : bgColor,
              fontSize: defaultPadding * .75,
            ),
          ),
        ),
      ),
    );
  }
}
