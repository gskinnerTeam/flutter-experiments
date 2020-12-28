import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Lifecycle
// Call init() and dispose() callbacks when the State is created and destroyed
void useInitWithDispose(Dispose Function() initWithDispose) {
  useEffect(initWithDispose, []);
}

// Calls init() callback when State is first created
void useInit(VoidCallback effect) {
  useInitWithDispose(() {
    effect?.call();
    return null;
  });
}

// Calls dispose() callback when state is destroyed
void useDispose(VoidCallback effect) {
  useInitWithDispose(() {
    // Do nothing, just return the effect for the dispose
    return effect;
  });
}

// Returns whether this is the first build() call for the Widget
bool useFirstBuildState() {
  ValueNotifier<bool> firstBuild = useState(true);
  if (firstBuild.value) {
    firstBuild.value = false;
    return true;
  }
  return false;
}

// Ignores the first build call, otherwise identical to useEffect
void useUpdateEffect(Dispose Function() effect, [List<Object> keys]) {
  bool firstBuild = useFirstBuildState();
  useEffect(() {
    if (!firstBuild) {
      return effect?.call();
    }
    return null;
  }, keys);
}

Timer useDebouncedEffect(Duration duration, VoidCallback callback) {
  Timer t;
  useEffect(() {
    t = Timer.periodic(duration, (timer) {
      callback?.call();
      timer.cancel();
    });
    return t.cancel;
  });
  return t;
}

// Callbacks
Timer useInterval(VoidCallback callback, Duration duration) {
  final t = useMemoized(() => Timer.periodic(duration, (timer) => callback?.call()));
  return t;
}

Timer useTimeout(VoidCallback callback, Duration duration) {
  final t = useMemoized(() => Timer.periodic(duration, (timer) {
        timer.cancel();
        callback?.call();
      }));
  return t;
}

// A more robust animation controller that allows for common use cases like delay, autoStart and building on tick
AnimationController useAnimController(
  Duration duration, {
  String debugLabel,
  double initialValue = 0,
  double lowerBound = 0,
  double upperBound = 1,
  TickerProvider vsync,
  AnimationBehavior animationBehavior = AnimationBehavior.normal,
  void Function(AnimationController) onStart,
  Duration delay = Duration.zero,
  bool listen = true,
  List<Object> keys,
}) {
  final c = useAnimationController(
      duration: duration,
      debugLabel: debugLabel,
      initialValue: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
      vsync: vsync,
      animationBehavior: animationBehavior);
  // useState so we only respect the initial value (can't conditionally call useListenable?)
  final listenNotifier = useState(listen);
  if (listenNotifier.value) useListenable(c);
  // Call onStart, delay it if needed
  useEffect(() {
    Future.delayed(delay, () => onStart?.call(c));
    return null;
  }, []);
  return c;
}
