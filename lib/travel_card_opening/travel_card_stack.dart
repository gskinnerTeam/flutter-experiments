// A stack with children, and a prev/next api. When it moves, it does a delayed tween on all children.
// When item is below index it instantly stops being rendered.
// At the same time, the background card transitions in from underneath
import 'package:flutter/material.dart';
import 'package:flutter_experiments/travel_card_opening/shared_widgets.dart';

import 'card_data.dart';
import 'opening_card.dart';
import 'travel_cards_demo_main.dart';
import 'travel_card.dart';

class TravelCardStack extends StatefulWidget {
  @override
  _TravelCardStackState createState() => _TravelCardStackState();
}

class _TravelCardStackState extends State<TravelCardStack> {
  CardData _bgData;
  CardData _selectedData;
  Offset _selectedOffset;
  bool _isOpening = false;

  // Can use a scroll controller to animate list items as they come on stage.
  // Cool trick from @marcin_szalek check out this talk for more: https://youtu.be/PVDB8u_RFvA?t=2334
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _selectedData = _bgData = cards[0];
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  // When card is clicked, change selectedData and set isOpening flag
  void _handleItemClicked(Offset globalPos, CardData data) {
    if (_selectedData == data) return;
    if (_isOpening) return;
    // Convert the globalPos we get from the clickedItem, into a localState for this Widget
    Offset localPos = ContextUtils.globalToLocal(context, globalPos);
    print(localPos);

    setState(() {
      _selectedOffset = localPos;
      _selectedData = data;
      _isOpening = true;
    });
  }

  // When card finishes opening, swap a new bgLayer into place, and set isOpening flag
  void _handleCardOpened() {
    setState(() {
      _isOpening = false;
      _bgData = _selectedData;
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

              Positioned.fill(
                key: ObjectKey(_selectedData),
                child: AutoFade(child: Container(color: Colors.black.withOpacity(.9))),
              ),

              /// ///////////////////////////////////////////////////
              /// OpeningCard, Each time the key is changed, open from the topLeftOffset and fills the Stack
              OpeningCard(
                key: ValueKey(_selectedData),
                topLeftOffset: _selectedOffset,
                closedSize: boxSize,
                child: TravelCard(_selectedData, largeMode: true),
                onEnd: _handleCardOpened,
              ),

              /// ///////////////////////////////////////////////////
              /// List of TravelCards that report their globalOffset when clicked
              Container(
                // List defines the width of the items
                width: boxSize.width + 12,
                padding: EdgeInsets.only(left: 12),
                // Just a basic listView
                child: ListView(
                  controller: _scrollController,
                  cacheExtent: 1000,
                  children: [
                    SizedBox(height: 24), //Padding at the top of the list
                    ...cards.map((CardData data) {
                      bool isSelected = _selectedData == data;
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
