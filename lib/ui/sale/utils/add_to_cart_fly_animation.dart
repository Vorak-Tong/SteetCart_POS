import 'dart:async';

import 'package:flutter/material.dart';

final GlobalKey cartBottomNavIconKey = GlobalKey(debugLabel: 'cartBottomNav');

Future<void> playAddToCartFlyAnimation(
  BuildContext context, {
  required GlobalKey sourceKey,
  GlobalKey? targetKey,
  required Widget flightWidget,
  Duration duration = const Duration(milliseconds: 190),
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final sourceContext = sourceKey.currentContext;
  final targetContext = (targetKey ?? cartBottomNavIconKey).currentContext;
  if (sourceContext == null || targetContext == null) return;

  final sourceBox = sourceContext.findRenderObject() as RenderBox?;
  final targetBox = targetContext.findRenderObject() as RenderBox?;
  if (sourceBox == null || targetBox == null) return;
  if (!sourceBox.hasSize || !targetBox.hasSize) return;

  final beginOffset = sourceBox.localToGlobal(Offset.zero);
  final beginRect = beginOffset & sourceBox.size;

  final targetTopLeft = targetBox.localToGlobal(Offset.zero);
  final targetSize = targetBox.size;
  final targetCenter = targetTopLeft + targetSize.center(Offset.zero);

  final endRect = Rect.fromCenter(
    center: targetCenter,
    width: 14,
    height: 14,
  );

  final completer = Completer<void>();
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _FlyToCartOverlay(
      beginRect: beginRect,
      endRect: endRect,
      duration: duration,
      child: flightWidget,
      onCompleted: () {
        entry.remove();
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    ),
  );

  overlay.insert(entry);
  await completer.future;
}

class _FlyToCartOverlay extends StatefulWidget {
  const _FlyToCartOverlay({
    required this.beginRect,
    required this.endRect,
    required this.duration,
    required this.child,
    required this.onCompleted,
  });

  final Rect beginRect;
  final Rect endRect;
  final Duration duration;
  final Widget child;
  final VoidCallback onCompleted;

  @override
  State<_FlyToCartOverlay> createState() => _FlyToCartOverlayState();
}

class _FlyToCartOverlayState extends State<_FlyToCartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  late final Animation<Rect?> _rect = RectTween(
    begin: widget.beginRect,
    end: widget.endRect,
  ).animate(_t);

  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1, curve: Curves.easeOut),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final rect = _rect.value;
          if (rect == null) return const SizedBox.shrink();

          return Stack(
            children: [
              Positioned.fromRect(
                rect: rect,
                child: Opacity(
                  opacity: _opacity.value,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
