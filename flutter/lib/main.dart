import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'theme.dart';

void main() {
  runApp(RestlyApp());
}

class RestlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restly',
      theme: buildTheme(),
      home: HomeScreen(),
    );
  }
}
