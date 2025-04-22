import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
