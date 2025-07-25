import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puppal_application/pages/clinicAppNavigator.dart';

class Mainclinicnavigatecontroller extends GetxController {
  // Current page index
  var currentIndex = 1.obs;

  // Dynamic pages storage
  var dynamicPages = <int, Widget>{}.obs;

  // Page titles
  var pageTitles = <int, String>{}.obs;

  // Parameters for pages
  var pageParameters = <String, dynamic>{}.obs;

  // Bottom navigation controller
  late NotchBottomBarController notchBottomBarController;

  @override
  void onInit() {
    super.onInit();
    notchBottomBarController = NotchBottomBarController(index: 1);

    // Initialize default titles
    pageTitles.addAll({
      0: 'คำขอฉีดวัคซีน',
      1: 'PUPPAL',
      2: 'การแจ้งเตือน',
      3: 'หมอ',
      4: 'ประวัติการฉีดยา',
      5: 'ตั้งค่า',
    });
  }

  // Navigate to a specific page
  void navigateToPage(int index, {Map<String, dynamic>? params}) {
    currentIndex.value = index;

    // Store parameters if provided
    if (params != null) {
      pageParameters.clear(); // Clear previous params
      pageParameters.addAll(params);
    }

    // Update bottom navigation controller
    updateBottomNavController(index);
    update();
  }

  // Add dynamic page
  int addDynamicPage(Widget page, {String? title}) {
    // Find next available index (starting from 6)
    int newIndex = 6;
    while (dynamicPages.containsKey(newIndex)) {
      newIndex++;
    }

    dynamicPages[newIndex] = page;
    if (title != null) {
      pageTitles[newIndex] = title;
    }

    return newIndex;
  }

  // Remove dynamic page
  void removeDynamicPage(int index) {
    dynamicPages.remove(index);
    pageTitles.remove(index);
  }

  // Get page title
  String getPageTitle(int index) {
    return pageTitles[index] ?? 'PUPPAL';
  }

  // Get parameter
  T? getParameter<T>(String key) {
    return pageParameters[key] as T?;
  }

  // Clear parameters
  void clearParameters() {
    pageParameters.clear();
  }

  // Update current index (for external updates)
  void updateIndex(int index) {
    currentIndex.value = index;
    updateBottomNavController(index);
  }

  // Handle bottom navigation controller updates
  void updateBottomNavController(int index) {
    if (index <= 2) {
      // For valid bottom nav indices, set normally
      notchBottomBarController.index = index;
      // notchBottomBarController.jumpTo(index);
    } else {
      // For drawer pages, create a new controller with no selection
      // This forces all items to show as inactive
      // notchBottomBarController.dispose();
      // notchBottomBarController = NotchBottomBarController(index: -1);
      notchBottomBarController.index = -1;
    }
  }

  // Check if bottom navigation should show active state
  bool isBottomNavActive() {
    return currentIndex.value <= 2;
  }

  // Clean up dynamic pages (call when needed to free memory)
  void cleanupDynamicPages() {
    // Remove pages that are not in the navigation stack
    List<int> stackIndices = Clinicappnavigator.getNavigationStack();
    List<int> toRemove = [];

    dynamicPages.forEach((index, page) {
      if (!stackIndices.contains(index) && index != currentIndex.value) {
        toRemove.add(index);
      }
    });

    for (int index in toRemove) {
      removeDynamicPage(index);
    }
  }

  // Handle back navigation
  void handleBack() {
    Clinicappnavigator.back();
  }

  // Check if current page can go back
  bool canGoBack() {
    return Clinicappnavigator.canGoBack() || currentIndex.value != 1;
  }

  @override
  void onClose() {
    notchBottomBarController.dispose();
    Clinicappnavigator.clearStack();
    super.onClose();
  }

  String getTitleForCurrentIndex() {
    return pageTitles[currentIndex.value] ?? 'PUPPAL';
  }
}
