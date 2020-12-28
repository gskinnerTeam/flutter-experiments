import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/props/animation_prop.dart';
import 'package:flutter_experiments/stateful_props/props/gesture_prop.dart';
import 'package:flutter_experiments/stateful_props/props/layout_prop.dart';
import 'package:flutter_experiments/stateful_props/stateful_props_widget.dart';

import '../stateful_prop_demo.dart';
import '../stateful_props_mixin.dart';

/// ///////////////////////////////////////////////////
/// Basic Animator Example
/// //////////////////////////////////////////////////
/// Creates an Animator, and a Tween and restarts the Animator when tapped.
/// Uses helper method AnimationControllerProp.isComplete to update the view.

class BasicAnimatorExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      stateless: BasicAnimatorStateless(),
      stateful: BasicAnimatorStateful(),
      classic: BasicAnimatorClassic(),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
class BasicAnimatorClassic extends StatefulWidget {
  @override
  _BasicAnimatorClassicState createState() => _BasicAnimatorClassicState();
}

class _BasicAnimatorClassicState extends State<BasicAnimatorClassic> with SingleTickerProviderStateMixin {
  AnimationController anim;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(vsync: this, duration: Duration(seconds: 1));
    //anim.forward();
    //anim.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = anim.status == AnimationStatus.completed || anim.status == AnimationStatus.dismissed;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => anim.forward(from: 0),
      child: _AnimatedContent(controller: anim, isComplete: isComplete),
    );
  }
}

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////
class BasicAnimatorStateful extends StatefulWidget {
  @override
  _BasicAnimatorStatefulState createState() => _BasicAnimatorStatefulState();
}

class _BasicAnimatorStatefulState extends State<BasicAnimatorStateful> with StatefulPropsMixin {
  AnimationProp anim;
  LayoutProp layout;

  @override
  void initProps() {
    anim = addProp(AnimationProp(1, autoStart: false));
    addProp(TapProp(() => anim.controller.forward(from: 0)));
    layout = addProp(LayoutProp());
  }

  @override
  Widget buildWithProps(BuildContext context) {
    print(layout.constraints.maxWidth);
    return _AnimatedContent(prop: anim);
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class BasicAnimatorStateless extends PropsWidget {
  static Ref<AnimationProp> _anim = Ref();
  static Ref<TapProp> _tap = Ref();

  @override
  void initProps() {
    addProp(_anim, AnimationProp(1, autoStart: false));
    addProp(_tap, TapProp(() => use(_anim).controller.forward(from: 0.0)));
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return _AnimatedContent(prop: use(_anim));
  }
}

/// ////////////////////////////////////
/// SHARED
class _AnimatedContent extends StatelessWidget {
  const _AnimatedContent({Key key, this.prop, this.isComplete, this.controller}) : super(key: key);
  final AnimationProp prop;
  final AnimationController controller;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    double animValue = controller?.value ?? prop.value;
    return Container(
      padding: EdgeInsets.all(100),
      alignment: Alignment(0, animValue),
      child: Text((isComplete ?? prop.isComplete) ? "Done! Click to animate" : "Wait for it..."),
    );
  }
}
