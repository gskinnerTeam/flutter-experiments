import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

PageTypes _toPageType(String key) => PageTypes.values.firstWhere((v) => "$v" == key, orElse: () => null);

enum PageTypes {
  Page1,
  Page2,
  Page3,
}

class NavModel extends ChangeNotifier {
  PageTypes _currentPage;

  PageTypes get currentPage => _currentPage;
  set currentPage(PageTypes value) {
    _currentPage = value;
    notifyListeners();
  }

  bool handlePopPage(Route<dynamic> route, dynamic result) {
    if (currentPage != null) {
      if (route.didPop(result)) {
        currentPage = null;
        return true; //Indicates that we handled pop, so the OS doesn't pop us
      }
    }
    return false;
  }

  List<Page> buildPages() {
    return [
      _MyHome(),
      if (currentPage != null) ...{
        _MyView(title: "$currentPage", key: ValueKey(currentPage)),
      },
    ].map((widget) => MaterialPage(child: widget)).toList();
  }
}

NavModel _navModel = NavModel();

class AppInformationParser extends RouteInformationParser<NavModel> {
  @override
  Future<NavModel> parseRouteInformation(RouteInformation routeInformation) async {
    NavModel result = NavModel();
    // If we have some deeplink location, parse it
    if (routeInformation.location != null) {
      List<String> keys = routeInformation.location.split("/");
      //Assume the first key is our page type
      if (keys.length > 0) result.currentPage = _toPageType(keys[0]);
    }
    return result;
  }

  @override
  RouteInformation restoreRouteInformation(NavModel model) {
    return RouteInformation(location: "${model.currentPage ?? ""}");
  }
}

class AppRouterDelegate extends RouterDelegate<NavModel> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  AppRouterDelegate(this.model) {
    this.model.addListener(notifyListeners);
  }
  final NavModel model;

  NavModel get currentConfiguration => model;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      pages: model.buildPages(),
      onPopPage: model.handlePopPage,
    );
  }

  @override
  Future<void> setNewRoutePath(NavModel model) async {
    this.model.currentPage = model.currentPage;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: AppInformationParser(),
      routerDelegate: AppRouterDelegate(_navModel),
    );
  }
}

class _MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlatButton(child: Text("PAGE1"), onPressed: () => _navModel.currentPage = PageTypes.Page1),
            FlatButton(child: Text("PAGE2"), onPressed: () => _navModel.currentPage = PageTypes.Page2),
            FlatButton(child: Text("PAGE3"), onPressed: () => _navModel.currentPage = PageTypes.Page3),
            FlatButton(child: Text("POP"), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _MyView extends StatelessWidget {
  const _MyView({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$title"),
            FlatButton(child: Text("POP"), onPressed: () => Navigator.of(context).pop()),
            FlatButton(child: Text("GO HOME"), onPressed: () => _navModel.currentPage = null),
          ],
        ),
      ),
    );
  }
}
