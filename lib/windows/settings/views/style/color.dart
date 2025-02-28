import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/providers.dart';
import 'package:keyviz/windows/shared/shared.dart';

import '../../widgets/widgets.dart';

class ColorView extends StatelessWidget {
  const ColorView({super.key});

  @override
  Widget build(BuildContext context) {
    return XExpansionTile(
      title: "Color",
      children: [
        SubPanelItem(
          title: "Fill Type",
          child: SegmentedButton<FillType>(
            segments: const [
              ButtonSegment(
                value: FillType.solid,
                label: Text("Solid"),
              ),
              ButtonSegment(
                value: FillType.gradient,
                label: Text("Gradient"),
              ),
            ],
            selected: {context.watch<KeyStyleProvider>().fillType},
            onSelectionChanged: (selected) {
              context.read<KeyStyleProvider>().fillType = selected.first;
            },
          ),
        ),
        const VerySmallColumnGap(),
        // normal & modifiers title
        Padding(
          padding: const EdgeInsets.only(
            left: defaultPadding * .5,
            bottom: defaultPadding * .5,
          ),
          child: Selector<KeyStyleProvider, bool>(
            selector: (_, keyStyle) => keyStyle.differentColorForModifiers,
            builder: (context, differentColors, _) => Row(
              children: [
                Text(
                  "Regular Keys",
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.tertiary,
                  ),
                ),
                const VerySmallRowGap(),
                IconButton(
                  tooltip: differentColors ? "Use Same Color" : "Use Different Color",
                  onPressed: () {
                    context.read<KeyStyleProvider>().differentColorForModifiers =
                        !differentColors;
                  },
                  icon: SvgIcon(
                    icon: differentColors
                        ? "assets/icons/link.svg"
                        : "assets/icons/link-broken.svg",
                  ),
                ),
                const VerySmallRowGap(),
                Text(
                  "Modifiers",
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colorScheme.tertiary
                        .withOpacity(differentColors ? .25 : 1),
                  ),
                ),
              ],
            ),
          ),
        ),
        // color options
        Selector<KeyStyleProvider, Tuple3<KeyCapStyle, bool, bool>>(
          selector: (_, keyStyle) => Tuple3(
            keyStyle.keyCapStyle,
            keyStyle.isGradient,
            keyStyle.differentColorForModifiers,
          ),
          builder: (context, tuple, _) {
            final bool need2Colors = tuple.item1 == KeyCapStyle.elevated ||
                tuple.item1 == KeyCapStyle.plastic ||
                tuple.item1 == KeyCapStyle.mechanical;
            final bool isGradient =
                tuple.item2 && tuple.item1 != KeyCapStyle.mechanical;
            final bool differentColorForModifiers = tuple.item3;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // normal color options
                isGradient
                    ? SubPanelItemGroup(
                        items: [
                          RawGradientInputSubPanelItem(
                            title: need2Colors ? "Main Color" : "Color",
                            initialColor1: context.keyStyle.primaryColor1,
                            initialColor2: context.keyStyle.primaryColor2,
                            onColor1Changed: (Color color) {
                              context.keyStyle.primaryColor1 = color;
                            },
                            onColor2Changed: (Color color) {
                              context.keyStyle.primaryColor2 = color;
                            },
                          ),
                          if (need2Colors)
                            RawGradientInputSubPanelItem(
                              title: "Secondary Color",
                              initialColor1: context.keyStyle.secondaryColor1,
                              initialColor2: context.keyStyle.secondaryColor2,
                              onColor1Changed: (Color color) {
                                context.keyStyle.secondaryColor1 = color;
                              },
                              onColor2Changed: (Color color) {
                                context.keyStyle.secondaryColor2 = color;
                              },
                            ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SubPanelItem(
                            title: need2Colors ? "Main Color" : "Color",
                            child: SizedBox(
                              width: defaultPadding * 10,
                              child: RawColorInputSubPanelItem(
                                defaultValue: context.keyStyle.primaryColor1,
                                onChanged: (Color color) {
                                  context.keyStyle.primaryColor1 = color;
                                },
                              ),
                            ),
                          ),
                          if (need2Colors) ...[
                            const VerySmallColumnGap(),
                            SubPanelItem(
                              title: "Secondary Color",
                              child: SizedBox(
                                width: defaultPadding * 10,
                                child: RawColorInputSubPanelItem(
                                  defaultValue:
                                      context.keyStyle.secondaryColor1,
                                  onChanged: (Color color) {
                                    context.keyStyle.secondaryColor1 = color;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                // modifier color options
                if (differentColorForModifiers) ...[
                  const VerySmallColumnGap(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: defaultPadding * .5,
                      left: defaultPadding * .5,
                      bottom: defaultPadding * .5,
                    ),
                    child: Text(
                      "Modifiers",
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.tertiary,
                      ),
                    ),
                  ),
                  isGradient
                      ? SubPanelItemGroup(
                          items: [
                            RawGradientInputSubPanelItem(
                              title: need2Colors ? "Main Color" : "Color",
                              initialColor1: context.keyStyle.mPrimaryColor1,
                              initialColor2: context.keyStyle.mPrimaryColor2,
                              onColor1Changed: (Color color) {
                                context.keyStyle.mPrimaryColor1 = color;
                              },
                              onColor2Changed: (Color color) {
                                context.keyStyle.mPrimaryColor2 = color;
                              },
                            ),
                            if (need2Colors)
                              RawGradientInputSubPanelItem(
                                title: "Secondary Color",
                                initialColor1:
                                    context.keyStyle.mSecondaryColor1,
                                initialColor2:
                                    context.keyStyle.mSecondaryColor2,
                                onColor1Changed: (Color color) {
                                  context.keyStyle.mSecondaryColor1 = color;
                                },
                                onColor2Changed: (Color color) {
                                  context.keyStyle.mSecondaryColor2 = color;
                                },
                              ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SubPanelItem(
                              title: need2Colors ? "Main Color" : "Color",
                              child: SizedBox(
                                width: defaultPadding * 10,
                                child: RawColorInputSubPanelItem(
                                  defaultValue: context.keyStyle.mPrimaryColor1,
                                  onChanged: (Color color) {
                                    context.keyStyle.mPrimaryColor1 = color;
                                  },
                                ),
                              ),
                            ),
                            if (need2Colors) ...[
                              const VerySmallColumnGap(),
                              SubPanelItem(
                                title: "Secondary Color",
                                child: SizedBox(
                                  width: defaultPadding * 10,
                                  child: RawColorInputSubPanelItem(
                                    defaultValue:
                                        context.keyStyle.mSecondaryColor1,
                                    onChanged: (Color color) {
                                      context.keyStyle.mSecondaryColor1 = color;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                ]
              ],
            );
          },
        ),
      ],
    );
  }
}
