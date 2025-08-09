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

  @override
  void onInit() {
    super.onInit();

    // Initialize default titles
    pageTitles.addAll({
      0: 'คำขอฉีดวัคซีน',
      1: 'PUPPAL',
      2: 'การแจ้งเตือน',
      3: 'หมอ',
      4: 'ประวัติการฉีดวัคซีน',
      5: 'ตั้งค่า',
    });
  }

  // Navigate to a specific page
  void navigateToPage(int index, {Map<String, dynamic>? params}) {
    currentIndex.value = index;

    // Store parameters if provided
    if (params != null) {
      pageParameters.clear();
      pageParameters.addAll(params);
    }

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
    // Simple cleanup without animation controller disposal issues
    Clinicappnavigator.clearStack();
    super.onClose();
  }

  String getTitleForCurrentIndex() {
    return pageTitles[currentIndex.value] ?? 'PUPPAL';
  }
}
