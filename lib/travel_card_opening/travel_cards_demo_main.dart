import 'dart:ui';
import 'package:flutter/material.dart';
import 'travel_card_stack.dart';

class TravelCardsDemo extends StatefulWidget {
  @override
  _TravelCardsDemoState createState() => _TravelCardsDemoState();
}

class _TravelCardsDemoState extends State<TravelCardsDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          TravelCardStack(),
        ],
      ),
    );
  }
}

class ContextUtils {
  // Utility methods to get the size/pos of our render boxes in global & local space
  static Size getSize(BuildContext c) {
    return (c.findRenderObject() as RenderBox)?.size ?? Size.zero;
  }

  static Offset localToGlobal(BuildContext c, {Offset local = Offset.zero}) {
    return (c.findRenderObject() as RenderBox)?.localToGlobal(local) ?? Offset.zero;
  }

  static Offset globalToLocal(BuildContext c, Offset global) {
    return (c.findRenderObject() as RenderBox)?.globalToLocal(global) ?? Offset.zero;
  }
}
