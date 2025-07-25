import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:puppal_application/controller/mainGeneralNavigateController.dart';

class Clinicappnavigator {
  static final List<int> _navigationStack = [];
  static MainNavigationController? _navController;

  // Initialize the navigation system
  static void initialize() {
    _navController = Get.find<MainNavigationController>();
    _navigationStack.clear();
    _navigationStack.add(1); // Default to main page
  }

  // Navigate to a new page (like Get.to)
  static void to(int pageIndex, {Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    _navigationStack.add(pageIndex);
    _navController!.navigateToPage(pageIndex, params: parameters);
  }

  // Navigate to a new page with dynamic widget (like Get.to with widget)
  static void toWidget(Widget page,
      {String? title, Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    int newIndex = _navController!.addDynamicPage(page, title: title);
    _navigationStack.add(newIndex);
    _navController!.navigateToPage(newIndex, params: parameters);
  }

  // Replace current page (like Get.off)
  static void off(int pageIndex, {Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
    }
    _navigationStack.add(pageIndex);
    _navController!.navigateToPage(pageIndex, params: parameters);
  }

  // Replace current page with widget (like Get.off with widget)
  static void offWidget(Widget page,
      {String? title, Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
    }
    int newIndex = _navController!.addDynamicPage(page, title: title);
    _navigationStack.add(newIndex);
    _navController!.navigateToPage(newIndex, params: parameters);
  }

  // Clear all and navigate to new page (like Get.offAll)
  static void offAll(int pageIndex, {Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    // Clear all navigation history
    _navigationStack.clear();

    // Clear all dynamic pages
    _navController!.dynamicPages.clear();
    _navController!.pageTitles.removeWhere((key, value) => key >= 6);

    // Clear parameters
    _navController!.clearParameters();

    // Add new page as the only page in stack
    _navigationStack.add(pageIndex);
    _navController!.navigateToPage(pageIndex, params: parameters);
  }

  // Clear all and navigate to new widget (like Get.offAll with widget)
  static void offAllWidget(Widget page,
      {String? title, Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    // Clear all navigation history
    _navigationStack.clear();

    // Clear all dynamic pages
    _navController!.dynamicPages.clear();
    _navController!.pageTitles.removeWhere((key, value) => key >= 6);

    // Clear parameters
    _navController!.clearParameters();

    // Add new page as the only page in stack
    int newIndex = _navController!.addDynamicPage(page, title: title);
    _navigationStack.add(newIndex);
    _navController!.navigateToPage(newIndex, params: parameters);
  }

  // Navigate back (like Get.back)
  static bool back() {
    if (_navController == null) initialize();

    if (_navigationStack.length > 1) {
      int currentIndex = _navigationStack.removeLast();

      // Remove dynamic page if it exists
      if (_navController!.dynamicPages.containsKey(currentIndex)) {
        _navController!.removeDynamicPage(currentIndex);
      }

      // Navigate to previous page
      int previousIndex = _navigationStack.last;
      _navController!.navigateToPage(previousIndex);
      return true;
    }
    return false;
  }

  // Navigate back until specific page (like Get.until)
  static void until(int targetPageIndex) {
    if (_navController == null) initialize();

    while (_navigationStack.length > 1 &&
        _navigationStack.last != targetPageIndex) {
      int currentIndex = _navigationStack.removeLast();

      // Remove dynamic page if it exists
      if (_navController!.dynamicPages.containsKey(currentIndex)) {
        _navController!.removeDynamicPage(currentIndex);
      }
    }

    if (_navigationStack.isNotEmpty) {
      _navController!.navigateToPage(_navigationStack.last);
    }
  }

  // Pop multiple pages back (like Get.close with count)
  static void close(int count) {
    if (_navController == null) initialize();

    for (int i = 0; i < count && _navigationStack.length > 1; i++) {
      int currentIndex = _navigationStack.removeLast();

      // Remove dynamic page if it exists
      if (_navController!.dynamicPages.containsKey(currentIndex)) {
        _navController!.removeDynamicPage(currentIndex);
      }
    }

    if (_navigationStack.isNotEmpty) {
      _navController!.navigateToPage(_navigationStack.last);
    }
  }

  // Handle system back button
  static bool handleSystemBack() {
    return back();
  }

  // Check if can go back
  static bool canGoBack() {
    return _navigationStack.length > 1;
  }

  // Get current navigation stack
  static List<int> getNavigationStack() {
    return List.from(_navigationStack);
  }

  // Get current page index
  static int getCurrentIndex() {
    return _navigationStack.isNotEmpty ? _navigationStack.last : 1;
  }

  // Clear entire navigation stack
  static void clearStack() {
    _navigationStack.clear();
    if (_navController != null) {
      _navController!.dynamicPages.clear();
      _navController!.pageTitles.removeWhere((key, value) => key >= 6);
      _navController!.clearParameters();
    }
  }

  // Check if specific page is in stack
  static bool isInStack(int pageIndex) {
    return _navigationStack.contains(pageIndex);
  }

  // Get stack depth
  static int getStackDepth() {
    return _navigationStack.length;
  }

  // Navigate to page and clear stack up to target (like offAllUntil)
  static void offAllUntil(int targetPageIndex, int newPageIndex,
      {Map<String, dynamic>? parameters}) {
    if (_navController == null) initialize();

    // Find target page in stack
    int targetStackIndex = -1;
    for (int i = _navigationStack.length - 1; i >= 0; i--) {
      if (_navigationStack[i] == targetPageIndex) {
        targetStackIndex = i;
        break;
      }
    }

    if (targetStackIndex != -1) {
      // Remove pages after target
      while (_navigationStack.length > targetStackIndex + 1) {
        int currentIndex = _navigationStack.removeLast();
        if (_navController!.dynamicPages.containsKey(currentIndex)) {
          _navController!.removeDynamicPage(currentIndex);
        }
      }
    } else {
      // Target not found, clear all
      _navigationStack.clear();
      _navController!.dynamicPages.clear();
      _navController!.pageTitles.removeWhere((key, value) => key >= 6);
    }

    // Add new page
    _navigationStack.add(newPageIndex);
    _navController!.navigateToPage(newPageIndex, params: parameters);
  }

  // Debug method to print current stack
  static void printStack() {
    print('Navigation Stack: $_navigationStack');
    if (_navController != null) {
      print('Dynamic Pages: ${_navController!.dynamicPages.keys.toList()}');
    }
  }
}
