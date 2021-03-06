import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'context_menu_overlay.dart';

String checkUrl(String url) {
  bool needsPrefix = !url.contains("http://") && !url.contains("https://");
  return (needsPrefix) ? "https://" + url : url;
}

void launchUrl(String url) => launch(checkUrl(url)).catchError((Object e) => print(e));

class ContextMenuCard extends StatelessWidget {
  const ContextMenuCard({Key key, this.children}) : super(key: key);
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 210,
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), offset: Offset(3, 3), blurRadius: 3),
            BoxShadow(color: Colors.black.withOpacity(.03), offset: Offset(3, 3), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ));
  }
}

class ImageContextMenu extends _BaseContextMenu {
  const ImageContextMenu({Key key, this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return ContextMenuCard(
      children: [
        /// Todo: Add ability to acually save thi  s
        _MenuBtn("Save Image as..."),
      ],
    );
  }
}

class AppContextMenu extends _BaseContextMenu {
  const AppContextMenu({Key key, @required this.srcUrl}) : super(key: key);
  final String srcUrl;

  void _handleViewSourcePressed() async => launchUrl(srcUrl);

  @override
  Widget build(BuildContext context) {
    bool noSrcUrl = srcUrl == null;
    return ContextMenuCard(
      children: [
        _MenuBtn("View Source", onPressed: noSrcUrl ? null : () => handlePress(context, _handleViewSourcePressed)),
      ],
    );
  }
}

class LinkContextMenu extends _BaseContextMenu {
  const LinkContextMenu({Key key, @required this.url}) : super(key: key);
  final String url;

  void _handleNewWindowPressed() async => launchUrl(url);

  void _handleClipboardPressed() async => Clipboard.setData(ClipboardData(text: checkUrl(url)));

  @override
  Widget build(BuildContext context) {
    bool noUrl = url == null;
    return ContextMenuCard(
      children: [
        // Wrap each handler with a handlePress() call, this closes the menu when we click something
        _MenuBtn("Open link in new window",
            onPressed: noUrl ? null : () => handlePress(context, _handleNewWindowPressed)),
        _MenuBtn("Copy link address", onPressed: noUrl ? null : () => handlePress(context, _handleClipboardPressed))
      ],
    );
  }
}

abstract class _BaseContextMenu extends StatelessWidget {
  const _BaseContextMenu({Key key}) : super(key: key);
  // Convenience method so each menu item does not need to manually Close the context menu.
  void handlePress(BuildContext context, VoidCallback action) {
    action?.call();
    CloseContextMenuNotification().dispatch(context);
  }
}

class _MenuBtn extends StatelessWidget {
  const _MenuBtn(this.label, {Key key, this.onPressed}) : super(key: key);
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Text(
            label ?? "",
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400),
          ),
        ),
        onPressed: onPressed);
  }
}
