import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_experiments/stateful_props/props/animation_prop.dart';
import 'package:flutter_experiments/stateful_props/props/scroll_prop.dart';
import 'package:flutter_experiments/stateful_props/props/text_edit_prop.dart';
import 'package:flutter_experiments/stateful_props/stateful_props_widget.dart';

import '../stateful_prop_demo.dart';
import '../stateful_props_mixin.dart';

/// ///////////////////////////////////////////////////
/// Basic Focus Example
/// //////////////////////////////////////////////////
/// Creates 2 focus nodes and counts the focus-outs and focus-ins

class ScrollToTopExample extends PropsWidget {
  @override
  Widget buildWithProps(BuildContext context) {
    return ComparisonStack(
      stateless: ScrollOnStartStateless(),
      stateful: ScrollOnStartStateful(),
      //classic: ScrollOnStartClassic(),
    );
  }
}

/// ///////////////////////////////////
/// Classic
/// //////////////////////////////////
//TODO ADD EXAMPLE

/// ///////////////////////////////////
/// State-ful Props
/// //////////////////////////////////

/// ////////////////////////////////////////////
/// Fade in and scroll-up when a view is firstMounted
class ScrollOnStartStateful extends StatefulWidget {
  @override
  _ScrollOnStartStatefulState createState() => _ScrollOnStartStatefulState();
}

class _ScrollOnStartStatefulState extends State<ScrollOnStartStateful> with StatefulPropsMixin {
  TextEditProp textProp;
  ScrollProp scrollProp;
  AnimationProp anim;

  @override
  void initProps() {
    textProp = addProp(TextEditProp(text: "Stateful Props are Cool!", onChanged: (v) => print(v)));
    scrollProp = addProp(ScrollProp(initialScrollOffset: 200));
    anim = addProp(AnimationProp(1));
    // Fade in after a slight delay
    Future.delayed(Duration(milliseconds: 200), () => anim.controller.forward());
    // Select all text when the view is first shown
    textProp.controller.selection = TextSelection(baseOffset: 0, extentOffset: textProp.controller.text.length);
    //Scroll up 1 frame after the view is first shown
    scheduleMicrotask(() {
      scrollProp.controller.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
  }

  @override
  Widget buildWithProps(BuildContext context) {
    // View
    return SingleChildScrollView(
      controller: scrollProp.controller,
      child: Opacity(
        opacity: anim.value,
        child: Column(
          children: [
            TextFormField(controller: textProp.controller),
            ...List.generate(
              20,
              (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 400,
                  height: 200,
                  color: Colors.red.shade200,
                  child: AnimatedBuilder(
                    animation: textProp.controller,
                    builder: (_, __) => Text(textProp.text),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ///////////////////////////////////
/// State-less Props
/// //////////////////////////////////
class ScrollOnStartStateless extends PropsWidget {
  static Ref<TextEditProp> _textProp = Ref();
  static Ref<ScrollProp> _scrollProp = Ref();
  static Ref<AnimationProp> _anim = Ref();

  @override
  void initProps() {
    final text = addProp(_textProp, TextEditProp(text: "Stateful Props are Cool!", onChanged: (v) => print(v)));
    addProp(_scrollProp, ScrollProp(initialScrollOffset: 200));
    addProp(_anim, AnimationProp(1));
    // Fade in after a slight delay
    Future.delayed(Duration(milliseconds: 200), () => use(_anim).controller.forward());
    // Select all text when the view is first shown
    text.controller.selection = TextSelection(baseOffset: 0, extentOffset: text.controller.text.length);
    //Scroll up 1 frame after the view is first shown
    scheduleMicrotask(() {
      use(_scrollProp).controller.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeOut);
    });
  }

  @override
  Widget buildWithProps(BuildContext context) {
    // View
    final textProp = use(_textProp);
    final scrollProp = use(_scrollProp);
    return SingleChildScrollView(
      controller: scrollProp.controller,
      child: Opacity(
        opacity: use(_anim).value,
        child: Column(
          children: [
            TextFormField(controller: textProp.controller),
            ...List.generate(
              20,
              (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 400,
                  height: 200,
                  color: Colors.red.shade200,
                  child: AnimatedBuilder(
                    animation: textProp.controller,
                    builder: (_, __) => Text(textProp.text),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
