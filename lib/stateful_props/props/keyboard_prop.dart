import 'package:flutter/widgets.dart';
import 'package:flutter_experiments/stateful_props/stateful_properties.dart';

//TODO: Update RawKeyboardProp so it can make it's own node internally... ideally it can use the Property?
// How? We should be able use addProp and syncProp, as long as make sure to only run it once...
// That means we either do it in init(), or very carefully in didUpdate... init() is problematic.
// We basically want a lazy addProp and syncProp implementation... where something is added on request, and only once.
class KeyboardProp extends StatefulProp<KeyboardProp> {
  KeyboardProp({
    this.key,
    @required this.focusNode,
    this.autofocus = true,
    this.includeSemantics = true,
    this.onKey,
  });
  final Key key;
  final FocusNode focusNode;
  final bool autofocus;
  final bool includeSemantics;

  // Callbacks
  ValueChanged<RawKeyEvent> onKey;

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    return () => RawKeyboardListener(
          focusNode: focusNode,
          autofocus: autofocus,
          includeSemantics: includeSemantics,
          onKey: onKey,
          key: key,
          child: FocusScope(child: childBuilder(), autofocus: autofocus),
        );
  }
}
