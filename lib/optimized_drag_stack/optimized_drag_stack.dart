import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

// Create a list of random boxes
double rnd([double value = 1]) => Random().nextDouble() * value;
List<BoxTransformData> _boxes;
void generateBoxes(int amt) {
  _boxes = List.generate(
    amt,
    (index) => BoxTransformData(offset: Offset(100 + rnd(600), 100 + rnd(600)), scale: .5 + rnd()),
  );
}

// Create a Stack that will render each Box
class OptimizedDragStack extends StatefulWidget {
  const OptimizedDragStack({Key key}) : super(key: key);
  @override
  _OptimizedDragStackState createState() => _OptimizedDragStackState();
}

class _OptimizedDragStackState extends State<OptimizedDragStack> {
  bool _useImages = false;
  bool _optimizeBuilds = true;
  int _boxCount = 100;

  @override
  void initState() {
    super.initState();
    generateBoxes(_boxCount.round());
  }

  // When a box ask to go on top, just re-order the list and rebuild.
  // This will cause the entire stack to rebuild once, which is pretty expensive, buw ok since it only happens once per drag.
  void _handleMoveStart(BoxTransformData bt) {
    _boxes.remove(bt);
    _boxes.add(bt);
    setState(() {});
  }

  void _handleMoveUpdated(BoxTransformData data, Offset delta) {
    // Update position of box
    data.offset += delta;
    // Now there's 2 ways we can rebuild the view...
    if (_optimizeBuilds) {
      // FAST: Trigger a notifyListeners() calls on the data object itself.
      // Only the box tied to this data will call setState
      data.notifyListeners();
    } else {
      // SLOW: Rebuild the parent stack. This works too, but EVERY child rebuilds.
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          // Create a bunch of Box Widgets from our BoxTransforms
          children: [
            ..._boxes.map(
              (BoxTransformData boxData) {
                return MyMovableBox(
                    // Give each box a key, so it won't lose it's state when _boxes is re-ordered
                    key: ValueKey(boxData),
                    data: boxData,
                    onMoveStarted: _handleMoveStart,
                    onMoveUpdated: _handleMoveUpdated,
                    child: _SquareImage(scale: boxData.scale, showImage: _useImages));
              },
            ).toList(),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  color: Colors.grey.shade200,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text("Use Images: "),
                          Checkbox(
                            tristate: false,
                            value: _useImages,
                            onChanged: (value) => setState(() => _useImages = value),
                          ),
                          SizedBox(width: 50),
                          Text("Optimize  child builds: "),
                          Checkbox(
                            tristate: false,
                            value: _optimizeBuilds,
                            onChanged: (value) => setState(() => _optimizeBuilds = value),
                          ),
                        ],
                      ),
                      SfSlider(
                        min: 100.0,
                        max: 2500.0,
                        value: _boxCount.toDouble(),
                        stepSize: 50,
                        interval: 100,
                        showTicks: true,
                        showLabels: true,
                        showTooltip: true,
                        minorTicksPerInterval: 1,
                        onChanged: (dynamic value) => setState(() {
                          _boxCount = (value as double).toInt();
                          generateBoxes(_boxCount);
                        }),
                      ),
                    ],
                  )),
            ),
          ]),
    );
  }
}

class _SquareImage extends StatelessWidget {
  const _SquareImage({Key key, this.scale = 1, this.showImage}) : super(key: key);
  final double scale;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100 * scale,
        height: 100 * scale,
        child: Container(
          padding: EdgeInsets.all(20),
          color: RandomColor().randomColor(),
          child: showImage
              ? Image.network(
                  "https://images.unsplash.com/photo-1557800636-894a64c1696f?ixlib=rb-1.2.1&auto=format&fit=crop&w=701&q=80",
                  fit: BoxFit.cover,
                )
              : Container(),
        ));
  }
}

class BoxTransformData extends ChangeNotifier {
  Offset offset = Offset.zero;
  double scale = 1;
  BoxTransformData({this.offset, this.scale = 0.0});

  @override
  void notifyListeners() => super.notifyListeners();
}

class MyMovableBox extends StatelessWidget {
  const MyMovableBox(
      {Key key, @required this.child, @required this.data, this.onMoveStarted, this.onMoveUpdated, this.onScaleUpdated})
      : super(key: key);
  final BoxTransformData data;
  final void Function(BoxTransformData) onMoveStarted;
  final void Function(BoxTransformData, Offset) onMoveUpdated;
  final void Function(BoxTransformData, double) onScaleUpdated;
  final Widget child;

  // Move dispatchers
  void _handlePanStart(DragStartDetails details) => onMoveStarted?.call(data);
  void _handlePanUpdate(DragUpdateDetails details) => onMoveUpdated?.call(data, details.delta);

  // Mouse-wheel
  void _handlePointerSignal(PointerSignalEvent signal) {
    if (signal is PointerScrollEvent) {
      double delta = -signal.scrollDelta.dy * .001;
      onScaleUpdated?.call(data, delta);
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Listener(
      //Listen for mouse-wheel scroll
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        // Listen for drag and pinch events
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        // Rebuild the box anytime it's data changes
        child: AnimatedBuilder(
          animation: data,
          builder: (BuildContext context, Widget _) {
            // Position the child, using a margin to offset it
            // TODO: Switch to Transform.translate
            return Container(
                padding: EdgeInsets.only(
                  left: max(0, data.offset.dx),
                  top: max(0, data.offset.dy),
                ),
                child: child);
          },
        ),
      ),
    );
  }
}
