import 'package:flutter/material.dart';

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
      //Assume the first key is our page type, will fall back to null.
      if (keys.length > 0) {
        result.currentPage = _toPageType(keys[0]);
      }
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

  // Provide a global-key for the Navigator, allowing us to use the PopNavigatorRouterDelegateMixin
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
      MaterialPage(child: _Home(), key: ValueKey("Home")),
      if (currentPage == PageTypes.Page1) ...{
        MaterialPage(child: _Page1(), key: ValueKey(currentPage)),
      } else if (currentPage == PageTypes.Page2) ...{
        MaterialPage(child: _Page2(), key: ValueKey(currentPage)),
      } else if (currentPage == PageTypes.Page3) ...{
        MaterialPage(child: _Page3(), key: ValueKey(currentPage)),
      },
    ];
  }
}

NavModel _navModel = NavModel();

class NavStep2BasicRouter extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: AppInformationParser(),
      routerDelegate: AppRouterDelegate(_navModel),
      builder: (_, content) {
        return Column(
          children: [
            Text("TITLE"),
            content,
          ],
        );
      },
    );
  }
}

/// ///////////////////////////////////////////
/// VIEWS

class _Home extends StatelessWidget {
  const _Home({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _MyScaffold(title: "HOME", page: Container());
}

class _Page1 extends StatelessWidget {
  const _Page1({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _MyScaffold(title: "Page1", page: Container(color: Colors.red.shade200));
}

class _Page2 extends StatelessWidget {
  const _Page2({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _MyScaffold(title: "Page2", page: Container(color: Colors.blue.shade200));
}

class _Page3 extends StatelessWidget {
  const _Page3({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => _MyScaffold(title: "Page3", page: Container(color: Colors.green.shade200));
}

class _MyScaffold extends StatelessWidget {
  const _MyScaffold({Key key, this.title, this.page}) : super(key: key);
  final String title;
  final Widget page;
  @override
  Widget build(BuildContext context) {
    bool showHome = _navModel.currentPage != null;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          color: Colors.grey.shade200,
          child: Column(
            children: [
              FlatButton(child: Text("PAGE1"), onPressed: () => _navModel.currentPage = PageTypes.Page1),
              FlatButton(child: Text("PAGE2"), onPressed: () => _navModel.currentPage = PageTypes.Page2),
              FlatButton(child: Text("PAGE3"), onPressed: () => _navModel.currentPage = PageTypes.Page3),
            ],
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 24)),
                if (showHome) ...{
                  TextButton(
                      child: Text("HOME > ", style: TextStyle(color: Colors.blue)),
                      onPressed: () => _navModel.currentPage = null),
                },
                Flexible(child: page),
              ],
            ),
          ),
        )
      ],
    );
  }
}
