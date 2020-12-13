import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Notification to trigger the ContextMenu
class ShowContextMenuNotification extends Notification {
  ShowContextMenuNotification({this.child, this.size});
  final Widget child;
  final Size size;
}

class CloseContextMenuNotification extends Notification {}

// Helper widget, to dispatch Notifications when a right-click is detected on some child
class ContextMenuRegion extends StatelessWidget {
  const ContextMenuRegion({Key key, @required this.child, @required this.contextMenu}) : super(key: key);
  final Widget child;
  final Widget contextMenu;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTap: () => ShowContextMenuNotification(
        child: contextMenu,
      ).dispatch(context),
      child: child,
    );
  }
}

// The main overlay class, holds a Stack which contains the main app, contextMenu and contextModal
class ContextOverlay extends StatefulWidget {
  const ContextOverlay({Key key, this.child}) : super(key: key);
  final Widget child;
  @override
  _ContextOverlayState createState() => _ContextOverlayState();
}

class _ContextOverlayState extends State<ContextOverlay> {
  Widget _currentMenu;
  Size _menuSize = Size.zero;
  Offset _mousePos = Offset.zero;
  Size _prevSize;

  void closeCurrent() => setState(() => _currentMenu = null);

  bool _handleNotificationReceived(Notification n) {
    if (n is ShowContextMenuNotification) {
      setState(() {
        _menuSize = Size.zero; //This will hide the widget until we can calculate it's size
        _currentMenu = n.child;
      });
    } else if (n is CloseContextMenuNotification) {
      closeCurrent();
    }
    return true;
  }

  void _handleMenuSizeChanged(Size value) => setState(() => _menuSize = value);

  void nullMenuIfWindowsWasResized(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool appWasResized = size != _prevSize;
    if (appWasResized) _currentMenu = null;
    _prevSize = size;
  }

  @override
  Widget build(BuildContext context) {
    nullMenuIfWindowsWasResized(context);
    // Offset the menu depending on which quadrant of the app we're in, this will make sure it always stays in bounds.
    double dx = 0, dy = 0;
    if (_mousePos.dx > _prevSize.width / 2) dx = -_menuSize.width;
    if (_mousePos.dy > _prevSize.height / 2) dy = -_menuSize.height;
    // The final menuPos, is mousePos + quadrant offset
    Offset _menuPos = _mousePos + Offset(dx, dy);
    return Scaffold(
      body: MouseRegion(
        onHover: (event) => _mousePos = event.position,
        // Listen for Notifications coming up from the app
        child: NotificationListener(
          onNotification: _handleNotificationReceived,
          //A Stack to hold the app content and the menu if there is one
          child: Stack(
            children: [
              // Child is the contents of the overlay, usually the entire app.
              widget.child,
              // Show the menu?
              if (_currentMenu != null) ...{
                // Modal underlay, blocks all taps to the main content.
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (_) => closeCurrent(),
                  onTap: () => closeCurrent(),
                  onSecondaryTapDown: (_) => closeCurrent(),
                  child: Container(),
                ),
                // Menu
                Transform.translate(
                  offset: _menuPos,
                  child: Opacity(
                    opacity: _menuSize != Size.zero ? 1 : 0,
                    child: _MeasureSize(
                      onChange: _handleMenuSizeChanged,
                      child: _currentMenu,
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);
  void Function(Size size) onChange;

  Size _prevSize;
  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child.size;
    if (_prevSize == newSize) return;
    _prevSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({Key key, @required this.onChange, @required Widget child}) : super(key: key, child: child);
  final void Function(Size size) onChange;
  @override
  RenderObject createRenderObject(BuildContext context) => _MeasureSizeRenderObject(onChange);
}
