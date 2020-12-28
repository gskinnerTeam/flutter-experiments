// Create a custom hook-class in order to implement Throttle. (couldn't figure out how to do it with functional hooks)
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

Timer useThrottledEffect(VoidCallback effect, Duration duration, {bool leading, bool trailing}) {
  return use(_ThrottleHook(effect, duration, leading: leading, trailing: trailing));
}

class _ThrottleHook<T> extends Hook<Timer> {
  const _ThrottleHook(this.effect, this.duration, {this.leading = true, this.trailing = false});
  final Duration duration;
  final VoidCallback effect;
  final bool leading;
  final bool trailing;

  @override
  _ThrottleHookState<T> createState() => _ThrottleHookState();
}

class _ThrottleHookState<T> extends HookState<Timer, _ThrottleHook<T>> {
  Timer _timer;

  void _callEffect(Timer t) {
    hook.effect?.call();
    t.cancel();
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer?.cancel();
    }
  }

  @override
  Timer build(BuildContext context) {
    if (_timer == null || !_timer.isActive) {
      _timer = Timer.periodic(hook.duration, _callEffect);
      if (hook.leading) {
        hook.effect?.call();
      }
    }
    return _timer;
  }

  @override
  Object get debugValue => _timer;

  @override
  String get debugLabel => 'useThrottled<$T>';
}
