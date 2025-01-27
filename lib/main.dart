import 'package:btc_graph/pages/dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTC dashboard',
      // themeMode: ThemeMode.dark,
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.deepPurple,
      //     brightness: Brightness.dark,
      //   ),
      //   useMaterial3: true,
      // ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const Dashboard(),
    );
  }
}
