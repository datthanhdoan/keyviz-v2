import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/providers.dart';
import 'package:keyviz/windows/shared/shared.dart';
import 'package:keyviz/windows/settings/widgets/widgets.dart';

class LayoutView extends StatelessWidget {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Layout", style: context.textTheme.titleMedium),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Border",
          child: Switch(
            value: context.watch<KeyStyleProvider>().showBorder,
            onChanged: (value) {
              context.read<KeyStyleProvider>().showBorder = value;
            },
          ),
        ),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Border Radius",
          child: Slider(
            min: 0,
            max: 20,
            divisions: 20,
            value: context.watch<KeyStyleProvider>().borderRadius.topLeft.x,
            onChanged: (value) {
              context.read<KeyStyleProvider>().borderRadius = BorderRadius.circular(value);
            },
          ),
        ),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Border Width",
          child: Slider(
            min: 0,
            max: 5,
            divisions: 10,
            value: context.watch<KeyStyleProvider>().borderWidth,
            onChanged: (value) {
              context.read<KeyStyleProvider>().borderWidth = value;
            },
          ),
        ),
        const SmallColumnGap(),
        Text("Icons", style: context.textTheme.titleMedium),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Show Icons",
          child: Switch(
            value: context.watch<KeyStyleProvider>().showIcons,
            onChanged: (value) {
              context.read<KeyStyleProvider>().showIcons = value;
            },
          ),
        ),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Show Symbols",
          child: Switch(
            value: context.watch<KeyStyleProvider>().showSymbols,
            onChanged: (value) {
              context.read<KeyStyleProvider>().showSymbols = value;
            },
          ),
        ),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Show Plus Separator",
          child: Switch(
            value: context.watch<KeyStyleProvider>().showPlusSeparator,
            onChanged: (value) {
              context.read<KeyStyleProvider>().showPlusSeparator = value;
            },
          ),
        ),
      ],
    );
  }
}
