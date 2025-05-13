import 'package:flutter/material.dart';

class NavigationService {
  static Future<void> navigateTo(
      BuildContext context, String routeName) async {
    await Navigator.pushNamed(context, routeName);
  }

  static Future<void> navigateToReplacement(
      BuildContext context, String routeName) async {
    await Navigator.pushReplacementNamed(context, routeName);
  }
}