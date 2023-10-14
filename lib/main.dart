import 'package:flutter/material.dart';

import './src/selectLanguage.dart';

void main() {
  const showLanguageSelection = true;
  runApp(const MyApp(condition: showLanguageSelection));
}

class MyApp extends StatelessWidget {
  final bool condition;

  const MyApp({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swiss News Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: condition ? const SelectLanguage(title: 'Swiss News Reader') : const SelectLanguage(title: "Not supposed to the SelectLanguage"),
    );
  }
}