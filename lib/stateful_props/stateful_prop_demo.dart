import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_experiments/app_model.dart';
import 'package:flutter_experiments/stateful_props/examples/basic_animator.dart';

import 'examples/basic_builders.dart';
import 'examples/basic_focus.dart';
import 'examples/basic_keyboard.dart';
import 'examples/basic_text_controller.dart';
import 'examples/scroll_to_top_example.dart';
import 'examples/sync_props_example.dart';
import 'stateful_props_widget.dart';

/**
 *
 * ISSUES:
 *  * Props need add/sync build
 *  * Better syntax for keys...
 *  * All use in init()...
 *
 * TODO:
 * SizeProp
 *  * Need some sort of context-aware Timer/Delay...

 * TabController
 * StreamBuilder

 * // LayoutBuilder
 // FutureBuilder
 // LayoutProp
 * // KeyboardListener!!
 * // ScrollController
 * // PageController
 * // TextEditingController
 * // FocusNode
 * // AnimationController
 */

// Create a list of experiments/tests
class Experiment {
  final String title;
  final Widget Function() builder;
  Experiment(this.title, this.builder);
}

List<Experiment> widgets = [
  Experiment("BasicBuilderExample", () => BasicBuilderExample()),
  Experiment("BasicAnimator", () => BasicAnimatorExample()),
  Experiment("BasicTextController", () => BasicTextControllerExample()),
  Experiment("BasicSync", () => SyncExample()),
  Experiment("KeyboardListener", () => BasicKeyboardExample()),
  Experiment("FocusNode", () => BasicFocusExample()),
  Experiment("ScrollToTopAndFadeIn", () => ScrollToTopExample()),
];

class StatefulPropsDemo extends StatefulWidget {
  static PageInfo info = PageInfo(
    title: "StatefulProps",
    sourceUrl: "stateful_props/stateful_props_demo.dart",
  );

  @override
  _StatefulPropsDemoState createState() => _StatefulPropsDemoState();
}

class _StatefulPropsDemoState extends State<StatefulPropsDemo> with SingleTickerProviderStateMixin {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    Widget _makeBtn(int index) => FlatButton(
          onPressed: () => setState(() => _index = index),
          child: Text(widgets[index].title),
          padding: EdgeInsets.symmetric(vertical: 40),
        );
    return RootRestorationScope(
      restorationId: "statefulDemo",
      child: Column(children: [
        // Content
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: widgets[_index].builder.call(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widgets.length, (index) {
            return Expanded(child: _makeBtn(index));
          }),
        )
      ]),
    );
  }
}

class ComparisonStack extends PropsWidget {
  ComparisonStack({this.stateless, this.stateful, this.classic});
  final PropsWidget stateless;
  final Widget stateful;
  final Widget classic;

  @override
  Widget buildWithProps(BuildContext context) {
    Widget _color(Color c, Widget child) => Container(color: c, child: child);
    Widget _header(String title) =>
        Expanded(child: Container(color: Colors.white.withOpacity(.2), child: Center(child: Text(title)), height: 40));
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Row(key: ValueKey(Random().nextDouble()), children: [
            if (classic != null) Expanded(child: _color(Colors.grey.shade100, classic)),
            if (stateful != null) Expanded(child: _color(Colors.red.shade100, stateful)),
            if (stateless != null) Expanded(child: _color(Colors.green.shade100, stateless)),
          ]),
        ),
        Center(
          child: FlatButton(
            color: Colors.white,
            onPressed: () => setState(() {}),
            child: Text("Rebuild"),
          ),
        ),
        Row(
          children: [
            if (classic != null) _header("CLASSIC"),
            if (stateful != null) _header("STATE-FULL"),
            if (stateless != null) _header("STATE-LESS"),
          ],
        )
      ],
    );
  }
}
