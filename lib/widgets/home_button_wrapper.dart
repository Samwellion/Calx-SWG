import 'package:flutter/material.dart';

/// A wrapper widget that adds a home floating action button to screens
/// except the home screen. This button navigates back to the home screen.
class HomeButtonWrapper extends StatelessWidget {
  final Widget child;
  final FloatingActionButton? existingFab;
  final bool showHomeButton;

  const HomeButtonWrapper({
    super.key,
    required this.child,
    this.existingFab,
    this.showHomeButton = true,
  });

  void _navigateToHome(BuildContext context) {
    // Navigate to home screen and clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!showHomeButton) {
      return child;
    }

    // If there's an existing FAB, we need to handle both buttons
    if (existingFab != null) {
      return Stack(
        children: [
          child,
          // Position the home button at bottom right, but slightly offset from the existing FAB
          Positioned(
            bottom: 90, // Position above the existing FAB
            right: 16,
            child: FloatingActionButton(
              heroTag: "home_button",
              onPressed: () => _navigateToHome(context),
              backgroundColor: Colors.blue[600],
              child: const Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // If no existing FAB, simply replace the child's FAB with home button
    if (child is Scaffold) {
      final scaffold = child as Scaffold;
      return Scaffold(
        key: scaffold.key,
        appBar: scaffold.appBar,
        body: scaffold.body,
        drawer: scaffold.drawer,
        endDrawer: scaffold.endDrawer,
        bottomNavigationBar: scaffold.bottomNavigationBar,
        bottomSheet: scaffold.bottomSheet,
        backgroundColor: scaffold.backgroundColor,
        resizeToAvoidBottomInset: scaffold.resizeToAvoidBottomInset,
        primary: scaffold.primary,
        drawerDragStartBehavior: scaffold.drawerDragStartBehavior,
        extendBody: scaffold.extendBody,
        extendBodyBehindAppBar: scaffold.extendBodyBehindAppBar,
        drawerScrimColor: scaffold.drawerScrimColor,
        drawerEdgeDragWidth: scaffold.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: scaffold.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: scaffold.endDrawerEnableOpenDragGesture,
        persistentFooterButtons: scaffold.persistentFooterButtons,
        floatingActionButton: FloatingActionButton(
          heroTag: "home_button",
          onPressed: () => _navigateToHome(context),
          backgroundColor: Colors.blue[600],
          child: const Icon(
            Icons.home,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: scaffold.floatingActionButtonLocation,
        floatingActionButtonAnimator: scaffold.floatingActionButtonAnimator,
      );
    }

    // Fallback for non-Scaffold widgets
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "home_button",
            onPressed: () => _navigateToHome(context),
            backgroundColor: Colors.blue[600],
            child: const Icon(
              Icons.home,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
