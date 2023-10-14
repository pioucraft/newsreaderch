import 'dart:async';

import "login.dart";

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key, required this.title});

  final String title;

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  var listOfWelcomeTexts = [
    "Hello, please select your language to continue.            ‎",
    "Hallo, bitte wählen Sie Ihre Sprache um fortzufahren.      ‎",
    "Bonjour, veuillez sélectionner votre langue pour continuer.‎",
    "Salve, selezionare la lingua per continuare.               ‎",
    "Hallo, eleger Vossa lingua per cuntinuar.                  ‎"
  ];
  var selectedWelcomeTextNumber = 0;
  var _selectedWelcomeText =
      "Hello, please select your language to continue.";
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (selectedWelcomeTextNumber == 4) {
        selectedWelcomeTextNumber = -1;
      }
      ++selectedWelcomeTextNumber;
      setState(() {
        _selectedWelcomeText = listOfWelcomeTexts[selectedWelcomeTextNumber];
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center( child:
        Column(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 160.0, 16.0, 0), child: 
              AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: 
                Text(
                  _selectedWelcomeText,
                  key: ValueKey<int>(selectedWelcomeTextNumber),
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                )
              )
            ),
          ),
          Center(child: 
            Padding(padding: const EdgeInsets.fromLTRB(16.0, 160.0, 16.0, 0), child: 
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(padding: const EdgeInsets.all(5.0), child: 
                  ElevatedButton(
                    onPressed: () { 
                      alert(context, "Fehler", "Deutsch ist noch nicht verfügbar.");
                    },
                  child: const Text("De")
                  ),
                ),
                Padding(padding: const EdgeInsets.all(5.0), child: 
                  ElevatedButton(
                    onPressed: () async { 
                      const selectedLanguage = "fr";
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('language', selectedLanguage);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login(title: "Créer un compte",)),
                      );
                    },
                  child: const Text("Fr")
                  ),
                ),
                Padding(padding: const EdgeInsets.all(5.0), child: 
                  ElevatedButton(
                    onPressed: () { 
                      alert(context, "Errore", "L'italiano non è ancora disponibile.");
                    },
                  child: const Text("It")
                  ),
                ),
                Padding(padding: const EdgeInsets.all(5.0), child: 
                  ElevatedButton(
                    onPressed: () { 
                      alert(context, "Fehler", "Rumantsch n'è betg a disposiziun per in schatg.");
                    },
                  child: const Text("Rm")
                  )
                ),
                Padding(padding: const EdgeInsets.all(5.0), child: 
                
                  ElevatedButton(
                    onPressed: () async { 
                      const selectedLanguage = "en";
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('language', selectedLanguage);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login(title: "Create an account",)),
                      );
                    },
                  child: const Text("En")
                  ),
                ),
                
              ])

            )
          )
        ])
      )
    );
  }
}

void alert(BuildContext context, String title, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}