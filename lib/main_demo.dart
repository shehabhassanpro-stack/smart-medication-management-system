import 'package:flutter/material.dart';
import 'examples/responsive_demo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Care - Level 3 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      home: const ResponsiveDemoScreen(),
    );
  }
}
