import 'package:flutter/material.dart';
import 'package:keyviz/windows/settings/widgets/hotkey_input.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/language_provider.dart';
import 'package:keyviz/l10n/app_localizations.dart';
import 'package:keyviz/domain/vault/vault.dart';
import 'package:keyviz/providers/key_style.dart';

import '../widgets/widgets.dart';
import '../widgets/cross_slider.dart';

// Thêm các widget Settings cần thiết
class SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class SettingsSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const SettingsSlider({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class SettingsDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const SettingsDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}

class SettingsButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SettingsButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// Thêm phương thức mở rộng cho String để hỗ trợ tr
extension StringExtension on String {
  String tr(BuildContext context, String text) {
    // Sử dụng AppLocalizations để dịch nếu có
    // Hoặc trả về text gốc nếu không có bản dịch
    return text;
  }
}

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
                  Vault.save(context);
                  debugPrint("Changed historyMode to: $value");
                },
              );
            },
          ),
        ),
        const Divider(),
        // History Fade Delay
        PanelItem(
          title: context.tr('history_fade_delay'),
          subtitle: context.tr('how_long_before_keys_fade'),
          action: Selector<KeyEventProvider, int>(
            selector: (_, keyEvent) => keyEvent.historyFadeDelayInSeconds,
            builder: (_, fadeDelay, __) => XSlider(
              value: fadeDelay.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              suffix: " ${context.tr('seconds')}",
              onChanged: (value) {
                context.keyEvent.historyFadeDelayInSeconds = value.toInt();
              },
            ),
          ),
        ),
        const Divider(),
        // Fade Steps
        PanelItem(
          title: context.tr('fade_steps'),
          subtitle: context.tr('number_of_fade_steps'),
          action: Selector<KeyEventProvider, int>(
            selector: (_, keyEvent) => keyEvent.fadeSteps,
            builder: (_, fadeSteps, __) => XSlider(
              value: fadeSteps.toDouble(),
              min: 5,
              max: 20,
              divisions: 15,
              suffix: " ${context.tr('steps')}",
              onChanged: (value) {
                context.keyEvent.fadeSteps = value.toInt();
              },
            ),
          ),
        ),
        const Divider(),
        // Show Combo Count
        PanelItem(
          title: context.tr('show_combo_count'),
          subtitle: context.tr('show_number_of_key_presses'),
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.showComboCount,
            builder: (_, showComboCount, __) => XSwitch(
              value: showComboCount,
              onChange: (value) {
                context.keyEvent.showComboCount = value;
              },
            ),
          ),
        ),
        const Divider(),
        // Min Combo Count
        PanelItem(
          title: context.tr('min_combo_count'),
          subtitle: context.tr('minimum_presses_to_show_count'),
          action: Selector<KeyEventProvider, int>(
            selector: (_, keyEvent) => keyEvent.minComboCount,
            builder: (_, minComboCount, __) => XSlider(
              value: minComboCount.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              suffix: " ${context.tr('presses')}",
              onChanged: (value) {
                context.keyEvent.minComboCount = value.toInt();
              },
            ),
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
              context.keyStyle.revertToDefaults();

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
