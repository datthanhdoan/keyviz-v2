import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/providers.dart';

import 'widgets/widgets.dart';

// positions key visualizer
class KeyVisualizer extends StatelessWidget {
  const KeyVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider, Tuple2<Alignment, double>>(
      builder: (context, tuple, child) => Align(
        alignment: tuple.item1,
        child: Padding(
          padding: _padding(tuple.item1, tuple.item2),
          child: child!,
        ),
      ),
      selector: (_, keyStyle) => Tuple2(keyStyle.alignment, keyStyle.margin),
      child: const _KeyVisualizer(),
    );
  }

  EdgeInsets _padding(Alignment alignment, double value) {
    final padding = EdgeInsets.all(value);
    switch (alignment) {
      case Alignment.bottomRight:
      case Alignment.bottomCenter:
      case Alignment.bottomLeft:
        return padding.copyWith(top: 0);

      case Alignment.centerRight:
      case Alignment.center:
      case Alignment.centerLeft:
        return padding.copyWith(top: 0, bottom: 0);

      case Alignment.topRight:
      case Alignment.topCenter:
      case Alignment.topLeft:
        return padding.copyWith(bottom: 0);
    }
    return padding;
  }
}

// maps events to KeyCapGroup or VisualizationHistory
class _KeyVisualizer extends StatelessWidget {
  const _KeyVisualizer();

  @override
  Widget build(BuildContext context) {
    // visualization history mode
    final historyDirection = context.select<KeyEventProvider, Axis?>(
      (keyEvent) => keyEvent.historyDirection,
    );
    return Selector<KeyEventProvider, List<String>>(
      builder: (context, groups, _) {
        // placeholder
        if (groups.isEmpty) return const SizedBox();
        // ignoring history
        return historyDirection == null
            // latest display group
            ? KeyCapGroup(
                key: Key(groups.last),
                groupId: groups.last,
              )
            // show history
            : _VisualizationHistory(
                groups: groups,
                direction: historyDirection,
              );
      },
      selector: (_, keyEvent) =>
          keyEvent.keyboardEvents.keys.toList(growable: false),
    );
  }
}

class _VisualizationHistory extends StatelessWidget {
  const _VisualizationHistory({required this.groups, required this.direction});

  final Axis direction;
  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyStyleProvider, Tuple2<Alignment, double>>(
      builder: (context, tuple, child) => Wrap(
        direction: direction,
        spacing: tuple.item2,
        runSpacing: tuple.item2,
        alignment: _wrapAlignment(tuple.item1),
        crossAxisAlignment: _crossAxisAlignment(tuple.item1),
        children: [
          for (int i = 0; i < groups.length; i++)
            _FadingKeyCapGroup(
              key: Key(groups[_showReversed(tuple.item1) ? groups.length - 1 - i : i]),
              groupId: groups[_showReversed(tuple.item1) ? groups.length - 1 - i : i],
              index: i,
              totalGroups: groups.length,
              direction: direction,
              alignment: tuple.item1,
            )
        ],
      ),
      selector: (_, keyStyle) => Tuple2(
        keyStyle.alignment,
        keyStyle.backgroundSpacing,
      ),
    );
  }

  bool _showReversed(Alignment alignment) {
    return alignment == Alignment.topLeft ||
        alignment == Alignment.topCenter ||
        alignment == Alignment.topRight;
  }

  WrapAlignment _wrapAlignment(Alignment alignment) {
    // showing history vertically
    if (direction == Axis.vertical) return WrapAlignment.start;

    switch (alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        return WrapAlignment.start;

      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        return WrapAlignment.center;

      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        return WrapAlignment.end;
    }

    return WrapAlignment.start;
  }

  WrapCrossAlignment _crossAxisAlignment(Alignment alignment) {
    // showing history horizontally
    if (direction == Axis.horizontal) return WrapCrossAlignment.start;

    switch (alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        return WrapCrossAlignment.start;

      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        return WrapCrossAlignment.center;

      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        return WrapCrossAlignment.end;
    }

    return WrapCrossAlignment.start;
  }
}

class _FadingKeyCapGroup extends StatelessWidget {
  const _FadingKeyCapGroup({
    Key? key,
    required this.groupId,
    required this.index,
    required this.totalGroups,
    required this.direction,
    required this.alignment,
  }) : super(key: key);

  final String groupId;
  final int index;
  final int totalGroups;
  final Axis direction;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    // Nếu không phải chiều dọc, không cần hiệu ứng fade
    if (direction != Axis.vertical) {
      return KeyCapGroup(
        key: Key(groupId),
        groupId: groupId,
      );
    }

    // Tính toán opacity dựa trên thứ tự hiển thị thực tế
    // Phím mới nhất có opacity = 1, phím cũ nhất có opacity = 0.3
    double opacity = 1.0;
    
    // Xác định vị trí tương đối (0 = cũ nhất, 1 = mới nhất)
    double relativePosition = index / (totalGroups - 1);
    
    // Đảo ngược vị trí nếu hiển thị từ dưới lên
    if (_showReversed(alignment)) {
      relativePosition = 1.0 - relativePosition;
    }
    
    // Tính opacity, giới hạn trong khoảng [0.3, 1.0]
    opacity = (relativePosition * 0.7 + 0.3).clamp(0.3, 1.0);
    
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      child: KeyCapGroup(
        key: Key(groupId),
        groupId: groupId,
      ),
    );
  }
}

bool _showReversed(Alignment alignment) {
  return alignment == Alignment.topLeft ||
      alignment == Alignment.topCenter ||
      alignment == Alignment.topRight;
}

