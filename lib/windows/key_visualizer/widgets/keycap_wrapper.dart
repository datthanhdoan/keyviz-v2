import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keyviz/providers/providers.dart';

import 'animations/animations.dart';
import 'keycaps/keycaps.dart';

class KeyCapWrapper extends StatelessWidget {
  const KeyCapWrapper({super.key, required this.groupId, required this.keyId});

  final String groupId;
  final int keyId;

  @override
  Widget build(BuildContext context) {
    return Selector<KeyEventProvider, KeyEventData?>(
      builder: (context, event, _) {
        return event == null
            ? const SizedBox()
            : _AnimationWrapper(
                show: event.show,
                opacity: event.opacity,
                child: _KeyCap(event),
              );
      },
      selector: (_, keyStyle) => keyStyle.keyboardEvents[groupId]?[keyId],
    );
  }
}

class _AnimationWrapper extends StatelessWidget {
  const _AnimationWrapper({
    required this.show,
    required this.opacity,
    required this.child,
  });

  final bool show;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = context.read<KeyEventProvider>().keyCapAnimation;
    
    // Bọc widget con trong Opacity để áp dụng hiệu ứng fade
    final wrappedChild = Opacity(
      opacity: opacity,
      child: child,
    );
    
    switch (animation) {
      case KeyCapAnimationType.none:
        return wrappedChild;

      case KeyCapAnimationType.fade:
        return FadeKeyCapAnimation(show: show, child: wrappedChild);

      case KeyCapAnimationType.slide:
        return SlideKeyCapAnimation(show: show, child: wrappedChild);

      case KeyCapAnimationType.grow:
        return GrowKeyCapAnimation(show: show, child: wrappedChild);

      case KeyCapAnimationType.wham:
        return WhamKeyCapAnimation(show: show, child: wrappedChild);
    }
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.event);

  final KeyEventData event;

  @override
  Widget build(BuildContext context) {
    final keyCapStyle = context.select<KeyStyleProvider, KeyCapStyle>(
      (keyStyle) => keyStyle.keyCapStyle,
    );
    switch (keyCapStyle) {
      case KeyCapStyle.minimal:
        return MinimalKeyCap(event: event);

      case KeyCapStyle.flat:
        return FlatKeyCap(event: event);

      case KeyCapStyle.elevated:
        return ElevatedKeyCap(event: event);

      case KeyCapStyle.plastic:
        return PlasticKeyCap(event: event);

      // case KeyCapStyle.retro:
      //   return RetroKeyCap(event: event);

      case KeyCapStyle.mechanical:
        return MechanicalKeyCap(event: event);
    }
  }
}
