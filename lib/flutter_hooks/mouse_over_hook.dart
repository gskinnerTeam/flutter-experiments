// Create a custom hook-class in order to implement Throttle. (couldn't figure out how to do it with functional hooks)
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

bool useMouseOver() => use(_MouseOverHook());

class _MouseOverHook<T> extends Hook<bool> {
  const _MouseOverHook({this.duration, this.effect});
  final Duration duration;
  final VoidCallback effect;

  @override
  _MouseOverHookState<T> createState() => _MouseOverHookState();
}

class _MouseOverHookState<T> extends HookState<bool, _MouseOverHook<T>> {
  bool _isMouseOver = false;

  @override
  bool build(BuildContext context) {
    return _isMouseOver;
  }

  @override
  Object get debugValue => _isMouseOver;

  @override
  String get debugLabel => 'useThrottled<$T>';
}
