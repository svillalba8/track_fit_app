import 'package:flutter/material.dart';
import '../../core/navigation/navigation_widget.dart';

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('por implementar')),
      bottomNavigationBar: NavigationWidget.customBottonNavigationBar(
        context,
        2,
      ),
    );
  }
}
