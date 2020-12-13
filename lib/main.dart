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
    return RouteInformation(location: "${model.currentPage ?? "/"}");
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
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        pages: model.currentPageStack(),
        onPopPage: model.handlePopPage,
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(NavModel model) async {
    this.model.currentPage = model.currentPage;
  }
}

class NavModel extends ChangeNotifier {
  PageTypes _currentPage;

  PageTypes get currentPage => _currentPage;
  set currentPage(PageTypes value) {
    _currentPage = value;
    notifyListeners();
  }

  bool handlePopPage(Route<dynamic> route, dynamic result) {
    bool result = false;
    if (route.didPop(result)) {
      currentPage = null;
      result = true;
    }
    return result;
  }

  List<Page> currentPageStack() {
    return [
      _Home(),
      if (currentPage == PageTypes.Page1) ...{
        _Page1(),
      } else if (currentPage == PageTypes.Page2) ...{
        _Page2(),
      } else if (currentPage == PageTypes.Page3) ...{
        _Page3(),
      },
    ].map((widget) => MaterialPage(child: widget)).toList();
  }
}

NavModel _navModel = NavModel();

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

class _MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlatButton(child: Text("POP"), onPressed: () => Navigator.of(context).pop()),
          FlatButton(child: Text("PAGE1"), onPressed: () => _navModel.currentPage = PageTypes.Page1),
          FlatButton(child: Text("PAGE2"), onPressed: () => _navModel.currentPage = PageTypes.Page2),
          FlatButton(child: Text("PAGE3"), onPressed: () => _navModel.currentPage = PageTypes.Page3),
          FlatButton(
              child: Text("PUSH ROUTE"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                  return Container(child: _MainMenu());
                }));
              }),
          FlatButton(child: Text("DIALOG"), onPressed: () => showDialog(context: context, builder: (_) => _MyDialog())),
          FlatButton(child: Text("GO HOME"), onPressed: () => _navModel.currentPage = null),
        ],
      );
}

class _MyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(8),
      child: FlatButton(child: Text("Close"), onPressed: () => Navigator.of(context).pop()));
}

class _Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [Text("HOME", style: TextStyle(fontSize: 72)), _MainMenu()]);
}

class _Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [Text("PAGE 1", style: TextStyle(fontSize: 72)), _MainMenu()]);
}

class _Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [Text("PAGE 2", style: TextStyle(fontSize: 72)), _MainMenu()]);
}

class _Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [Text("PAGE 3", style: TextStyle(fontSize: 72)), _MainMenu()]);
}
