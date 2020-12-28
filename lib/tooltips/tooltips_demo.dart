import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

class TooltipsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Portal(
      child: _DemoView(),
    );
  }
}

class _DemoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PortalEntry(
            visible: true,
            portalAnchor: Alignment.topLeft,
            childAnchor: Alignment.topRight,
            portal: Material(
              elevation: 8,
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(title: Text('option 1')),
                    ListTile(title: Text('option 2')),
                  ],
                ),
              ),
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.network("https://images.unsplash.com/photo-1517699418036-fb5d179fef0c?w=1800&q=95"),
            ),
          ),
          FlatButton(onPressed: () {}, child: Text("CLICK ME"))
        ],
      ),
    );
  }
}
