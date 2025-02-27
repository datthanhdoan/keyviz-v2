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
      builder: (context, tuple, child) {
        // Nếu là hiển thị theo chiều dọc, sử dụng container với gradient
        if (direction == Axis.vertical) {
          return _VerticalGradientHistory(
            groups: groups,
            alignment: tuple.item1,
            spacing: tuple.item2,
          );
        }
        
        // Nếu là hiển thị theo chiều ngang, giữ nguyên cách hiển thị cũ
        return Wrap(
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
        );
      },
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

// Widget mới để hiển thị lịch sử theo chiều dọc với gradient
class _VerticalGradientHistory extends StatefulWidget {
  const _VerticalGradientHistory({
    required this.groups,
    required this.alignment,
    required this.spacing,
  });

  final List<String> groups;
  final Alignment alignment;
  final double spacing;

  @override
  State<_VerticalGradientHistory> createState() => _VerticalGradientHistoryState();
}

class _VerticalGradientHistoryState extends State<_VerticalGradientHistory> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    // Tạo animation controller để điều khiển hiệu ứng fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeController.forward();
  }
  
  @override
  void didUpdateWidget(_VerticalGradientHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi có phím mới được thêm vào, reset animation
    if (widget.groups.length != oldWidget.groups.length) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Xác định hướng hiển thị dựa vào alignment
    final bool isReversed = _showReversed(widget.alignment);
    
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _getColumnAlignment(widget.alignment),
          children: [
            for (int i = 0; i < widget.groups.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i < widget.groups.length - 1 ? widget.spacing : 0),
                child: AnimatedOpacity(
                  // Kết hợp cả hai logic fade:
                  // 1. Fade theo vị trí (phím càng lên cao càng mờ dần)
                  // 2. Fade theo thời gian (phím mới thêm vào sẽ hiện dần)
                  opacity: _calculateCombinedOpacity(i, widget.groups.length, isReversed),
                  duration: const Duration(milliseconds: 300),
                  child: KeyCapGroup(
                    key: Key(widget.groups[isReversed ? widget.groups.length - 1 - i : i]),
                    groupId: widget.groups[isReversed ? widget.groups.length - 1 - i : i],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Tính toán opacity kết hợp cả vị trí và thời gian
  double _calculateCombinedOpacity(int index, int total, bool isReversed) {
    if (total <= 1) return _fadeController.value;
    
    // Vị trí tương đối (0 = đầu, 1 = cuối)
    double relativePosition = index / (total - 1);
    
    // Đảo ngược vị trí nếu cần - đảm bảo phím mới nhất luôn sáng nhất
    if (isReversed) {
      relativePosition = 1.0 - relativePosition;
    }
    
    // Opacity theo vị trí: phím mới nhất có opacity = 1.0, phím cũ nhất có opacity = 0.3
    double positionOpacity = (0.3 + 0.7 * relativePosition).clamp(0.3, 1.0);
    
    // Kết hợp với opacity theo thời gian (animation)
    // Phím mới thêm vào sẽ có hiệu ứng fade in
    double timeOpacity = index == (isReversed ? 0 : total - 1) ? _fadeController.value : 1.0;
    
    // Kết hợp cả hai loại opacity
    return (positionOpacity * timeOpacity).clamp(0.0, 1.0);
  }

  CrossAxisAlignment _getColumnAlignment(Alignment alignment) {
    switch (alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        return CrossAxisAlignment.start;

      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        return CrossAxisAlignment.center;

      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        return CrossAxisAlignment.end;
    }

    return CrossAxisAlignment.center;
  }
}

class _FadingKeyCapGroup extends StatefulWidget {
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
  State<_FadingKeyCapGroup> createState() => _FadingKeyCapGroupState();
}

class _FadingKeyCapGroupState extends State<_FadingKeyCapGroup> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  
  @override
  void initState() {
    super.initState();
    // Tạo animation controller để điều khiển hiệu ứng fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán opacity dựa trên thứ tự hiển thị thực tế
    // Phím mới nhất có opacity = 1, phím cũ nhất có opacity = 0.3
    
    // Xác định vị trí tương đối (0 = cũ nhất, 1 = mới nhất)
    double relativePosition = widget.index / (widget.totalGroups - 1);
    
    // Đảo ngược vị trí nếu hiển thị từ dưới lên hoặc từ phải qua trái
    bool shouldReverse = _showReversed(widget.alignment);
    if (shouldReverse) {
      relativePosition = 1.0 - relativePosition;
    }
    
    // Tính opacity theo vị trí, giới hạn trong khoảng [0.3, 1.0]
    double positionOpacity = (0.3 + 0.7 * relativePosition).clamp(0.3, 1.0);
    
    // Kết hợp với opacity theo thời gian (animation)
    // Phím mới thêm vào sẽ có hiệu ứng fade in
    double opacity = (positionOpacity * _fadeController.value).clamp(0.0, 1.0);
    
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      child: KeyCapGroup(
        key: Key(widget.groupId),
        groupId: widget.groupId,
      ),
    );
  }
}

bool _showReversed(Alignment alignment) {
  return alignment == Alignment.topLeft ||
      alignment == Alignment.topCenter ||
      alignment == Alignment.topRight;
}

