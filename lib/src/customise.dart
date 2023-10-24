import 'dart:convert';
import 'dart:async';

import "homePage.dart";

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customise extends StatefulWidget {
  const Customise({super.key, required this.title});

  final String title;

  @override
  State<Customise> createState() => _CustomiseState();
}

class _CustomiseState extends State<Customise> {
  Map<String, dynamic> jsonData = {};
  String? language;
  List<bool> userInterests = [ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    loadJsonData();
    getLanguage();
  }

  Future<void> loadJsonData() async {
    final String jsonString = await rootBundle.loadString('assets/customise.json');
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
      body: SingleChildScrollView(child:
        Center(child: 
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), child:
              Column(children: [
                Text(jsonData["personalise"][language], style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
                Padding(padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0), child:
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        width: 10,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Text(jsonData["interests"][language], style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
                      Column(children: [

                        for(var interest in jsonData["interestsList"]) Padding(padding: const EdgeInsets.only(left: 20.0), child: 

                          Row(children: [      
                            Text(interest[language], style: const TextStyle(fontSize: 15),textAlign: TextAlign.center),
                            Checkbox(value: userInterests[jsonData["interestsList"].indexOf(interest)], onChanged: (newBool) {
                              setState(() {
                                userInterests[jsonData["interestsList"].indexOf(interest)] = newBool!;
                              });
                            })
                          ])
                        )
                      ])
                    ])
                  ),
                ),
                Padding(padding: const EdgeInsets.only(bottom: 20), child: 
                  ElevatedButton(onPressed: () async { 
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('interests', userInterests.toString());
                    String inputString = prefs.getString("interests")!;
                    List<dynamic> parsedList = jsonDecode(inputString);
                    List<bool> boolList = parsedList.map((value) => value as bool).toList();
                    print(boolList);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (Route<dynamic> route) => false,
                    );
                  }, child: Text(jsonData["next"][language]))
                )
                
              ],)
              
            )
          ])
        ),
      )
    );
  }
}

