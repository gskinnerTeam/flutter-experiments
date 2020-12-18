import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_experiments/context_menu/context_menu_experiment.dart';
import 'package:flutter_experiments/travel_card_opening/opening_cards_app.dart';
import 'package:statsfl/statsfl.dart';
import 'package:flutter_experiments/optimized_drag_stack/optimized_drag_stack.dart';

import 'keyboard_listener/keyboard_listener_app.dart';
import 'nav_examples/imperative_nav_tests.dart';

void main() {
  runApp(StatsFl(child: ExperimentsApp()));
}

// Some shared state for demo
AppModel _appModel = AppModel();
AppRouterDelegate _appRouterDelegate = AppRouterDelegate(_appModel);
AppRouteParser _appRouteParser = AppRouteParser(_appModel);

// Main App
class ExperimentsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouterDelegate,
      routeInformationParser: _appRouteParser,
    );
  }
}

// Main app model, holds the currentExperiment and some builders for them.
class AppModel extends ChangeNotifier {
  String _currentPage;

  String get currentPage => _currentPage;
  set currentPage(String currentExperiment) {
    _currentPage = currentExperiment;
    notifyListeners();
  }

  // A map of experiment-builders  by name. Used to build the main menu, and render each content area.
  Map<String, Widget Function()> pagesByName = {
    "OptimizedDragAndDrop": () => OptimizedDragStack(),
    "ContextMenu": () => ContextMenuTestApp(),
    "NavTests": () => ImperativeNavTests(),
    "keyboardListeners": () => KeyboardListenerApp(),
    "OpeningCards": () => OpeningTravelCardsApp(),
  };
  List<String> get pageNames => pagesByName.keys.toList();

  // Builds an experiment according to currentExperiment value
  Widget buildCurrentPage() {
    if (pagesByName.containsKey(currentPage) == false) return null;
    return pagesByName[currentPage].call();
  }

  bool isValidExperimentName(String value) => pagesByName.keys.contains(value);
}

// Main app scaffold, internally shows / hides views depending on app state
class MainScaffold extends StatelessWidget {
  const MainScaffold({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: _appModel.currentPage == null
            // 'Home' View
            ? _HomeView()
            : _ExperimentView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Flutter Experiments", style: TextStyle(fontSize: 32)),
        // TODO Add hyperlink and context-menu here
        Text("by gskinner.com"),
        SizedBox(height: 20),
        _MainMenu(_appModel),
      ]));
}

class _ExperimentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
        // Side Menu
        Column(
          children: [
            SizedBox(height: 50),
            _MenuBtn(label: "HOME", onPressed: (_) => _appModel.currentPage = null),
            _MainMenu(_appModel)
          ],
        ),
        // Page Area
        Flexible(
            child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          // Build the current experiment according to nav-state
          child: _appModel.buildCurrentPage(),
        ))
      ]);
}

class _MainMenu extends StatelessWidget {
  const _MainMenu(this.appModel, {Key key}) : super(key: key);
  final AppModel appModel;
  void selectExperiment(String value) => appModel.currentPage = value;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Turn the list of experiments in the model, to menu buttons
        ...appModel.pageNames.map((name) => _MenuBtn(
              label: name,
              isSelected: name == appModel.currentPage,
              onPressed: selectExperiment,
            ))
      ],
    );
  }
}

class _MenuBtn extends StatelessWidget {
  const _MenuBtn({Key key, this.label, this.isSelected = false, this.onPressed}) : super(key: key);
  final String label;
  final bool isSelected;
  final void Function(String) onPressed;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);

    return OutlineButton(
      onPressed: () => onPressed(label),
      child: SizedBox(
        width: 200,
        height: 50,
        child: Center(child: Text(label, style: style)),
      ),
    );
  }
}

/// ////////////////////////////////////////////////
/// ROUTER DELEGATE & PARSER
/// There are really only 4 methods that matter here.
/// Delegate: build(), popRoute()
/// Parser: restoreRouteInformation(), parseRouteInformation()
/// Both the Delegate and the Parser, take an instance of the AppModel, and use it to change the app state and verify data.
class AppRouterDelegate extends RouterDelegate<AppModel> with ChangeNotifier {
  AppRouterDelegate(this.model) {
    // Accept the model as a param, and listen to it for changes. Rebuild anytime model changes.
    this.model.addListener(notifyListeners);
  }
  final AppModel model;

  @override
  // By supplying this, we indicate to Router it should update the browser URL
  AppModel get currentConfiguration => model;

  @override
  // Return the current stack of pages according to state.
  // This demo only ever has 1 Page in the stack.
  Widget build(BuildContext context) {
    return Navigator(
      // Viewstack has only one view, it will manage view-state internally
      pages: [
        // Navigator requires all pages are wrapped in a Page() widget, use MaterialPage cause it's easy.
        MaterialPage(
          child: MainScaffold(),
        ),
      ],
      // With a 1-Page app we never want the first page to be popped. So we'll return a false here.
      // If you had multiple pages, you could do more like `if(route.didPop()){ return popRoute(); } return false;`
      onPopPage: (route, result) => false,
    );
  }

  @override
  // Android back button
  Future<bool> popRoute() async {
    // If we have a current experiment we'll go back to the home view.
    if (model.currentPage != null) {
      model.currentPage = null;
      return true;
    }
    return false;
  }

  @override
  // This method is redundant in this example, as we're letting the RouteInformationParser
  // update the appModel directly in order to save boilerplate.
  Future<void> setNewRoutePath(AppModel deepLink) async {}
}

class AppRouteParser extends RouteInformationParser<AppModel> {
  AppRouteParser(this.model);
  final AppModel model;

  @override
  // Return location for AppModel's current state (/pageName/)
  RouteInformation restoreRouteInformation(_) {
    return RouteInformation(location: "/${model.currentPage ?? ""}");
  }

  @override
  // Parse location, verify links, and update the AppModel with the new state.
  Future<AppModel> parseRouteInformation(RouteInformation routeInformation) async {
    // See if we have any location segments that we can parse into experiments
    String location = routeInformation.location;
    List<String> segments = location.split("/")..removeWhere((e) => e == "");
    String experiment = "OpeningCards";
    if (segments.length > 0) {
      // Assume first segment is an experiment name and validate it
      if (model.isValidExperimentName(segments[0])) {
        experiment = segments[0];
      }
    }
    model.currentPage = experiment;
    return model;
  }
}
