import 'package:flutter/material.dart';

class DesktopScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Hides default scrollbars completely
  }
}

class DesktopLayout extends StatelessWidget {
  final Widget child;

  const DesktopLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ScrollConfiguration(
        behavior: DesktopScrollBehavior(),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1920,
              height: 1080,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
