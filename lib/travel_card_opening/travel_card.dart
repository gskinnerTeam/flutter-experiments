import 'package:flutter/material.dart';

import 'card_data.dart';
import 'travel_cards_demo_main.dart';
import 'shared_widgets.dart';

class TravelCard extends StatefulWidget {
  const TravelCard(this.data, {Key key, this.isSelected = false, this.onPressed, this.scrollController, this.largeMode})
      : super(key: key);
  final CardData data;
  final bool isSelected;
  final largeMode;
  final ScrollController scrollController;
  final void Function(Offset globalPos) onPressed;

  @override
  _TravelCardState createState() => _TravelCardState();
}

class _TravelCardState extends State<TravelCard> {
  bool _isMouseOver = false;
  set isOver(bool value) => setState(() => _isMouseOver = value);

  void _handlePressed() {
    widget.onPressed?.call(ContextUtils.localToGlobal(context));
  }

  @override
  Widget build(BuildContext context) {
    bool enableMouseOverEffect = _isMouseOver && widget.onPressed != null;
    Duration mouseOverDuration = Duration(milliseconds: 700);
    // Cards that are clickable will appear dimmed, until you mouse over, but we don't want to apply this logic to non-clickable cards.
    double overlayOpacity = 0;
    if (widget.onPressed != null) {
      overlayOpacity = _isMouseOver ? 0 : .3;
    }
    return RoundedCard(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: widget.isSelected ? 0 : 500),
        child: widget.isSelected == false
            ? MouseRegion(
                onEnter: (_) => isOver = true,
                onExit: (_) => isOver = false,
                child: GestureDetector(
                  onTap: _handlePressed,
                  child: Stack(fit: StackFit.expand, children: [
                    /// /////////////////////////////
                    /// Background Image
                    AnimatedScale(
                      duration: mouseOverDuration,
                      beginScale: 1,
                      // Animated scale for when we mouse-over
                      scale: enableMouseOverEffect ? 1.1 : 1,
                      // Use animatedBuilder to show another scale effect when the list scrolls
                      child: ScrollingListImage(widget.scrollController, widget.data.url),
                    ),

                    /// /////////////////////////////
                    /// Overlay Fill
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: mouseOverDuration,
                        color: Colors.black.withOpacity(overlayOpacity),
                      ),
                    ),

                    /// /////////////////////////////
                    /// Text Content
                    AutoFade(
                      delay: Duration(milliseconds: 500),
                      child: Container(
                        padding: EdgeInsets.all(24),
                        alignment: widget.largeMode ?? false ? Alignment.bottomRight : Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 30, height: 3, color: Colors.white),
                            SizedBox(height: 8),
                            Text(widget.data.desc.toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 16), maxLines: 1),
                            SizedBox(height: 8),
                            Text(
                              widget.data.title.toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, height: .95),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              )
            : Container(color: Colors.white.withOpacity(.2)),
      ),
    );
  }
}

// Listens to a scrollController, and scales up based on it's Y position on the screen.
// Todo: Maybe this should take an Axis?
class ScrollingListImage extends StatefulWidget {
  const ScrollingListImage(this.scrollController, this.url, {Key key, this.scaleAmt}) : super(key: key);
  final String url;
  final ScrollController scrollController;
  final double scaleAmt;

  @override
  _ScrollingListImageState createState() => _ScrollingListImageState();
}

class _ScrollingListImageState extends State<ScrollingListImage> {
  Offset _globalPos = Offset.zero;
  @override
  Widget build(BuildContext context) {
    Image img = Image.network(widget.url, fit: BoxFit.cover);
    // Return the basic image if we don't have a scrollController
    if (widget.scrollController == null) {
      return img;
    }
    // If we have a scrollController, listen to it and scale the child
    return AnimatedBuilder(
        animation: widget.scrollController,
        builder: (_, child) {
          double normalizedPos = _calculateNormalizedPos();
          return Transform.scale(
            scale: 1 + (widget.scaleAmt ?? .25) * normalizedPos,
            child: child,
          );
        },
        child: img);
  }

  double _calculateNormalizedPos() {
    //This throws a bunch of errors when we click an item in the list but otherwise works perfectly.
    //TODO: Investigate this further, might be a bug with AnimatedBuilder being remove from the stack? What if we don't remove it??
    try {
      _globalPos = ContextUtils.localToGlobal(context);
    } catch (e) {}
    return (_globalPos.dy / MediaQuery.of(context).size.height).clamp(0.0, 1.0);
  }
}