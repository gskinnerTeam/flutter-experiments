import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class CardData {
  CardData({this.title, this.desc, this.url});
  final String title;
  final String desc;
  final String url;
}

List<CardData> cards = [
  CardData(
      title: "Card1", desc: "Desc1", url: "https://images.unsplash.com/photo-1494548162494-384bba4ab999?w=800&q=80"),
  CardData(
      title: "Card2", desc: "Desc2", url: "https://images.unsplash.com/photo-1567878130373-9c952877ed1d?w=800&q=80"),
  CardData(
      title: "Card3", desc: "Desc3", url: "https://images.unsplash.com/photo-1574579991264-a87099cc17b1?w=800&q=80"),
  CardData(
      title: "Card4", desc: "Desc4", url: "https://images.unsplash.com/photo-1494548162494-384bba4ab999?w=800&q=80"),
  CardData(
      title: "Card5", desc: "Desc5", url: "https://images.unsplash.com/photo-1567878130373-9c952877ed1d?w=800&q=80"),
  CardData(
      title: "Card6", desc: "Desc6", url: "https://images.unsplash.com/photo-1574579991264-a87099cc17b1?w=800&q=80"),
  CardData(
      title: "Card7", desc: "Desc7", url: "https://images.unsplash.com/photo-1494548162494-384bba4ab999?w=800&q=80"),
  CardData(
      title: "Card8", desc: "Desc8", url: "https://images.unsplash.com/photo-1567878130373-9c952877ed1d?w=800&q=80"),
  CardData(
      title: "Card9", desc: "Desc9", url: "https://images.unsplash.com/photo-1574579991264-a87099cc17b1?w=800&q=80"),
];

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
        fit: StackFit.expand,
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
    return LayoutBuilder(
      builder: (_, constraints) {
        double padding = 10;
        Size boxSize = Size(260, 350);
        double paddedBoxWidth = boxSize.width + padding;
        Size viewSize = constraints.biggest;
        Offset listOffset = Offset(viewSize.width - boxSize.width * 4, viewSize.height - boxSize.height - 40);
        int bgIndex = _selectedIndex;
        if (_goingForward) {
          bgIndex = _selectedIndex == 0 ? cards.length - 1 : _selectedIndex - 1;
        }
        return Stack(
          children: [
            // Background Element 1 (Static, switches when index is changed, swapping with element 2)
            TravelCard(cards[bgIndex], isVisible: true),

            // Background Element 2 (Transitions from the card pos, to fullscreen)
            TransitionCard(
              listOrigin: listOffset.translate(paddedBoxWidth, 0),
              cardSize: boxSize,
              viewSize: viewSize,
              goingForward: _goingForward,
              card: cards[selectedIndex + (_goingForward ? 0 : 1)],
            ),

            // Row of Cards
            ...cards.map((CardData data) {
              int i = cards.indexOf(data);
              double initialPos = listOffset.dx + i * paddedBoxWidth;
              double currentListPos = _selectedIndex * paddedBoxWidth;
              Offset cardOffset = Offset(initialPos - currentListPos, listOffset.dy);
              // Use animated offset to move the cards horizontally with some custom ease and delay for each item
              return AnimatedOffset(
                offset: cardOffset,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutSine,
                delay: Duration(milliseconds: max(0, i - _selectedIndex) * 150),
                child: SizedBox.fromSize(
                  size: boxSize,
                  child: TravelCard(data, isVisible: i > _selectedIndex, index: i),
                ),
              );
            }),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FlatButton(color: Colors.white, onPressed: prev, child: Text("<<")),
              FlatButton(color: Colors.white, onPressed: next, child: Text(">>")),
            ]),
          ],
        );
      },
    );
  }
}

//TODO: Reduce this boilerplate...maybe it just has a reference to the State and CardData?
class TransitionCard extends StatefulWidget {
  TransitionCard({
    Key key,
    @required this.card,
    @required this.viewSize,
    @required this.cardSize,
    @required this.listOrigin,
    this.goingForward = true,
  }) : super(key: key);
  final CardData card;
  final Size viewSize;
  final Size cardSize;
  final Offset listOrigin;
  final bool goingForward;

  @override
  _TransitionCardState createState() => _TransitionCardState();
}

class _TransitionCardState extends State<TransitionCard> with SingleTickerProviderStateMixin {
  AnimationController animation;

  Offset get origin => widget.listOrigin;
  Size get viewSize => widget.viewSize;
  Size get cardSize => widget.cardSize;

  @override
  void initState() {
    animation = AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    animation?.dispose();
  }

  @override
  void didUpdateWidget(covariant TransitionCard oldWidget) {
    //TODO: Add support for goingBack
    if (oldWidget.card != widget.card || widget.goingForward != oldWidget.goingForward) {
      if (widget.goingForward) {
        animation.reverse(from: 1);
      } else {
        animation.forward(from: 0);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    double scale = animation.value;
    double distanceFromRight = (viewSize.width - (origin.dx + cardSize.width));
    double distanceFromBottom = (viewSize.height - (origin.dy + cardSize.height));
    EdgeInsets marginInsets = EdgeInsets.only(
        left: origin.dx * scale,
        right: distanceFromRight * scale,
        top: origin.dy * scale,
        bottom: distanceFromBottom * scale);
    return Container(
      margin: marginInsets,
      child: TravelCard(widget.card, isVisible: true),
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

class TravelCard extends StatelessWidget {
  final CardData data;
  final int index;
  final bool isVisible;

  const TravelCard(this.data, {Key key, this.isVisible, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 0),
      opacity: isVisible ? 1 : 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          child: Stack(fit: StackFit.expand, children: [
            Image.network(data.url, fit: BoxFit.cover),
            Center(
              child: Text(
                data.title,
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 26),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
