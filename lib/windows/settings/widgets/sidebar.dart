import 'package:flutter/material.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/windows/shared/shared.dart';

enum SettingsTab {
  general(VuesaxIcons.cogWheel, "General"),
  mouse(VuesaxIcons.mouse, "Mouse"),
  keycap(VuesaxIcons.keyboard, "Keycap"),
  appearance(VuesaxIcons.monitor, "Appearance"),
  about(VuesaxIcons.more, "About");

  final String icon;
  final String label;

  const SettingsTab(this.icon, this.label);
}

class SideBar extends StatelessWidget {
  final SettingsTab currentTab;
  final ValueChanged<SettingsTab> onChange;

  const SideBar({
    super.key,
    required this.currentTab,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: context.colorScheme.outline,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: defaultPadding),
          for (final item in SettingsTab.values)
            _buildSidebarItem(context, item),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, SettingsTab item) {
    final isSelected = currentTab == item;

    return Tooltip(
      message: item.label,
      child: InkWell(
        onTap: () => onChange(item),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? context.colorScheme.primaryContainer
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                width: 3,
                color: isSelected
                    ? context.colorScheme.primary
                    : Colors.transparent,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgIcon(
                icon: item.icon,
                size: 24,
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
