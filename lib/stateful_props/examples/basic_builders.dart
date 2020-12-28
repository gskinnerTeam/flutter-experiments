import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/props/future_prop.dart';
import 'package:flutter_experiments/stateful_props/props/gesture_prop.dart';
import 'package:flutter_experiments/stateful_props/props/layout_prop.dart';
import 'package:flutter_experiments/stateful_props/stateful_props_widget.dart';
import 'package:provider/provider.dart';

import '../stateful_prop_demo.dart';
import '../stateful_props_mixin.dart';

/// ///////////////////////////////////////////////////
/// Basic Builder Example
/// //////////////////////////////////////////////////
/// Show a Future and Layout Builder in use
///
class BasicBuilderExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return Provider<int>.value(
      value: 0,
      child: ComparisonStack(
        //classic: BasicBuilderClassic(),
        //stateful: BasicBuilderStateful(),
        stateless: BasicBuilderStateless(),
      ),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
class BasicBuilderClassic extends StatefulWidget {
  @override
  _BasicBuilderClassicState createState() => _BasicBuilderClassicState();
}

class _BasicBuilderClassicState extends State<BasicBuilderClassic> {
  Future<int> _currentFuture;

  @override
  void initState() {
    _currentFuture = _loadData();
    super.initState();
  }

  // Wait 1 second, return random Integer
  Future<int> _loadData() => Future.delayed(Duration(seconds: 1), () => Random().nextInt(999));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _currentFuture = _loadData();
      }),
      child: LayoutBuilder(builder: (_, constraints) {
        return FutureBuilder<int>(
            future: _currentFuture,
            builder: (_, snapshot) {
              bool hasLoaded = snapshot?.connectionState != ConnectionState.waiting;
              int loadedValue = snapshot.data;
              double maxWidth = constraints.maxWidth;

              return Container(
                alignment: Alignment.center,
                child: Text("${maxWidth}, future=${hasLoaded ? loadedValue : "Loading..."}"),
              );
            });
      }),
    );
  }
}

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////
class BasicBuilderStateful extends StatefulWidget {
  @override
  _BasicBuilderStatefulState createState() => _BasicBuilderStatefulState();
}

class _BasicBuilderStatefulState extends State<BasicBuilderStateful> with StatefulPropsMixin {
  LayoutProp layout;
  FutureProp<int> someFuture;

  @override
  void initProps() {
    layout = addProp(LayoutProp());
    someFuture = addProp(FutureProp(_loadData()));
    addProp(TapProp(() => someFuture.future = _loadData()));
  }

  // Wait 1 second, return random Integer
  Future<int> _loadData() => Future.delayed(Duration(seconds: 1), () => Random().nextInt(999));

  @override
  Widget buildWithProps(BuildContext context) {
    bool hasLoaded = !someFuture.isWaiting;
    int loadedValue = someFuture.value;
    double maxWidth = layout.constraints.maxWidth;
    //print(context.watch<int>());
    return Container(
      alignment: Alignment.center,
      child: Text("${maxWidth}, future=${hasLoaded ? loadedValue : "Loading..."}"),
    );
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicBuilderStateless extends PropsWidget {
  static const Ref<LayoutProp> _layout = Ref();
  static const Ref<FutureProp<int>> _someFuture = Ref();
  static const Ref<TapProp> _tap = Ref();

  @override
  void initProps() {
    addProp(_layout, LayoutProp());
    addProp(_someFuture, FutureProp(_loadData()));
    addProp(_tap, TapProp(() => use(_someFuture).future = _loadData()));
  }

  // Wait 1 second, return random Integer
  Future<int> _loadData() => Future.delayed(Duration(seconds: 1), () => Random().nextInt(999));

  @override
  Widget buildWithProps(BuildContext context) {
    FutureProp<int> future = use(_someFuture);
    bool hasLoaded = !future.isWaiting;
    int loadedValue = future.value;
    double maxWidth = use(_layout).constraints.maxWidth;
    print(context.read<int>());
    return Container(
      alignment: Alignment.center,
      child: Text("${maxWidth}, future=${hasLoaded ? loadedValue : "Loading..."}"),
    );
  }
}