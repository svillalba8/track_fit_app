import 'package:flutter/material.dart';
import 'package:track_fit_app/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Espaciado alrededor del logo
          child: Image.asset(kLogoTrackFitBlancoMorado, fit: BoxFit.cover),
        ),
      ),
      body: Center(
        child: Text('Bienvenido a tu app fitness 👟'),
      ),
    );
  }
}
