// Main app scaffold, internally shows / hides views depending on app state
import 'package:flutter/material.dart';
import 'package:flutter_experiments/context_menu/context_menu_overlay.dart';
import 'package:flutter_experiments/context_menu/context_menus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_model.dart';
import 'stateful_props/stateful_prop_demo.dart';

class AppScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppModel model = context.watch();
    String currentPage = model.currentPage;
    return ContextMenuRegion(
      contextMenu: AppContextMenu(
        srcUrl: model.currentSrcUrl,
      ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: currentPage == null ? _HomeView() : _ExperimentView(),
        ),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText("Flutter Experiments", style: TextStyle(fontSize: 32)),
          // TODO Make a dedicated LinkBtn?
          ContextMenuRegion(
              child: TextButton(
                  onPressed: () => launch("http://gskinner.com"),
                  child: Text("by gskinner.com", style: TextStyle(color: Colors.blue))),
              contextMenu: LinkContextMenu(url: "gskinner.com")),
          SizedBox(height: 20),
          _MainMenu(),
        ],
      ),
    );
  }
}

class _ExperimentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppModel model = context.watch();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Side Menu
      SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            _MenuBtn(label: "HOME", onPressed: (_) => model.currentPage = null),
            _MainMenu(),
          ],
        ),
      ),
      // Page Area
      Flexible(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          // Build the current experiment according to nav-state
          child: model.currentPageBuilder?.call(),
        ),
      )
    ]);
  }
}

class _MainMenu extends StatelessWidget {
  void selectExperiment(BuildContext context, String value) {
    context.read<AppModel>().currentPage = value;
  }

  @override
  Widget build(BuildContext context) {
    AppModel model = context.watch();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Turn the list of experiments names into menu buttons
        ...model.pageNames.map((name) => _MenuBtn(
              label: name,
              isSelected: name == model.currentPage,
              onPressed: (value) => selectExperiment(context, value),
            )),
        SizedBox(height: 40),
        SelectableText("v${AppModel.kVersion}"),
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
    bool isNarrow = MediaQuery.of(context).size.width < 500;
    Widget content = SizedBox(
      width: isNarrow ? 100 : 200,
      height: 50,
      child: Center(child: Text(label, style: style, textAlign: TextAlign.center)),
    );
    return isSelected
        ? content
        : OutlineButton(
            onPressed: () => onPressed(label),
            child: content,
          );
  }
}
