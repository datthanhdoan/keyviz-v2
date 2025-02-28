import 'package:flutter/material.dart';
import 'package:keyviz/providers/key_event.dart';
import 'package:keyviz/providers/key_style.dart';
import 'package:provider/provider.dart';

class KeyCap extends StatelessWidget {
  const KeyCap({
    super.key,
    required this.keyId,
    required this.groupId,
    this.opacity = 1.0,
  });

  final int keyId;
  final String groupId;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final keyEvent = context.keyEvent;
    final keyStyle = context.keyStyle;

    final event = keyEvent.keyboardEvents[groupId]?[keyId];
    if (event == null) return const SizedBox.shrink();

    final label = event.label;
    final icon = event.icon;
    final isPressed = event.pressed;
    final showPressCount = event.showPressCount;
    final pressedCount = event.pressedCount;

    final keyCapStyle = keyStyle.keyCapStyle;
    final keyCapHeight = keyCapStyle.height;
    final keyCapWidth = keyCapStyle.width;
    final keyCapBorderRadius = keyCapStyle.borderRadius;
    final keyCapBorderWidth = keyCapStyle.borderWidth;
    final keyCapPadding = keyCapStyle.padding;
    final keyCapTextStyle = keyCapStyle.textStyle;
    final keyCapIconSize = keyCapStyle.iconSize;

    final keyCapBackgroundColor = keyCapStyle.backgroundColor;
    final keyCapBorderColor = keyCapStyle.borderColor;
    final keyCapTextColor = keyCapStyle.textColor;
    final keyCapIconColor = keyCapStyle.iconColor;

    final keyCapPressedBackgroundColor = keyCapStyle.pressedBackgroundColor;
    final keyCapPressedBorderColor = keyCapStyle.pressedBorderColor;
    final keyCapPressedTextColor = keyCapStyle.pressedTextColor;
    final keyCapPressedIconColor = keyCapStyle.pressedIconColor;

    final backgroundColor =
        isPressed ? keyCapPressedBackgroundColor : keyCapBackgroundColor;
    final borderColor =
        isPressed ? keyCapPressedBorderColor : keyCapBorderColor;
    final textColor = isPressed ? keyCapPressedTextColor : keyCapTextColor;
    final iconColor = isPressed ? keyCapPressedIconColor : keyCapIconColor;

    final keyCapAnimation = keyEvent.keyCapAnimation;
    final noKeyCapAnimation = keyEvent.noKeyCapAnimation;
    final animationDuration = keyEvent.animationDuration;

    final show = event.show;

    Widget child;

    if (icon != null) {
      child = Icon(
        IconData(
          int.parse(icon, radix: 16),
          fontFamily: 'MaterialIcons',
        ),
        size: keyCapIconSize,
        color: iconColor.withOpacity(opacity),
      );
    } else {
      child = Text(
        label,
        style: keyCapTextStyle.copyWith(
          color: textColor.withOpacity(opacity),
        ),
      );
    }

    // Thêm hiển thị số lần bấm phím nếu cần
    if (showPressCount && pressedCount > 1) {
      child = Stack(
        clipBehavior: Clip.none, // Cho phép vẽ ra ngoài phạm vi Stack
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9 * opacity),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2 * opacity),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'x$pressedCount',
                style: TextStyle(
                  color: Colors.white.withOpacity(opacity),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final keyCap = Container(
      height: keyCapHeight,
      width: keyCapWidth,
      padding: keyCapPadding,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(opacity),
        borderRadius: keyCapBorderRadius,
        border: Border.all(
          color: borderColor.withOpacity(opacity),
          width: keyCapBorderWidth,
        ),
      ),
      child: Center(child: child),
    );

    if (noKeyCapAnimation) return keyCap;

    switch (keyCapAnimation) {
      case KeyCapAnimationType.none:
        return keyCap;

      case KeyCapAnimationType.fade:
        return AnimatedOpacity(
          opacity: show ? 1.0 : 0.0,
          duration: animationDuration,
          child: keyCap,
        );

      case KeyCapAnimationType.wham:
        return AnimatedScale(
          scale: show ? 1.0 : 1.5,
          duration: animationDuration,
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: animationDuration,
            child: keyCap,
          ),
        );

      case KeyCapAnimationType.grow:
        return AnimatedScale(
          scale: show ? 1.0 : 0.0,
          duration: animationDuration,
          child: keyCap,
        );

      case KeyCapAnimationType.slide:
        return AnimatedSlide(
          offset: show ? Offset.zero : const Offset(0, 1),
          duration: animationDuration,
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: animationDuration,
            child: keyCap,
          ),
        );
    }
  }
} 