import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it_mixin/get_it_mixin.dart';

import 'custom_hooks.dart';

class Foo extends StatelessWidget with GetItMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class FlutterHooksDemo extends HookWidget {
  @override
  Widget build(BuildContext context) {
// Vars
    final textController = useTextEditingController(text: "Hooks are cool!");
    final scrollController = useScrollController(initialScrollOffset: 200);
    final animController = useAnimController(
      Duration(seconds: 1),
      onStart: (c) => c.forward(),
      delay: Duration(milliseconds: 200),
    );

// Init
    useInit(() {
      // Select all text when the view is first shown
      textController.selection = TextSelection(baseOffset: 0, extentOffset: textController.text.length);
      //Scroll up 1 frame after the view is first shown
      scheduleMicrotask(() {
        scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeOut);
      });
    });

    // View
    return SingleChildScrollView(
      controller: scrollController,
      child: Opacity(
        opacity: animController.value,
        child: Column(
          children: [
            TextFormField(controller: textController),
            ...List.generate(
              20,
              (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 400,
                  height: 200,
                  color: Colors.red.shade200,
                  child: HookBuilder(builder: (_) {
                    useListenable(textController); // Rebuild when the text is changed
                    return Text(textController.text);
                  }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
