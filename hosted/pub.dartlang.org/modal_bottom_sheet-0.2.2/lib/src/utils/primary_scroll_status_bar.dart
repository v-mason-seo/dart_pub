import 'package:flutter/widgets.dart';

/// Creates a primary scroll controller that will
/// scroll to the top when tapped on the status bar
///
class PrimaryScrollStatusBarHandler extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const PrimaryScrollStatusBarHandler(
      {Key key, this.child, this.scrollController})
      : super(key: key);
  @override
  _PrimaryScrollWidgetState createState() => _PrimaryScrollWidgetState();
}

class _PrimaryScrollWidgetState extends State<PrimaryScrollStatusBarHandler> {
  ScrollController controller;

  @override
  void initState() {
    controller = widget.scrollController ?? ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: controller,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top,
            child: Builder(
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleStatusBarTap(context),
                // iOS accessibility automatically adds scroll-to-top to the clock in the status bar
                excludeFromSemantics: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStatusBarTap(BuildContext context) {
    final controller = PrimaryScrollController.of(context);
    if (controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear, // TODO(ianh): Use a more appropriate curve.
      );
    }
  }
}
