import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_experiments/stateful_props/stateful_properties.dart';

import '../app_model.dart';

class CustomStatelessWidgetDemo extends MyStatelessWidget {
  static PageInfo info = PageInfo(
    title: "CustomStatelessWidget",
    sourceUrl: null, //"stateful_props/stateful_props_demo.dart",
  );

  void _handleTap() {
    // context is available even in a button handler!
    print("${state.context}");
    // And we can rebuild if we want
    state.setState?.call(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size s = MediaQuery.of(context).size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "This is a stateless widget, but it remembers it's build count, has a setState call, and access a .context property. Click to call setState() which will trigger a rebuild, and increment the buildCount."),
            Text("The widget remembers it's buildCount, WAT?!: ${state.buildCount}"),
          ],
        ),
      ),
    );
  }
}
// HOW IT WORKS:

// _AddMutableStateMixin + _MyStatelessElement = MyStatelessWidget
// _AddMutableStateMixin: Provides accessors to child Widgets
// _MyStatelessElement: takes care of passing the state from widget to widget

// PropsStatelessWidgetMixin adds a _state property to StatelessWidget and returns the _PropsStatelessElement()
// _PropsStatelessElement curries state from the oldWidget to the new and overrides the lifecycle methods as needed.

// Combines PropsStatelessWidgetMixin + StatefulPropsWidget widget into a single `extends` call
abstract class MyStatelessWidget extends StatelessWidget with _AddMutableStateMixin {}

// Used to curry data from one widget to another.
class _MutableState<T> {
  static const int foo2 = 0;
  final int foo = 0;

  T state;
}

// Store any persistent state you need here
class _MySecretState {
  int buildCount = 0;
  BuildContext context;
  void Function(VoidCallback) setState;
}

// A small mixin, that provides a place where we can pass an instance of state from widget to widget
mixin _AddMutableStateMixin on StatelessWidget {
  // Create a final variable that can wrap some state object instance
  final _MutableState<_MySecretState> _stateWrapper = _MutableState<_MySecretState>();

  _MySecretState get state => _stateWrapper.state;

  //Return the custom StatelessElement which does most of the work
  @override
  StatelessElement createElement() => _MyStatelessElement(this);
}

// This is actually the context, Element implements Context!
class _MyStatelessElement<W extends _AddMutableStateMixin> extends StatelessElement {
  _MySecretState _propsState = _MySecretState();
  // New element was created, this is the true first-mount for a StatelessWidget
  _MyStatelessElement(W widget) : super(widget) {
    _syncWidget(widget);
  }
  @override
  W get widget => super.widget as W;

  // A new widget has been created for this element, inject the state into the new widget
  @override
  void update(W newWidget) {
    print('update stateless element');
    // Push our state into the new widget
    _syncWidget(newWidget);
    super.update(newWidget);
  }

  void _syncWidget(W w) {
    w._stateWrapper.state = _propsState;
    w._stateWrapper.state.context = this;
    w._stateWrapper.state.setState = (VoidCallback fn) {
      fn?.call();
      this.markNeedsBuild();
    };
  }

  @override
  Widget build() {
    print('ComponentElement.build, count=${_propsState.buildCount}');
    // Update the 'stateless state'
    _propsState.buildCount++;
    return super.build();
  }
}
