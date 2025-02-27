import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/providers.dart';
import 'package:keyviz/windows/shared/shared.dart';
import 'package:keyviz/windows/settings/widgets/widgets.dart';

import '../../widgets/widgets.dart';
import 'typography.dart';
import 'background.dart';
import 'border.dart';
import 'color.dart';
import 'layout.dart';

class StyleTabView extends StatelessWidget {
  const StyleTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Keycap", style: context.textTheme.titleMedium),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Presets",
          child: SegmentedButton<KeyCapStyle>(
            segments: const [
              ButtonSegment(
                value: KeyCapStyle.minimal,
                label: Text("Minimal"),
              ),
              ButtonSegment(
                value: KeyCapStyle.flat,
                label: Text("Flat"),
              ),
              ButtonSegment(
                value: KeyCapStyle.elevated,
                label: Text("Elevated"),
              ),
              ButtonSegment(
                value: KeyCapStyle.plastic,
                label: Text("Plastic"),
              ),
              ButtonSegment(
                value: KeyCapStyle.mechanical,
                label: Text("Mechanical"),
              ),
            ],
            selected: {context.watch<KeyStyleProvider>().keyCapStyle},
            onSelectionChanged: (selected) {
              context.read<KeyStyleProvider>().keyCapStyle = selected.first;
            },
          ),
        ),
        const SmallColumnGap(),
        const ColorView(),
        const SmallColumnGap(),
        const LayoutView(),
        const SmallColumnGap(),
        const TypographyView(),
      ],
    );
  }
}
