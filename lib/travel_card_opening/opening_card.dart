import 'dart:ui';

import 'package:flutter/material.dart';

// Tweens from some opening offset + size to fill the entire parent view
// Relies on Tranform.translate() and SizedBox to move and size the Child
class OpeningCard extends StatefulWidget {
  OpeningCard({Key key, @required this.onEnd, this.child, this.topLeftOffset, this.closedSize}) : super(key: key);
  final VoidCallback onEnd;
  final Widget child;
  final Offset topLeftOffset;
  final Size closedSize;

  @override
  _OpeningCardState createState() => _OpeningCardState();
}

class _OpeningCardState extends State<OpeningCard> with SingleTickerProviderStateMixin {
  AnimationController animController;
  Animation<double> anim;
  @override
  void initState() {
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    animController.addListener(() {
      setState(() {});
      if (animController.status == AnimationStatus.completed && animController.value == animController.upperBound) {
        widget.onEnd?.call();
      }
    });
    animController.forward();
    anim = animController.drive(CurveTween(curve: Curves.easeInQuart));
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  Offset get offset => widget.topLeftOffset;
  Size get closedSize => widget.closedSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      Size viewSize = constraints.biggest;
      // If we don't have an offset, there's nothing we can animate from so skip it completely
      // Typically this will just happen once, on first load, before anything has been pressed
      bool skipAnims = offset == null;
      double animValue = skipAnims ? 1 : anim.value;
      Rect rect = Rect.zero;
      // Figure out what our closed rect would be based on viewWidth, offset and cardSize
      if (!skipAnims) {
        rect = Rect.fromLTRB(
          offset.dx, //Left
          offset.dy, //Top
          viewSize.width - (offset.dx + closedSize.width), // Right
          viewSize.height - (offset.dy + closedSize.height), // Bottom
        );
      }
      // Translate the box up and to the left, while expanding it's width and height.
      // This is easier to do with Container.margin, but Container throws errors when it has negative margins.
      return Transform.translate(
        offset: Offset(rect.left * (1 - animValue), rect.top * (1 - animValue)),
        child: SizedBox(
          width: lerpDouble(closedSize.width, viewSize.width, animValue),
          height: lerpDouble(closedSize.height, viewSize.height, animValue),
          child: widget.child,
        ),
      );

//      return Container(
//        padding: EdgeInsets.fromLTRB(rect.left, rect.top, rect.right, rect.bottom) * (1 - anim.value),
//        child: widget.child,
//      );
    });
  }
}
