import 'package:flutter/material.dart';

class NavModel extends ChangeNotifier {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int tabIndex) {
    _tabIndex = tabIndex;
    notifyListeners();
  }

  bool navigateUp() {
    if (tabIndex > 0) {
      tabIndex--;
      return true;
    }
    return false;
  }
}

NavModel _navModel = NavModel();
AppRouterDelegate _appRouterDelegate = AppRouterDelegate(_navModel);

class TabbedRouterExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouterDelegate,
      routeInformationParser: AppRouteParser(),
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
        // Handle .pop() calls.
        onPopPage: (route, result) {
          if (route.willHandlePopInternally) {
            return route.didPop(result);
          } else {
            return navModel.navigateUp(); // Move the navModel up
          }
        },
        // Viewstack has only one view, TabbedScaffold, it will build it's own view internally.
        pages: [
          // Wrap TabbedScaffold in NoAnimationPage, to avoid any transitions in the main app chrome when pop()'ing
          NoAnimationPage(child: TabbedScaffold(navModel: navModel)),
        ],
      );

  @override
  // Android back btn goes up in the navigation:
  Future<bool> popRoute() async => navModel.navigateUp();

  @override
  Future<void> setNewRoutePath(NavModel newNav) async => navModel.tabIndex = newNav.tabIndex;
}

class AppRouteParser extends RouteInformationParser<NavModel> {
  @override
  RouteInformation restoreRouteInformation(NavModel configuration) {
    return RouteInformation(location: "${configuration.tabIndex}");
  }

  @override
  Future<NavModel> parseRouteInformation(RouteInformation routeInformation) async {
    List<String> segments = routeInformation.location.split("/");
    int index = 0;
    if (segments.length > 0) {
      // Parse the location to a tabIndex
      index = int.tryParse(segments[0]) ?? 0;
      // Validate the index since the user can type anything into the browser.
      // Note: If this were some id in your database, you could do a network call here and make sure the id is valid.
      if (index > 2 || index < 0) index = 0;
    }
    return NavModel()..tabIndex = index;
  }
}

class NoAnimationPage extends Page {
  final Widget child;
  NoAnimationPage({this.child}) : super(key: ObjectKey(child));

  Route createRoute(BuildContext context) {
    return PageRouteBuilder(settings: this, pageBuilder: (context, animation, animation2) => child);
  }
}

/// ////////////////////////////////////////////////
/// PAGE CONTENT
class TabbedScaffold extends StatelessWidget {
  const TabbedScaffold({Key key, this.navModel}) : super(key: key);
  final NavModel navModel;

  // Create a list of pages by index, just a quick way to change from Page to Page by integer.
  List<Widget Function()> get pageBuilders => [
        () => Page1(),
        () => Page2(),
        () => Page3(),
      ];
  void selectTab(int value) => _navModel.tabIndex = value;

  @override
  Widget build(BuildContext context) {
    int index = _navModel.tabIndex;
    return Scaffold(
      body: Row(
        children: [
          // Side Menu
          Column(
            children: [
              SizedBox(height: 100),
              _TabBtn(index: 0, isSelected: index == 0, onPressed: selectTab),
              _TabBtn(index: 1, isSelected: index == 1, onPressed: selectTab),
              _TabBtn(index: 2, isSelected: index == 2, onPressed: selectTab),
            ],
          ),
          // Page Area
          Flexible(
              child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: pageBuilders[index].call(),
          )),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({Key key, this.index, this.isSelected, this.onPressed}) : super(key: key);
  final int index;
  final bool isSelected;
  final void Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onPressed(index),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Text("PAGE$index", style: style),
      ),
    );
    Text content = Text("PAGE$index", style: style);
    return Padding(
      padding: EdgeInsets.all(12),
      child: isSelected
          ? content
          : TextButton(
              child: content,
              onPressed: () => onPressed(index),
            ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.red.shade200,
        alignment: Alignment.center,
        child: FlatButton(child: Text("pop"), onPressed: () => Navigator.of(context).pop()),
      );
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.green.shade200,
        alignment: Alignment.center,
        child: FlatButton(child: Text("pop"), onPressed: () => Navigator.of(context).pop()),
      );
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.blue.shade200,
        alignment: Alignment.center,
        child: FlatButton(child: Text("pop"), onPressed: () => Navigator.of(context).pop()),
      );
}
