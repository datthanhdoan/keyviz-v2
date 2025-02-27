import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../../widgets/widgets.dart';

class LayoutView extends StatelessWidget {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return XExpansionTile(
      title: "Layout",
      children: [
        Selector<KeyStyleProvider, bool>(
          selector: (_, keyStyle) => keyStyle.showBorder,
          builder: (context, showBorder, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SubPanelItem(
                title: "Border",
                child: XSwitch(
                  value: showBorder,
                  onChanged: (value) {
                    context.keyStyle.showBorder = value;
                  },
                ),
              ),
              if (showBorder) ...[
                const VerySmallColumnGap(),
                SubPanelItem(
                  title: "Border Width",
                  child: Selector<KeyStyleProvider, double>(
                    selector: (_, keyStyle) => keyStyle.borderWidth,
                    builder: (context, borderWidth, _) => XSlider(
                      max: 10,
                      suffix: "px",
                      value: borderWidth,
                      onChanged: (value) {
                        context.keyStyle.borderWidth = value;
                      },
                    ),
                  ),
                ),
                const VerySmallColumnGap(),
                SubPanelItem(
                  title: "Border Radius",
                  child: Selector<KeyStyleProvider, double>(
                    selector: (_, keyStyle) => keyStyle.borderRadius,
                    builder: (context, borderRadius, _) => XSlider(
                      max: 32,
                      suffix: "px",
                      value: borderRadius,
                      onChanged: (value) {
                        context.keyStyle.borderRadius = value;
                      },
                    ),
                  ),
                ),
                const VerySmallColumnGap(),
                SubPanelItem(
                  title: "Border Color",
                  child: ColorPickerButton(
                    color: context.keyStyle.borderColor,
                    onColorChanged: (color) {
                      context.keyStyle.borderColor = color;
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const VerySmallColumnGap(),
        SubPanelItem(
          title: "Icons",
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.showIcons,
            builder: (context, showIcons, _) => XSwitch(
              value: showIcons,
              onChanged: (value) {
                context.keyStyle.showIcons = value;
              },
            ),
          ),
        ),
        const VerySmallColumnGap(),
        SubPanelItem(
          title: "Symbols",
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.showSymbols,
            builder: (context, showSymbols, _) => XSwitch(
              value: showSymbols,
              onChanged: (value) {
                context.keyStyle.showSymbols = value;
              },
            ),
          ),
        ),
        const VerySmallColumnGap(),
        SubPanelItem(
          title: 'Plus Separator',
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.showPlusSeparator,
            builder: (context, showPlusSeparator, _) => XSwitch(
              value: showPlusSeparator,
              onChanged: (value) {
                context.keyStyle.showPlusSeparator = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
