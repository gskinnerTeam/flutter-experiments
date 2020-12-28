import 'package:flutter/material.dart';

import '../stateful_properties.dart';

// Core GestureDetector Property
// Usage: initProperty((_, __) => GestureProp(onTapDown: _handleTap, onTapUp: ..., etc));
class GestureProp extends StatefulProp<GestureProp> {
  GestureProp({this.onTap, this.onLongPress, this.behavior = HitTestBehavior.opaque});
  final HitTestBehavior behavior;
  // Callbacks
  void Function() onTap;
  void Function() onLongPress;

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    return () => GestureDetector(
          behavior: behavior,
          // TODO: Implement all the other 20+ callbacks for gestureDetector
          onTap: () => onTap?.call(),
          onLongPress: () => onLongPress?.call(),
          child: childBuilder(),
        );
  }

  @override
  void update(GestureProp newProp) {
    onTap = newProp.onTap;
    onLongPress = newProp.onLongPress;
  }
}

/// Demonstrates how we can extend an existing Prop, to focus it for a specific use case.
/// Tap is such a common use case, that having this accelerator is quite nice.
/// In this case, we're omitting the "onTap: " from GestureDetectorProp, and using a shorter name.
/// Usage: `addProp(TapProp(_handleTap))`
///         vs
///        `addProp(onTap: GestureDetectorProp(_handleTap))`
class TapProp extends GestureProp {
  TapProp(VoidCallback onTap) : super(onTap: onTap);

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    return super.getBuilder(childBuilder);
  }
}
