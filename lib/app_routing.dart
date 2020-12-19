import 'package:flutter/material.dart';
import 'app_model.dart';
import 'app_scaffold.dart';

class AppRouterDelegate extends RouterDelegate<AppModel> with ChangeNotifier {
  AppRouterDelegate(this.model) {
    // Accept the model as a param, and listen to it for changes. Rebuild anytime model changes.
    this.model.addListener(notifyListeners);
  }
  final AppModel model;

  @override
  AppModel get currentConfiguration => model;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        AppScaffold(),
      ].map((c) => MaterialPage(child: c)).toList(),
      // With a 1-Page app we never want the first page to be popped. So we'll return a false here.
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
  // Redundant in this example, as we're letting the RouteInformationParser update appModel directly
  Future<void> setNewRoutePath(AppModel deepLink) async {}
}

class AppRouteParser extends RouteInformationParser<AppModel> {
  AppRouteParser(this.model);
  final AppModel model;

  @override
  RouteInformation restoreRouteInformation(_) {
    return RouteInformation(location: "/${model.currentPage ?? ""}");
  }

  @override
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
