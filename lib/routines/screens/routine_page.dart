import 'package:flutter/material.dart';
import '../../navigation/navigation_widget.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('por implementar'),
      ),
      bottomNavigationBar: NavigationWidget.customBottonNavigationBar(
        context,
        1,
      ),
    );
  }
}
