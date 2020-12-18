import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class OpeningTravelCardsApp extends StatefulWidget {
  @override
  _OpeningTravelCardsAppState createState() => _OpeningTravelCardsAppState();
}

class _OpeningTravelCardsAppState extends State<OpeningTravelCardsApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          AnimatedCardStack(),
        ],
      ),
    );
  }
}

// A stack with children, and a prev/next api. When it moves, it does a delayed tween on all children.
// When item is below index it instantly stops being rendered.
// At the same time, the background card transitions in from underneath
class AnimatedCardStack extends StatefulWidget {
  @override
  _AnimatedCardStackState createState() => _AnimatedCardStackState();
}

class _AnimatedCardStackState extends State<AnimatedCardStack> {
  List<int> cards = List.generate(20, (i) => i);

  bool _goingForward = true;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  set selectedIndex(value) => setState(() => _selectedIndex = value);

  void next() {
    _goingForward = true;
    if (selectedIndex < cards.length - 1) selectedIndex++;
  }

  void prev() {
    _goingForward = false;
    if (selectedIndex > 0) selectedIndex--;
  }

  @override
  Widget build(BuildContext context) {
    double padding = 10;
    return Stack(
      children: [
        Row(children: [
          FlatButton(onPressed: prev, child: Text("<<")),
          FlatButton(onPressed: next, child: Text(">>")),
        ]),
        ...cards.map((int i) {
          return AnimatedOffset(
            offset: Offset(300 + (i.toDouble() * (260 + padding)) - (_selectedIndex * (260 + padding)), 300),
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutQuint,
            delay: Duration(milliseconds: max(0, i - _selectedIndex) * 100),
            child: TravelCardSmall(isVisible: i > _selectedIndex, index: i),
          );
        })
      ],
    );
  }
}

class AnimatedOffset extends StatefulWidget {
  final Duration delay;
  final Offset offset;
  final Duration duration;
  final Widget child;
  final Curve curve;
  const AnimatedOffset(
      {Key key, @required this.delay, @required this.offset, @required this.duration, this.child, this.curve})
      : super(key: key);

  @override
  _AnimatedOffsetState createState() => _AnimatedOffsetState();
}

class _AnimatedOffsetState extends State<AnimatedOffset> {
  Offset _currentOffset;
  Offset _targetOffset;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _currentOffset = widget.offset;
    _targetOffset = widget.offset;
  }

  @override
  void didUpdateWidget(AnimatedOffset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget?.offset != widget.offset) {
      timer?.cancel();
      timer = Timer(widget.delay, () => setState(() => _targetOffset = widget.offset));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      duration: widget.duration,
      curve: widget.curve ?? Curves.easeOut,
      tween: Tween(begin: _currentOffset, end: _targetOffset),
      builder: (_, value, __) {
        _currentOffset = value;
        return Transform.translate(offset: value, child: widget.child);
      },
    );
  }
}

class TravelCardSmall extends StatelessWidget {
  final int index;
  final bool isVisible;

  const TravelCardSmall({Key key, this.isVisible, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 0),
      opacity: isVisible ? 1 : 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          child: Container(
            width: 260,
            height: 400,
            color: Colors.blue.shade200,
            child: Image.network(
              index % 2 == 0
                  ? "https://images.unsplash.com/photo-1567878130373-9c952877ed1d?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2000&q=80"
                  : "https://images.unsplash.com/photo-1574579991264-a87099cc17b1?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2000&q=80",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
