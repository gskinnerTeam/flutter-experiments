import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/props/focus_prop.dart';
import 'package:flutter_experiments/stateful_props/props/keyboard_prop.dart';
import 'package:flutter_experiments/stateful_props/props/primitive_props.dart';
import 'package:flutter_experiments/stateful_props/stateful_props_widget.dart';

import '../stateful_prop_demo.dart';
import '../stateful_props_mixin.dart';

/// ///////////////////////////////////////////////////
/// Basic Keyboard Example
/// //////////////////////////////////////////////////
/// TODO: Add Desc

class BasicKeyboardExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      stateless: BasicKeyboardStateless(),
      stateful: BasicKeyboardStateful(),
      //classic: BasicKeyboardClassic(),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
//TODO ADD EXAMPLE

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////

class BasicKeyboardStateful extends StatefulWidget {
  @override
  _KeyboardExampleState createState() => _KeyboardExampleState();
}

class _KeyboardExampleState extends State<BasicKeyboardStateful> with StatefulPropsMixin {
  RawKeyEvent _lastkeyPressed;

  @override
  void initProps() {
    FocusProp nodeProp = addProp(FocusProp(canRequestFocus: false));
    addProp(KeyboardProp(onPressed: _handleKeyDown, focusNode: nodeProp.node));
  }

  void _handleKeyDown(RawKeyEvent event) => setState(() => _lastkeyPressed = event);

  @override
  Widget buildWithProps(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(),
        Text(
          "${_lastkeyPressed ?? "Start typing on the keyboard (Desktop/Web Only)"}",
        ),
      ],
    );
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////

class BasicKeyboardStateless extends PropsWidget {
  static Ref<ValueProp<RawKeyEvent>> _lastKeyPressed = Ref();
  static Ref<KeyboardProp> _keyboard = Ref();
  static Ref<FocusProp> _focus = Ref();

  @override
  void initProps() {
    final focus = addProp(_focus, FocusProp(canRequestFocus: false));
    addProp(_keyboard, KeyboardProp(onPressed: _handleKeyDown, focusNode: focus.node));
    addProp(_lastKeyPressed, ValueProp<RawKeyEvent>(null));
  }

  void _handleKeyDown(RawKeyEvent event) => setState(() => use(_lastKeyPressed).value = event);

  @override
  Widget buildWithProps(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFormField(),
        Text(
          "${use(_lastKeyPressed).value ?? "Start typing on the keyboard (Desktop/Web Only)"}",
        ),
      ],
    );
  }
}
