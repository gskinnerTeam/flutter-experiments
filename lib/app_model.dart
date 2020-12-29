// Main app model, holds the currentExperiment and some builders for them.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_experiments/custom_widget/custom_widget.dart';
import 'package:flutter_experiments/flutter_hooks/flutter_hooks_demo.dart';
import 'package:flutter_experiments/restoration_demo/restoration_demo.dart';
import 'package:flutter_experiments/tooltips/tooltips_demo.dart';

import 'context_menu/context_menu_experiment.dart';
import 'keyboard_listener/keyboard_listener_app.dart';
import 'nav_examples/imperative_nav_tests.dart';
import 'optimized_drag_stack/optimized_drag_stack.dart';
import 'stateful_props/stateful_prop_demo.dart';
import 'travel_card_opening/travel_cards_demo.dart';

class PageInfo {
  PageInfo({@required this.title, this.sourceUrl});
  String get link => title.toLowerCase().replaceAll(" ", "-");
  final String title;
  final String sourceUrl;
}

class AppModel extends ChangeNotifier {
  static String kBaseSrcUrl = "https://github.com/gskinnerTeam/flutter-experiments/blob/master/lib/";
  static String kVersion = "0.1.2";
  String _currentPage;

  //Debug: Override default page to skip home
  String get currentPage => _currentPage ?? StatefulPropsDemo.info.title;
  set currentPage(String currentExperiment) {
    _currentPage = currentExperiment;
    notifyListeners();
  }

  String get currentSrcUrl {
    if (currentPageInfo?.sourceUrl == null) return null;
    return kBaseSrcUrl + currentPageInfo?.sourceUrl;
  }

  // A map of experiment-builders  by name. Used to build the main menu, and render each content area.
  // This is a quick way to map a bunch of "route names" to some specific content pages.
  Map<String, _Page> pagesByName = {
    "OptimizedDragAndDrop": _Page(() => OptimizedDragStack(), null),
    "ContextMenu": _Page(() => ContextMenuTestApp(), null),
    "NavTests": _Page(() => ImperativeNavTests(), null),
    "keyboardListeners": _Page(() => KeyboardListenerApp(), null),
    "OpeningCards": _Page(() => TravelCardsDemo(), null),
    if (kReleaseMode == false) ...{
      "Tooltip": _Page(() => TooltipsDemo(), null),
      "FlutterHooks": _Page(() => FlutterHooksDemo(), null),
      StatefulPropsDemo.info.title: _Page(() => StatefulPropsDemo(), StatefulPropsDemo.info),
      "StateRestoration": _Page(() => StateRestorationDemo(), null),
      CustomStatelessWidgetDemo.info.title: _Page(() => CustomStatelessWidgetDemo(), CustomStatelessWidgetDemo.info),
    }
  };
  List<String> get pageNames => pagesByName.keys.toList();
  bool isValidExperimentName(String value) => pagesByName.keys.contains(value);

  // Builds an experiment according to currentExperiment value
  Widget Function() get currentPageBuilder {
    if (pagesByName.containsKey(currentPage) == false) return null;
    return pagesByName[currentPage].builder;
  }

  PageInfo get currentPageInfo {
    if (pagesByName.containsKey(currentPage) == false) return null;
    return pagesByName[currentPage].info;
  }
}

class _Page {
  _Page(this.builder, this.info);
  final Widget Function() builder;
  final PageInfo info;
}
