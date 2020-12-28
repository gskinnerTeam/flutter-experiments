import 'dart:ui';

import 'package:flutter/material.dart';

// Tweens from some opening offset + size to fill the entire parent view
// Relies on Tranform.translate() and SizedBox to move and size the Child
class OpeningContainer extends StatefulWidget {
  OpeningContainer({
    Key key,
    @required this.onEnd,
    @required this.child,
    @required this.topLeftOffset,
    @required this.closedSize,
    @required this.duration,
    this.curve = Curves.easeOut,
  }) : super(key: key);

  final VoidCallback onEnd;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset topLeftOffset;
  final Size closedSize;

  @override
  _OpeningContainerState createState() => _OpeningContainerState();
}

//TODO: Fix this for RTL not quite working right
class _OpeningContainerState extends State<OpeningContainer> with SingleTickerProviderStateMixin {
  Offset get offset => widget.topLeftOffset;
  Size get closedSize => widget.closedSize;

  @override
  Widget build(BuildContext context) {
    bool skipAnims = offset == null;
    return TweenAnimationBuilder<double>(
      onEnd: widget.onEnd,
      duration: skipAnims ? Duration.zero : widget.duration,
      curve: widget.curve,
      tween: Tween(begin: 0, end: 1),
      builder: (_, value, __) {
        return LayoutBuilder(builder: (_, constraints) {
          Size viewSize = constraints.biggest;
          // If we don't have an offset, there's nothing we can animate from so skip it completely
          // Typically this will just happen once, on first load, before anything has been pressed
          double animValue = skipAnims ? 1 : value;
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
          return Transform.translate(
            offset: Offset(rect.left * (1 - animValue), rect.top * (1 - animValue)),
            child: SizedBox(
              width: lerpDouble(closedSize.width, viewSize.width, animValue),
              height: lerpDouble(closedSize.height, viewSize.height, animValue),
              child: widget.child,
            ),
          );
        });
      },
    );
  }
}
