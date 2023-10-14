import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Map<String, dynamic> jsonData = {};
  String? language;

  @override
  void initState() {
    super.initState();
    loadJsonData();
    getLanguage();
  }

  Future<void> loadJsonData() async {
    final String jsonString = await rootBundle.loadString('assets/login.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    setState(() {
      jsonData = data;
    });
  }

  Future<void> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getString("language");
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(child: 
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), child:
              Column(children: [
                Text(jsonData["welcomeText"][language], style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),

              ],)
              
            )
          ])
        ),
    );
  }
}

