import 'dart:async';
import 'package:flutter/material.dart';
import 'package:statsfl/statsfl.dart';
import 'package:flutter_experiments/optimized_drag_stack/optimized_drag_stack.dart';

void main() {
  runApp(StatsFl(child: ExperimentsApp()));
}

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

// A map of view-builders by name. Used to build the main menu, and render each content area.
Map<String, Widget Function()> experimentsByName = {
  "OptimizedDragAndDrop": () => OptimizedDragStack(),
};

// A model that holds state regarding the app navigation, and API for interaction with RouterDelegate and RouteParser
class NavModel extends ChangeNotifier {
  String _currentExperiment;
  String get currentExperiment => _currentExperiment;
  set currentExperiment(String currentExperiment) {
    _currentExperiment = currentExperiment;
    notifyListeners();
  }

  // Called by RouterDelegate when AndroidBack btn is pressed
  bool navigateUp() {
    if (currentExperiment != null) {
      currentExperiment = null;
      return true;
    }
    return false;
  }

  // Builds an experiment according to currentExperiment value
  Widget buildCurrentExperiment() {
    if (experimentsByName.containsKey(currentExperiment) == false) return null;
    return experimentsByName[currentExperiment].call();
  }

  // Called by RouteParser, when the browser wants the link
  String toLink() {
    return currentExperiment ?? "/";
  }

  // Called by Router, when it has a new location/deeplink
  void copyFromLink(String location) {
    List<String> segments = location.split("/");
    if (segments.length > 0) {
      // Validate the experimentName since the user can type anything into the browser.
      if (experimentsByName.keys.contains(segments[0])) {
        currentExperiment = segments[0];
      }
    }
  }
}

NavModel _navModel = NavModel();
AppRouterDelegate _appRouterDelegate = AppRouterDelegate(_navModel);
AppRouteParser _appRouteParser = AppRouteParser(_navModel);

/// ////////////////////////////////////////////////
/// TABBED SCAFFOLD VIEW
/// ///////////////////////////////////////////////
class TabbedScaffold extends StatelessWidget {
  const TabbedScaffold({Key key, this.navModel}) : super(key: key);
  final NavModel navModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: navModel.currentExperiment == null
            // 'Home' View
            ? Container(
                alignment: Alignment.center,
                child: _MainMenu(navModel),
              )
            : Row(
                children: [
                  // Side Menu
                  Column(
                    children: [
                      SizedBox(height: 50),
                      _MenuBtn(label: "HOME", onPressed: (_) => navModel.currentExperiment = null),
                      _MainMenu(_navModel)
                    ],
                  ),
                  // Page Area
                  Flexible(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      // Build the current experiment according to nav-state
                      child: navModel.buildCurrentExperiment(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MainMenu extends StatelessWidget {
  const _MainMenu(this.navModel, {Key key}) : super(key: key);
  final NavModel navModel;
  void selectExperiment(String value) => navModel.currentExperiment = value;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Turn the list of experiments in the model, to menu buttons
        ...navModel.experimentsByName.keys.map((name) => _MenuBtn(
              label: name,
              isSelected: name == navModel.currentExperiment,
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

class AppRouterDelegate extends RouterDelegate<NavModel> with ChangeNotifier {
  AppRouterDelegate(this.navModel) {
    // Accept the state as a param, and listen to it for changes. This lets us rebuild anytime the NavModel changes.
    this.navModel.addListener(notifyListeners);
  }
  final NavModel navModel;

  @override
  // Allows Router to get the current state of the app when it needs
  NavModel get currentConfiguration => navModel;

  @override
  Widget build(BuildContext context) => Navigator(
        // The main scaffold will not support pop() usage directly, so we'll just return a false here.
        onPopPage: (route, result) => false,
        // Viewstack has only one view, TabbedScaffold, it will build it's own view internally.
        pages: [MaterialPage(child: TabbedScaffold(navModel: navModel))],
      );

  @override
  // Android back btn goes up in the navigation:
  Future<bool> popRoute() async => navModel.navigateUp();

  @override
  Future<void> setNewRoutePath(newNav) async => navModel.copyFromLink(newNav.toLink());
}

class AppRouteParser extends RouteInformationParser<NavModel> {
  AppRouteParser(this.navModel);
  final NavModel navModel;

  @override
  RouteInformation restoreRouteInformation(NavModel model) => RouteInformation(location: model.toLink());

  @override
  Future<NavModel> parseRouteInformation(RouteInformation routeInformation) async {
    return navModel..copyFromLink(routeInformation.location);
  }
}
