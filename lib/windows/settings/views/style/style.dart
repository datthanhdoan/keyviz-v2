import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/config/config.dart';
import 'package:keyviz/providers/providers.dart';
import 'package:keyviz/windows/shared/shared.dart';
import 'package:keyviz/windows/settings/widgets/widgets.dart';
import 'package:keyviz/domain/vault/vault.dart';
import 'package:keyviz/l10n/app_localizations.dart';

import '../../widgets/widgets.dart';
import 'typography.dart';
import 'background.dart';
import 'border.dart';
import 'color.dart';
import 'layout.dart';

class StyleTabView extends StatefulWidget {
  const StyleTabView({super.key});

  @override
  State<StyleTabView> createState() => _StyleTabViewState();
}

class _StyleTabViewState extends State<StyleTabView> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo cài đặt được áp dụng khi tab được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Vault.save(context);
    });
  }

  @override
  void dispose() {
    // Đảm bảo cài đặt được lưu khi tab bị đóng
    Vault.save(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Keycap", style: context.textTheme.titleMedium),
        const SmallColumnGap(),
        SubPanelItem(
          title: "Presets",
          child: SizedBox(
            width: 350, // Giới hạn chiều rộng
            child: SegmentedButton<KeyCapStyle>(
              showSelectedIcon: false, // Ẩn biểu tượng đã chọn để tiết kiệm không gian
              segments: const [
                ButtonSegment(
                  value: KeyCapStyle.minimal,
                  label: Text("Minimal", style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: KeyCapStyle.flat,
                  label: Text("Flat", style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: KeyCapStyle.elevated,
                  label: Text("Elevated", style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: KeyCapStyle.plastic,
                  label: Text("Plastic", style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: KeyCapStyle.mechanical,
                  label: Text("Mechanical", style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {context.watch<KeyStyleProvider>().keyCapStyle},
              onSelectionChanged: (selected) {
                context.read<KeyStyleProvider>().keyCapStyle = selected.first;
                // Lưu cài đặt ngay sau khi thay đổi preset
                Vault.save(context);
              },
            ),
          ),
        ),
        const SmallColumnGap(),
        const ColorView(),
        const SmallColumnGap(),
        const LayoutView(),
        const SmallColumnGap(),
        const TypographyView(),
        const SmallColumnGap(),
        // Thêm nút Reset to Defaults
        Center(
          child: FilledButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.tr('confirm_reset')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.tr('cancel')),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.read<KeyStyleProvider>().revertToDefaults();
                        Navigator.pop(context);
                        // Lưu cài đặt ngay sau khi reset
                        Vault.save(context);
                      },
                      child: Text(context.tr('reset_to_defaults')),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('reset_to_defaults')),
          ),
        ),
      ],
    );
  }
}
