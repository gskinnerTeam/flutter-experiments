import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/props/primitive_props.dart';

import '../stateful_properties.dart';

class FutureProp<T> extends StatefulProp<FutureProp<T>> {
  FutureProp(this._initialFuture) {}

  //Internal State
  Future<T> _initialFuture;
  AsyncSnapshot<T> _snapshot;
  ValueProp<Future<T>> futureValue;

  // Helper methods
  AsyncSnapshot<T> get snapshot => _snapshot;
  T get value => _snapshot?.data ?? null;
  bool get isWaiting => _snapshot?.connectionState == ConnectionState.waiting;

  Future<T> get future => futureValue?.value;
  set future(Future<T> value) => futureValue?.value = value;

  @override
  void init() {
    // Shows composition, as we'll use a ValueProp to handle our 'did-change' check
    futureValue = addProp?.call(ValueProp(_initialFuture));
  }

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    return () => FutureBuilder<T>(
          future: futureValue.value,
          builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
            _snapshot = snapshot;
            return childBuilder();
          },
        );
  }
}
