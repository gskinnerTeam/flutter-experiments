// Main app model, holds the currentExperiment and some builders for them.
import 'package:flutter/material.dart';

import 'context_menu/context_menu_experiment.dart';
import 'keyboard_listener/keyboard_listener_app.dart';
import 'nav_examples/imperative_nav_tests.dart';
import 'optimized_drag_stack/optimized_drag_stack.dart';
import 'travel_card_opening/travel_cards_demo_main.dart';

class AppModel extends ChangeNotifier {
  static String kVersion = "0.1.1";
  String _currentPage;

  String get currentPage => _currentPage;
  set currentPage(String currentExperiment) {
    _currentPage = currentExperiment;
    notifyListeners();
  }

  // A map of experiment-builders  by name. Used to build the main menu, and render each content area.
  // This is a quick way to map a bunch of "route names" to some specific content pages.
  Map<String, Widget Function()> pagesByName = {
    "OptimizedDragAndDrop": () => OptimizedDragStack(),
    "ContextMenu": () => ContextMenuTestApp(),
    "NavTests": () => ImperativeNavTests(),
    "keyboardListeners": () => KeyboardListenerApp(),
    "OpeningCards": () => TravelCardsDemo(),
  };
  List<String> get pageNames => pagesByName.keys.toList();
  bool isValidExperimentName(String value) => pagesByName.keys.contains(value);

  // Builds an experiment according to currentExperiment value
  Widget Function() get currentPageBuilder {
    if (pagesByName.containsKey(currentPage) == false) return null;
    return pagesByName[currentPage];
  }
}
