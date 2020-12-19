import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({Key key, this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        child: child,
      );
}

class AnimatedScale extends StatelessWidget {
  const AnimatedScale(
      {Key key, @required this.child, @required this.scale, @required this.duration, this.beginScale, this.curve})
      : super(key: key);
  final Widget child;
  final double scale;
  final Duration duration;
  final double beginScale;
  final Curve curve;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: beginScale ?? .2, end: scale),
        curve: curve ?? Curves.easeOut,
        duration: duration,
        child: child,
        builder: (_, value, cachedChild) {
          return Transform.scale(scale: value, child: cachedChild);
        },
      );
}

class AutoFade extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const AutoFade({
    Key key,
    @required this.child,
    this.delay = Duration.zero,
    this.offset = Offset.zero,
    @required this.duration,
    this.curve = Curves.easeOut,
  }) : super(key: key);
  @override
  _AutoFadeState createState() => _AutoFadeState();
}

class _AutoFadeState extends State<AutoFade> with SingleTickerProviderStateMixin {
  AnimationController animController;
  Animation<double> anim;

  @override
  void initState() {
    //TODO: Need to standardize durations/eases from topDown
    animController = AnimationController(vsync: this, duration: widget.duration);
    animController.addListener(() => setState(() {}));
    anim = animController.drive(CurveTween(curve: widget.curve));
    Future.delayed(widget.delay ?? Duration.zero, animController.forward);
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Offset startPos = widget.offset ?? Offset.zero;
    Animation<Offset> position = Tween<Offset>(begin: startPos, end: Offset.zero).animate(anim);
    return Transform.translate(
      offset: position.value,
      child: Opacity(opacity: anim.value, child: widget.child),
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
