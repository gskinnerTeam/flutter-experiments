import 'dart:async';

import 'package:flutter/material.dart';

import '../stateful_properties.dart';

class LayoutProp extends StatefulProp<LayoutProp> {
  LayoutProp({this.key});
  Key key;

  //Helper methods
  BoxConstraints get constraints => _constraints;
  Size get parentSize => _constraints.biggest;
  Size get contextSize => _contextSize;

  //Internal state
  BoxConstraints _constraints = BoxConstraints();
  Size _contextSize = Size(1, 1);

  @override
  void init() {
    // In order to get a proper measurement for size
    scheduleMicrotask(() => setState(() {}));
    super.init();
  }

  @override
  void update(LayoutProp newProp) {
    key = newProp.key;
  }

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return () => LayoutBuilder(
          key: key,
          builder: (context, constraints) {
            _constraints = constraints;
            RenderBox rb = context.findRenderObject() as RenderBox;
            if (rb?.hasSize ?? false) {
              _contextSize = rb.size;
            }
            registerBuilderContext(context);
            return childBuilder();
          },
        );
  }
}
