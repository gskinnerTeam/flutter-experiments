//
//enum PageTypes {
//  Page1,
//  Page2,
//  Page3,
//}
//
//class NavModel extends ChangeNotifier {
//  PageTypes _currentPage;
//
//  PageTypes get currentPage => _currentPage;
//  set currentPage(PageTypes value) {
//    _currentPage = value;
//    notifyListeners();
//  }
//
//  bool handlePopPage(Route<dynamic> route, dynamic result) {
//    if (currentPage != null) {
//      if (route.didPop(result)) {
//        currentPage = null;
//        return true; //Indicates that we handled pop, so the OS doesn't pop us
//      }
//    }
//    return false;
//  }
//
//  List<Page> buildPages() {
//    return [
//      _MyHome(),
//      if (currentPage != null) ...{
//        _MyView(title: "$currentPage", key: ValueKey(currentPage)),
//      },
//    ].map((widget) => MaterialPage(child: widget)).toList();
//  }
//}
//
//NavModel _navModel = NavModel();
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      builder: (_, __) {
//        return AnimatedBuilder(
//          animation: _navModel,
//          builder: (_, __) => Navigator(
//            pages: _navModel.buildPages(),
//            onPopPage: _navModel.handlePopPage,
//          ),
//        );
//      },
//    );
//  }
//}
//
//class _MyHome extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Center(
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: [
//            FlatButton(child: Text("PAGE1"), onPressed: () => _navModel.currentPage = PageTypes.Page1),
//            FlatButton(child: Text("PAGE2"), onPressed: () => _navModel.currentPage = PageTypes.Page2),
//            FlatButton(child: Text("PAGE3"), onPressed: () => _navModel.currentPage = PageTypes.Page3),
//            FlatButton(child: Text("POP"), onPressed: () => Navigator.of(context).pop()),
//          ],
//        ),
//      ),
//    );
//  }
//}
//
//class _MyView extends StatelessWidget {
//  const _MyView({Key key, this.title}) : super(key: key);
//  final String title;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Center(
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: [
//            Text("$title"),
//            FlatButton(child: Text("POP"), onPressed: () => Navigator.of(context).pop()),
//            FlatButton(child: Text("GO HOME"), onPressed: () => _navModel.currentPage = null),
//          ],
//        ),
//      ),
//    );
//  }
//}
