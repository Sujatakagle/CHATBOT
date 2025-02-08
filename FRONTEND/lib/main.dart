import 'package:flutter/material.dart';
import 'help_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Help Center',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HelpCenterScreen(),
    );
  }
}
