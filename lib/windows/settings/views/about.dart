import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/widgets.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: defaultBorderRadius,
                    border: Border.all(color: context.colorScheme.outline),
                  ),
                  padding: const EdgeInsets.all(defaultPadding * 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Keyviz",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerySmallColumnGap(),
                      Text(
                        "Author: Rahul Mula",
                        style: context.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _launchUrl(
                              "https://github.com/mulaRahul/keyviz",
                            ),
                            tooltip: "GitHub",
                            icon: const SvgIcon(
                              icon: VuesaxIcons.github,
                              size: 24,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _launchUrl(
                              "mailto:rahulmula.1@gmail.com",
                            ),
                            tooltip: "Email",
                            icon: const SvgIcon(
                              icon: VuesaxIcons.message,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SmallRowGap(),
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: defaultBorderRadius,
                    border: Border.all(color: context.colorScheme.outline),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: SvgPicture.asset(
                          "assets/img/keycap-grid.svg",
                          width: defaultPadding * 9,
                          height: defaultPadding * 9,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                          defaultPadding * 1.5,
                        ).copyWith(right: defaultPadding * 4),
                        child: Text(
                          "This is an Alpha early test version,\nbugs 🐛 are expected.\n"
                          "If you encounter any issues,\nplease report them to us!",
                          style: context.textTheme.labelSmall?.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SmallColumnGap(),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: defaultBorderRadius,
                    border: Border.all(color: context.colorScheme.outline),
                  ),
                  padding: const EdgeInsets.all(defaultPadding * 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "💻 Developer's Note",
                        style: context.textTheme.titleLarge,
                      ),
                      const VerySmallColumnGap(),
                      Text(
                        "Hello 👋, I'm Rahul Mula, the developer of Keyviz. "
                        "I'm also an online instructor, teaching courses on the web.\n\n"
                        "When recording tutorial videos, I often need to show my keyboard actions to viewers. "
                        "That's why I decided to develop Keyviz, a key visualization software, "
                        "and share it with everyone, hoping it helps others with similar needs.",
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SmallRowGap(),
              Container(
                height: 250,
                width: 200,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: defaultBorderRadius,
                  border: Border.all(color: context.colorScheme.outline),
                ),
                padding: const EdgeInsets.all(defaultPadding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💖 Support",
                      style: context.textTheme.titleLarge,
                    ),
                    const VerySmallColumnGap(),
                    Text(
                      "Keyviz is completely free, relying on your generosity to support development. "
                      "Your support allows me to invest more time and effort into improving this software.",
                      style: context.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => launchUrlString(
                            "https://github.com/sponsors/mulaRahul",
                          ),
                          tooltip: "Github Sponsors",
                          icon: const SvgIcon(icon: "assets/img/github-logo.svg"),
                        ),
                        IconButton(
                          onPressed: () => launchUrlString(
                            "https://opencollective.com/keyviz",
                          ),
                          tooltip: "Open Collective",
                          icon: SvgPicture.asset(
                            "assets/img/opencollective-logo.svg",
                            width: defaultPadding,
                            height: defaultPadding,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
