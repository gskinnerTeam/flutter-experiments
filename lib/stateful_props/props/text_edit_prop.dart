import 'package:flutter/widgets.dart';
import 'package:flutter_experiments/stateful_props/stateful_properties.dart';

class TextEditProp extends StatefulProp<TextEditProp> {
  TextEditProp({String text, this.onChanged}) {
    _initialText = text;
  }
  // Callbacks
  final void Function(TextEditProp) onChanged;

  // Helper methods
  String get text => _controller.text;
  TextEditingController get controller => _controller;

  // Internal state
  String _initialText;
  TextEditingController _controller;

  @override
  void init() {
    _controller = TextEditingController(text: _initialText);
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() => onChanged?.call(this);

  @override
  void dispose() => _controller.dispose();
}
