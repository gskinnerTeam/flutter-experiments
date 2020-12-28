import 'dart:async';

import 'package:flutter/material.dart';

import '../stateful_properties.dart';

class LayoutProp extends StatefulProp<LayoutProp> {
  LayoutProp({this.key});
  Key key;
  BoxConstraints _constraints = BoxConstraints();
  BoxConstraints get constraints => _constraints;

  @override
  Widget Function() getBuilder(Widget Function() childBuilder) {
    return () => LayoutBuilder(
          key: key,
          builder: (_, constraints) {
            _constraints = constraints;
            return childBuilder();
          },
        );
  }
}
