import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/l10n/app_localizations.dart';

import '../widgets/widgets.dart';

class MouseTabView extends StatelessWidget {
  const MouseTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PanelItem(
          title: context.tr('visualize_mouse_clicks'),
          subtitle: context.tr('show_animation_when_pressed'),
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.showMouseClicks,
            builder: (context, showMouseClicks, _) => XSwitch(
              value: showMouseClicks,
              onChange: (value) {
                context.keyEvent.showMouseClicks = value;
              },
            ),
          ),
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.showMouseClicks,
          builder: (context, enabled, _) {
            return PanelItem(
              enabled: enabled,
              title: context.tr('animation_type'),
              action: Selector<KeyStyleProvider, MouseClickAnimation>(
                selector: (_, keyStyle) => keyStyle.clickAnimation,
                builder: (context, value, _) {
                  return XDropdown<MouseClickAnimation>(
                    value: value,
                    options: MouseClickAnimation.values,
                    onChanged: (value) {
                      context.keyStyle.clickAnimation = value;
                    },
                  );
                },
              ),
            );
          },
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.showMouseClicks,
          builder: (context, enabled, _) => PanelItem(
            enabled: enabled,
            title: context.tr('animation_color'),
            subtitle: context.tr('color_of_cursor_animation'),
            actionFlex: 2,
            action: RawColorInputSubPanelItem(
              label: context.tr('mouse_click_animation_color'),
              defaultValue: context.keyStyle.clickColor,
              onChanged: (color) => context.keyStyle.clickColor = color,
            ),
          ),
        ),
        const Divider(),
        Selector<KeyEventProvider, bool>(
          selector: (_, keyEvent) => keyEvent.showMouseClicks,
          builder: (_, enabled, __) => PanelItem(
            enabled: enabled,
            title: context.tr('keep_visible'),
            subtitle: context.tr('always_show_animation'),
            action: Selector<KeyEventProvider, bool>(
              selector: (_, keyEvent) => keyEvent.highlightCursor,
              builder: (context, highlightCursor, _) => XSwitch(
                value: highlightCursor,
                onChange: (value) {
                  context.keyEvent.highlightCursor = value;
                },
              ),
            ),
          ),
        ),
        const Divider(),
        PanelItem(
          title: context.tr('show_mouse_actions'),
          subtitle: context.tr('display_mouse_actions'),
          action: Selector<KeyEventProvider, bool>(
            selector: (_, keyEvent) => keyEvent.showMouseEvents,
            builder: (context, showMouseEvents, _) => XSwitch(
              value: showMouseEvents,
              onChange: (value) {
                context.keyEvent.showMouseEvents = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
