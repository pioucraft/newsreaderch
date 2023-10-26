import 'package:flutter/material.dart';
import 'package:newsreaderch/src/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './src/selectLanguage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? inputString = prefs.getString("interests");
  final showLanguageSelection = inputString == null;
  runApp(MyApp(condition: showLanguageSelection));
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
      home: condition ? const SelectLanguage(title: 'Swiss News Reader') : const HomePage(),
    );
  }
}