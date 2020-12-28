import 'package:flutter/widgets.dart';
import 'package:flutter_experiments/stateful_props/stateful_properties.dart';

class PageControllerProp extends StatefulProp<PageControllerProp> {
  PageControllerProp({this.initialPage: 0, this.keepPage: true, this.viewportFraction: 1.0, this.onChanged});
  final int initialPage;
  bool keepPage;
  double viewportFraction;

  // Callbacks
  void Function(PageControllerProp prop) onChanged;

  // Helper Methods
  ScrollPosition get position => _controller.position;
  PageController get controller => _controller;

  // Internal state
  PageController _controller;

  @override
  void init() {
    _controller = PageController(
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );
    _controller.addListener(_handlePageChanged);
  }

  @override
  void update(PageControllerProp newProp) {
    onChanged = newProp.onChanged ?? onChanged;
  }

  @override
  void dispose() => _controller.dispose();

  void _handlePageChanged() => onChanged?.call(this);
}
