import 'package:flutter/material.dart';

class StateRestorationDemo extends StatefulWidget {
  @override
  _StateRestorationDemoState createState() => _StateRestorationDemoState();
}

class _StateRestorationDemoState extends State<StateRestorationDemo> with RestorationMixin {
  RestorableInt someInt = RestorableInt(0);

  @override
  String get restorationId => "someView";

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(someInt, "someInt");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => someInt.value++),
      child: Scaffold(
        body: Container(
          alignment: Alignment.topLeft,
          child: Text("${someInt.value}", style: TextStyle(fontSize: 34)),
        ),
      ),
    );
  }
}
