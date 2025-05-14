import 'package:flutter/material.dart';
import '../../widgets/navigation_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('por implementar'),
      ),
      bottomNavigationBar: NavigationWidget.customBottonNavigationBar(
        context,
        3,
      ),
    );
  }
}
