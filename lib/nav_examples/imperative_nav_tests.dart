import 'package:flutter/material.dart';

class ImperativeNavTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Simple tests to make sure that page-less routes and dialogs work correctly within the main app."),
        FlatButton(onPressed: () => _showDialog(context), child: Text("SHOW DIALOG")),
        FlatButton(
            onPressed: () => _showRoute(
                  context,
                ),
            child: Text("PUSH ROUTE")),
      ],
    ));
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => new SimpleDialog(
        title: new Text('This button calls pop()'),
        children: [
          SimpleDialogOption(child: new Text('pop!'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  _showRoute<T>(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder<T>(
      transitionDuration: Duration(milliseconds: 300.round()),
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("POP"),
          ),
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }
}
