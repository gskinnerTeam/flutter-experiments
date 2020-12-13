import 'dart:ui';

import 'package:flutter/material.dart';

import 'context_menu_overlay.dart';
import 'context_menus.dart';

class ContextMenuTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String url = "https://miro.medium.com/max/1400/0*nZzXEwKpXHOS2OpG";
    return MaterialApp(
      home: ContextOverlay(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: double.infinity),
                // Link btn, w/ ContextMenu
                ContextMenuRegion(
                  contextMenu: LinkContextMenu(url: "www.gskinner.com"),
                  child: TextButton(child: Text("www.gskinner.com"), onPressed: () {}),
                ),
                ContextMenuRegion(
                  contextMenu: LinkContextMenu(url: "1/http://badurl"),
                  child: TextButton(child: Text("1/http://badurl"), onPressed: () {}),
                ),
                // An image, w/ ContextMenu
                ContextMenuRegion(
                  contextMenu: ImageContextMenu(url: url),
                  child: _SomeImageWidget(url: url),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SomeImageWidget extends StatelessWidget {
  const _SomeImageWidget({Key key, this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 200, width: 200, child: Image.network(url));
  }
}
