import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'card_data.dart';
import '_shared.dart';

class TravelCard extends StatefulWidget {
  const TravelCard(
    this.data, {
    Key key,
    this.isSelected = false,
    this.onPressed,
    this.scrollController,
    this.largeMode = false,
  }) : super(key: key);
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

  double get textScale => widget.largeMode ? 1.5 : .8;

  TextStyle get titleStyle {
    return TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26 * textScale, height: .95);
  }

  TextStyle get descStyle {
    return TextStyle(color: Colors.white, fontSize: 16 * textScale);
  }

  void _handlePressed() {
    widget.onPressed?.call(ContextUtils.localToGlobal(context));
  }

  @override
  Widget build(BuildContext context) {
    bool isClickable = _isMouseOver && widget.onPressed != null;
    Duration mouseOverDuration = Duration(milliseconds: 700);
    // Cards that are clickable will appear dimmed, until you mouse over, but we don't want to apply this logic to non-clickable cards.
    double overlayOpacity = 0;
    if (widget.onPressed != null) {
      overlayOpacity = _isMouseOver ? 0 : .3;
    }
    TextDirection dir = Directionality.of(context);
    Alignment largeModeAlign = dir == TextDirection.ltr ? Alignment.bottomRight : Alignment.bottomLeft;
    Alignment smallModeAlign = dir == TextDirection.ltr ? Alignment.bottomLeft : Alignment.bottomRight;
    return RoundedCard(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: widget.isSelected ? 0 : 200),
        child: widget.isSelected
            ? Container(color: Colors.white.withOpacity(.2))
            : MouseRegion(
                cursor: isClickable ? SystemMouseCursors.click : MouseCursor.defer,
                onEnter: (_) => isOver = true,
                onHover: (_) => isOver = true,
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
                      scale: isClickable ? 1.1 : 1,
                      // Use animatedBuilder to show another scale effect when the list scrolls
                      child: ScrollableListImage(widget.scrollController, widget.data.url),
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
                    Container(
                      padding: EdgeInsets.all(24),
                      alignment: widget.largeMode ? largeModeAlign : smallModeAlign,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: widget.largeMode ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (widget.largeMode) ...{
                            _LargeViewContent(state: this),
                          } else ...{
                            _SmallViewContent(state: this)
                          }
                        ],
                      ),
                    ),
                    // Show a border on mouseOver
                    if (isClickable)
                      Positioned.fill(
                        child: FadeIn(
                          child: RoundedBorder(),
                        ),
                      ),
                  ]),
                ),
              ),
      ),
    );
  }
}

class ScrollableListCard extends StatelessWidget {
  const ScrollableListCard({Key key, @required this.scrollController, @required this.child}) : super(key: key);
  final Widget child;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext _) {
    if (scrollController == null) return child;
    return LayoutBuilder(
      builder: (_, constraints) => AnimatedBuilder(
        animation: scrollController,
        child: child,
        builder: (context, cachedChild) {
          Size size = ContextUtils.getSize(context);
          Offset pos = ContextUtils.localToGlobal(context);
          Size viewSize = MediaQuery.of(context).size;
          double amtOnScreen = max(0, viewSize.height - pos.dy) / (size.height * .35);
          return Transform.scale(scale: min(1, .7 + amtOnScreen * .3), child: cachedChild);
        },
      ),
    );
  }
}

class _SmallViewContent extends StatelessWidget {
  const _SmallViewContent({Key key, this.state}) : super(key: key);
  final _TravelCardState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //White Line
        Container(width: 30, height: 3, color: Colors.white),
        SizedBox(height: 8),
        // Desc
        Text(state.widget.data.desc.toUpperCase(), style: state.descStyle, maxLines: 1),
        SizedBox(height: 8),
        // Title
        Text(state.widget.data.title.toUpperCase(), style: state.titleStyle),
      ],
    );
  }
}

class _LargeViewContent extends StatelessWidget {
  const _LargeViewContent({Key key, this.state}) : super(key: key);
  final _TravelCardState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        //White Line
        FadeInUp(
          delay: Duration(milliseconds: 100),
          child: Container(width: 30, height: 3, color: Colors.white),
        ),
        SizedBox(height: 8),
        // Desc
        FadeInUp(
          delay: Duration(milliseconds: 200),
          child: Text(state.widget.data.desc.toUpperCase(), style: state.descStyle, maxLines: 1),
        ),
        SizedBox(height: 8),
        // Title
        FadeInUp(
            delay: Duration(milliseconds: 300),
            child: Text(state.widget.data.title.toUpperCase(), style: state.titleStyle)),
      ],
    );
  }
}

// Listens to a scrollController, and scales up based on it's Y position on the screen.
// Todo: Maybe this should take an Axis?
class ScrollableListImage extends StatefulWidget {
  const ScrollableListImage(this.scrollController, this.url, {Key key, this.scaleAmt}) : super(key: key);
  final String url;
  final ScrollController scrollController;
  final double scaleAmt;

  @override
  _ScrollableListImageState createState() => _ScrollableListImageState();
}

class _ScrollableListImageState extends State<ScrollableListImage> {
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
