import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:keyviz/windows/shared/shared.dart';

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
    const div = Divider(height: defaultPadding);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding * .5),
          child: PanelItem(
            title: "Presets",
            action: Selector<KeyStyleProvider, KeyCapStyle>(
              selector: (_, keyStyle) => keyStyle.style,
              builder: (context, style, _) => Row(
                children: [
                  for (final value in KeyCapStyle.values)
                    Tooltip(
                      message: value.toString(),
                      child: TextButton(
                        onPressed: () {
                          context.keyStyle.style = value;
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            vertical: defaultPadding * .25,
                            horizontal: defaultPadding * .5,
                          ),
                        ),
                        child: Text(
                          value.toString(),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: value == style
                                ? context.colorScheme.primary
                                : context.colorScheme.tertiary,
                            fontWeight: value == style
                                ? FontWeight.w700
                                : FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        div,
        const TypographyView(),
        div,
        const LayoutView(),
        div,
        Selector<KeyStyleProvider, bool>(
          selector: (_, keyStyle) {
            return keyStyle.style == KeyCapStyle.minimal;
          },
          builder: (_, isMinimal, __) {
            return isMinimal
                ? const SizedBox()
                : const Column(
                    children: [ColorView(), div, BorderView(), div],
                  );
          },
        ),
        const BackgroundView(),
        const SmallColumnGap(),
      ],
    );
  }
}
