import 'dart:ui';
import 'package:flutter/material.dart';
import '_shared.dart';
import 'card_data.dart';
import 'opening_card.dart';
import 'travel_card.dart';

Duration fastDuration = Duration(milliseconds: 700);

class TravelCardsDemo extends StatefulWidget {
  @override
  _TravelCardsDemoState createState() => _TravelCardsDemoState();
}

class _TravelCardsDemoState extends State<TravelCardsDemo> {
  bool _useRtl = false;
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _useRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Main Content
            Positioned.fill(
              top: 30,
              child: TravelCardStack(),
            ),

            /// Checkbox to toggle RTL layout
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  Checkbox(value: _useRtl, onChanged: (value) => setState(() => _useRtl = value)),
                  Text("RTL Mode"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TravelCardStack extends StatefulWidget {
  @override
  _TravelCardStackState createState() => _TravelCardStackState();
}

class _TravelCardStackState extends State<TravelCardStack> {
  CardData _bgData;
  CardData _currentCard;
  Offset _currentCardPos;
  bool _isOpening = false;

  // Can use a scroll controller to animate list items as they come on stage.
  // Cool trick from @marcin_szalek check out this talk for more: https://youtu.be/PVDB8u_RFvA?t=2334
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _currentCard = _bgData = cards[0];
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  // When card is clicked, change selectedData and set isOpening flag
  void _handleItemClicked(Offset globalPos, CardData data) {
    if (_currentCard == data) return;
    if (_isOpening) return;
    // Convert the globalPos we get from the clickedItem, into a localState for this Widget
    Offset localPos = ContextUtils.globalToLocal(context, globalPos);
    print(localPos);

    setState(() {
      _currentCardPos = localPos;
      _currentCard = data;
      _isOpening = true;
    });
  }

  // When card finishes opening, swap a new bgLayer into place, and set isOpening flag
  void _handleCardOpened() {
    setState(() {
      _isOpening = false;
      _bgData = _currentCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        Size boxSize = Size(260, 350);
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          child: Stack(
            children: [
              /// ///////////////////////////////////////////////////
              /// BackgroundCard, this gets updated then the OpeningCard finishes opening
              if (_bgData != null) ...{
                TravelCard(_bgData, largeMode: true),
              },

              // Until we have a position, we'll hide the OpeningContainer and FadeUnderlay
              if (_currentCardPos != null) ...{
                /// A black underlay that sits between the background and transition, fading in each time we change _selectedData
                Positioned.fill(
                  key: ObjectKey(_currentCard),
                  child: AutoFade(
                    duration: fastDuration,
                    child: Container(color: Colors.black.withOpacity(.9)),
                  ),
                ),

                /// ///////////////////////////////////////////////////
                /// OpeningCard, Each time the key is changed, open from the topLeftOffset and fills the Stack

                OpeningContainer(
                  key: ValueKey(_currentCard),
                  topLeftOffset: _currentCardPos,
                  closedSize: boxSize,
                  duration: fastDuration,
                  child: TravelCard(_currentCard, largeMode: true),
                  onEnd: _handleCardOpened,
                ),
              },

              /// ///////////////////////////////////////////////////
              /// List of TravelCards that report their globalOffset when clicked
              Container(
                // List defines the width of the items
                width: boxSize.width + 12,
                padding: EdgeInsets.symmetric(horizontal: 12),
                // Just a basic listView
                child: ListView(
                  controller: _scrollController,
                  cacheExtent: 1000,
                  children: [
                    SizedBox(height: 24), //Padding at the top of the list
                    ...cards.map((CardData data) {
                      bool isSelected = _currentCard == data;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Container(
                          height: boxSize.height, // Define height for the card, works in tandem with the list-width
                          // Travel Card
                          child: TravelCard(
                            data,
                            isSelected: isSelected,
                            scrollController: _scrollController,
                            //Pass null if we're currently selected to disable the btn
                            onPressed: isSelected ? null : (Offset pos) => _handleItemClicked(pos, data),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
