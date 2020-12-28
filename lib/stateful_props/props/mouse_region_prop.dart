import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../stateful_properties.dart';

/// Wraps MouseRegions. Reports current position of mouse in
/// both local and global coords. Also provides state like .isHovered,
/// and normalized (0-1) mouse coords, which it calculates using MediaQuery.size
/// TODO: Would be nice if this also stored local-relative position. Would need to use LayoutBuilder or `context.findRenderBox()` I think?
class MouseRegionProp extends StatefulProp<MouseRegionProp> {
  MouseRegionProp({this.onHover, this.onEnter, this.onExit});
  // Callbacks
  final void Function(PointerHoverEvent event) onHover;
  final void Function(PointerEnterEvent event) onEnter;
  final void Function(PointerExitEvent event) onExit;

  // Helper methods
  Offset get position => _pos;
  Offset get localPosition => _localPos;
  bool get isHovered => _isHovered;
  Offset get normalizedPosition => Offset(
        (position.dx / _viewSize.width).clamp(0.0, 1.0) as double,
        (position.dy / _viewSize.height).clamp(0.0, 1.0) as double,
      );

  // Internal state
  Size _viewSize = Size(1, 1);
  Offset _pos = Offset.zero;
  Offset _localPos = Offset.zero;
  bool _isHovered = false;

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    _viewSize = MediaQuery.of(context).size;
    return () => MouseRegion(
          onEnter: (m) {
            _handleMouseUpdate(isDown: true, position: m.position, localPosition: m.localPosition);
            onEnter?.call(m);
          },
          onExit: (m) {
            // Don't report position here, because it will jump to 0 when leaving the window. Usually not what we want.
            _handleMouseUpdate(isDown: false);
            onExit?.call(m);
          },
          onHover: (m) {
            _handleMouseUpdate(isDown: true, position: m.position, localPosition: m.localPosition);
            onHover?.call(m);
          },
          child: childBuilder(),
        );
  }

  void _handleMouseUpdate({bool isDown, Offset position, Offset localPosition}) {
    _isHovered = isDown;
    _pos = position ?? _pos;
    _localPos = localPosition ?? _localPos;
    setState(() {});
  }
}
