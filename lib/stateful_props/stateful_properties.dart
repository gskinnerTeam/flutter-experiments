import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/stateful_props_widget.dart';

extension SecondsToDurationExtension on double {
  Duration get duration => Duration(milliseconds: (this * 1000).round());
}

extension DurationToSecondsExtension on Duration {
  double get seconds => this.inMilliseconds * .001;
}

// The core engine that manages props for both the StatefulPropsMixin and StatefulPropsWidget:
// * maintains a list of each Prop
// * calls lifecycle methods on each Prop (init, didUpdate, dispose)
// * Requires setState, context and widget instances. Provided by [StatefulPropsMixin] or [StatefulPropsWidget]
// * Injects `context` and `setState` into each Prop
class StatefulPropsManager {
  static bool logDuplicateRefWarnings = true;

  // List of all props that have been registered.
  // Props can not be removed, only added. Their lifecycle is entirely bound to the owning State or Widget.
  List<StatefulProp<dynamic>> _values = [];
  Map<Object, StatefulProp<dynamic>> _propsByKey = {};
  int buildCount = 0;

  // Widget/State Dependencies
  void Function(VoidCallback) setState;
  BuildContext context;
  Widget widget;
  bool mounted = false;
  bool initPropsComplete = false;

  // Calls addProp() and also injects the create method into the prop, so it can be called later.
  T syncProp<T>(StatefulProp<dynamic> Function(BuildContext c, Widget w) create, [String restoreId]) {
    // Use the builder to create the first instance of the property.
    StatefulProp<dynamic> prop = addProp(create(context, widget));
    // Inject the create builder so we can compare on didUpdateWidget
    prop.create = create;
    return prop as T;
  }

  // Add a new statefulProperty that we will keep track of.  This should only ever be called from StatefulWidget.initState()
  T addProp<T>(StatefulProp<dynamic> prop, [String restoreId]) {
    assert(context != null, '''
      Looks like you're trying to addProp/syncProp before the StatefulPropManger has been initialized. Make sure you've called initState.super() before calling add/syncProp. Or just override initProp() instead.''');
    // Inject common hooks needed for all Props
    prop.context = context;
    prop.restoreId = restoreId;
    prop.setState = this.setState;
    prop.addProp = addProp;
    prop.syncProp = syncProp;
    _values.add(prop);
    prop.init();
    return prop as T;
  }

  T syncPropKeys<T extends StatefulProp<dynamic>>(Ref<T> ref, T Function(BuildContext c, Widget w) create,
      [String restoreId]) {
    // The first time this is called for a given create method, call the method, and cache the result.
    if (_propsByKey.containsKey(ref) == false) {
      // Use SyncProp to add the object, inject `create` and return us the new instance
      _propsByKey[ref] = syncProp(create, restoreId);
    } else if (logDuplicateRefWarnings) {
      print(
          "WARNING @ $widget: syncProp(Ref) was called twice on the same Ref. Check that you aren't calling syncProp() twice on the same reference, this is likely a mistake.");
    }
    // All future requests fo the object, get the cache
    return _propsByKey[ref] as T;
  }

  T addPropWithKey<T extends StatefulProp<dynamic>>(Ref<T> key, T prop, [String restoreId]) {
    if (_propsByKey.containsKey(key) == false) {
      // Add prop to Map and register with the manager using the same addProp() as the StatefulMixin
      _propsByKey[key] = prop;
      addProp(prop);
    } else if (logDuplicateRefWarnings) {
      print(
          "WARNING @ $widget: addProp(Ref) was called twice on the same Ref object. Check that you aren't calling addProp() twice with the same reference, this is likely a mistake.");
    }
    return prop;
  }

  T useProp<T extends StatefulProp<dynamic>>(Ref<T> ref) {
    //assert(_propsByRef.containsKey(ref),"You appear to be using a PropRef before it has been added or sync'd. Make sure addProp(refA) or syncProp(refA) has been called before you call useRef(refA))");
    if (_propsByKey.containsKey(ref)) {
      return _propsByKey[ref] as T;
    }
    return null;
  }

  // Wrap local build() call in additional "parent" build calls. Fire them all at the end.
  // This ensures the local build() call goes last and gets the latest state from the builders above it.
  Widget buildProps(Widget Function() childBuild) {
    _values.forEach((prop) => childBuild = prop.getBuilder(childBuild));
    return childBuild();
  }

  // Use the current widget, to create a new Prop. Pass that new Prop to each existing one so they can update themselves.
  void didUpdateWidget() {
    _values.forEach((property) {
      // Sync any props that have a create method
      if (property.create != null) {
        StatefulProp<dynamic> newProp = property.create(context, widget);
        property.update(newProp);
      }
    });
  }

  // This implements one of the required methods for RestorationMixin. Iterate each property, and give it a chance to restore itself.
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    _values.forEach((prop) {
      if (prop.restoreId != null) {
        // Ignore the protected warning here. Since Props are always a child of some state, they can act as restoration delegates
        // ignore: invalid_use_of_protected_member,
        prop.restoreState((this as RestorationMixin).registerForRestoration);
      }
    });
  }

  void dispose() => _values.forEach((p) => p.dispose());
}

// Extend this base class to create your own StatefulProperty. Every method is optional, implement only what you need.
// Available overrides are: init(), build(), update(), dispose(), restoreState()
abstract class StatefulProp<T> {
  /// ////////////////////////////////
  /// Life cycle
  // Optional: Create whatever state you need to store, if any (maybe you are only wrapping events, like
  // GestureDetector, or data, like LayoutBuilder).
  @protected
  void init() {}

  // Optional: Wrap builders Widgets here if needed, (like GestureDetector())
  @protected
  Widget Function() getBuilder(Widget Function() childBuild) => childBuild;

  // Optional: Update internal state if the Widget has changed (like animation.duration)
  @protected
  void update(T newProp) {}

  // Optional: Implement if you have something to cleanup (textEditingController.dispose)
  @protected
  void dispose() {}

  // Utility method to reduce boilerplate when implementing didChangeUpdates.
  bool didChange<T>(T oldVal, T newVal) {
    return oldVal != newVal && newVal != null;
  }

  // Optional: Support Restoration; call `register()` with any RestorableValues you have internally.
  @protected
  void restoreState(void Function(RestorableProperty<Object> property, String restorationId) register) {}

  /// ////////////////////////////////
  /// Internal

  ///
  // Injected by the [StatefulPropertyMixin], create a StatefulProperty instance from a Widget
  @protected
  StatefulProp<dynamic> Function(BuildContext c, Widget widget) create;

  // Injected by the [StatefulPropertyMixin], rebuilds state when Property desires it
  @protected
  void Function(VoidCallback fn) setState;

  // Injected by the the manager when a prop is added
  @protected
  BuildContext context;

  // The Add/Sync methods are injected from the manager so props can register sub-props allowing composition
  T Function<T>(StatefulProp<dynamic> prop, [String restoreId]) addProp;
  T Function<T>(StatefulProp<dynamic> Function(BuildContext c, Widget w) create, [String restoreId]) syncProp;

  /// Restoration
  // Injected when calling [ StatefulPropertyMixin.registerProperty(restoreId: "foo") ]
  @protected
  String restoreId;
}
