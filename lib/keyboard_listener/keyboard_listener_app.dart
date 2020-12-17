import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// A simple demo showing how to use ESC button on desktop close a dialog.

// Note: With barrierDismissible:true, ESC will close by default.
// This example shows how we can use barrierDismissible:false, but still have ESC support.
// Mainly it is just meant to serve as a simple usage example of desktop key listeners.

class KeyboardListenerApp extends StatefulWidget {
  @override
  _KeyboardListenerAppState createState() => _KeyboardListenerAppState();
}

class _KeyboardListenerAppState extends State<KeyboardListenerApp> {
  String _result = "";

  // Show a basic alert dialog, with barrierDismissible:false. `MyDialog` handles the Keyboard listening internally.
  void _handleShowDialogPressed(BuildContext context) async {
    bool confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MyDialog(),
    );
    setState(() => _result = confirmed ? "CONFIRMED!" : "CANCELLED :(");
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlineButton(
                  child: Text("SHOW DIALOG"),
                  onPressed: () => _handleShowDialogPressed(context),
                ),
                Text(_result ?? "", style: TextStyle(fontSize: 32)),
              ],
            ),
          ),
        ),
      );
}

class MyDialog extends StatelessWidget {
  // Handle the keydown event, and check if we should close the dialog.
  void _handleKey(BuildContext context, RawKeyEvent value) {
    // Check if we should close ourselves
    bool escapeWasPressed = value.logicalKey == LogicalKeyboardKey.escape;
    if (escapeWasPressed) {
      Navigator.pop(context, false);
    }
    // Example output:
    // RawKeyDownEvent#a7d5b(logicalKey: LogicalKeyboardKey#70029(keyId: "0x100070029", keyLabel: "", debugName: "Escape"), physicalKey: PhysicalKeyboardKey#70029(usbHidUsage: "0x00070029", debugName: "Escape"))
    // RawKeyUpEvent#6b7af(logicalKey: LogicalKeyboardKey#70029(keyId: "0x100070029", keyLabel: "", debugName: "Escape"), physicalKey: PhysicalKeyboardKey#70029(usbHidUsage: "0x00070029", debugName: "Escape"))
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      // A focusNode is required to capture key events. Set canRequestFocus:false, so the user can not TAB to this focus node.
      focusNode: FocusNode(canRequestFocus: false),
      onKey: (value) => _handleKey(context, value),
      child: AlertDialog(
        title: Text("Use ESC to cancel, ENTER to Confirm, TAB to change btns."),
        actions: <Widget>[
          TextButton(
            autofocus: true,
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
