import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/props/primitive_props.dart';

import '../stateful_properties.dart';

//TODO:
// * Add some sort of caching, make .future cached by default and replace(future)
// * Respect initialData
// * Add maintainState bool
class FutureProp<T> extends StatefulProp<FutureProp<T>> {
  FutureProp(
    this.initialFuture, {
    this.initialData,
    this.key,
  }) {}
  Future<T> initialFuture;
  T initialData;
  Key key;

  // Helper methods
  AsyncSnapshot<T> get snapshot => _snapshot;
  T get value => _snapshot?.data ?? null;
  bool get isWaiting => _snapshot?.connectionState == ConnectionState.waiting;

  Future<T> get future => futureValue?.value;
  set future(Future<T> value) => futureValue?.value = value;

  //Internal State
  AsyncSnapshot<T> _snapshot;
  ValueProp<Future<T>> futureValue; // Handles rebuilds when future changes

  @override
  void init() {
    // Use a ValueProp to handle our 'did-change' check
    futureValue = addProp?.call(ValueProp(initialFuture));
    print("Init Future");
  }

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    return () => FutureBuilder<T>(
          future: futureValue.value,
          key: key,
          initialData: initialData,
          builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
            print("Build Future");
            _snapshot = snapshot;
            return childBuilder();
          },
        );
  }
}
