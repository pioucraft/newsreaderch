import 'dart:convert';
import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'package:url_launcher/url_launcher.dart';

import "./newspapers/french.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> jsonData = {};
  List<bool>? interests;
  String? language;
  List<dynamic> finalFeed = [];
  bool isRSSLoaded = false;

  
  @override
  void initState() {
    super.initState();
    loadJsonData();
    getLanguage();
    makeRSS();
    getInterests();
  }

  Future<void> loadJsonData() async {
   var jsonString = await rootBundle.loadString('assets/homePage.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    setState(() {
      jsonData = data;
    });
  }

  Future<void> getLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    language = prefs.getString("language");
  }

  Future<void> getInterests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String inputString = prefs.getString("interests")!;
    List<dynamic> parsedList = jsonDecode(inputString);
    interests = parsedList.map((value) => value as bool).toList();
  }

  Future<void> makeRSS() async {
    List<dynamic> rtsFeed = [];
    for(var item in (await makeRTS())) {
      if(item["interestsIDs"].toString() == "[]") {
        rtsFeed.add(item);
      }
      for(var interest in item["interestsIDs"]) {
        if(interests![interest] == true) {
          if(rtsFeed.contains(item) == false) {
            rtsFeed.add(item);
          }
        }
      }
    }
    var temporaryFinalFeed = rtsFeed;
    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
    
    List<dynamic> blickFeed = [];
    for(var item in (await makeBlick())) {
      if(item["interestsIDs"].toString() == "[]") {
        blickFeed.add(item);
      }
      for(var interest in item["interestsIDs"]) {
        if(interests![interest] == true) {
          if(blickFeed.contains(item) == false) {
            blickFeed.add(item);
          }
        }
      }
    }
    temporaryFinalFeed.addAll(blickFeed);
    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
    

    List<dynamic> leTempsFeed = [];
    for(var item in (await makeLeTemps(interests!))) {
      if(item["interestsIDs"].toString() == "[]") {
        leTempsFeed.add(item);
      }
      for(var interest in item["interestsIDs"]) {
        if(interests![interest] == true) {
          if(leTempsFeed.contains(item) == false) {
            leTempsFeed.add(item);
          }
        }
      }
    }
    temporaryFinalFeed.addAll(leTempsFeed);
    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
    


    List<dynamic> tdgFeed = await makeTdg(interests!);
    temporaryFinalFeed.addAll(tdgFeed);
    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
    List<dynamic> heures24Feed = await make24Heures(interests!);
    temporaryFinalFeed.addAll(heures24Feed);
    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
    List<dynamic> leMatinFeed = await makeLeMatin(interests!);
    temporaryFinalFeed.addAll(leMatinFeed);

    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
    List<dynamic> minutes20Feed = await make20Minutes(interests!);
    temporaryFinalFeed.addAll(minutes20Feed);

    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(temporaryFinalFeed)!;
      
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Swiss News Reader"),
      ),
      body: Center(
        child: Column(
          children: [
            if (isRSSLoaded)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: finalFeed.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: ElevatedButton(
                        onPressed: () {
                          _launchUrl(Uri.parse(finalFeed[index]["link"]));
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                finalFeed[index]["title"],
                                style: const TextStyle(fontSize: 18.0),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                "${finalFeed[index]['newspaper']} | Date : ${finalFeed[index]['localDate'].toString().split(".000")[0]}",
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                child: CachedNetworkImage(
                                  imageUrl: finalFeed[index]["image"],
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              Text(finalFeed[index]["description"]),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}



//all functions for feeds of each newspaper






//other functions
List? sortListByMilliDate(List? inputList) {
  inputList!.sort((a, b) {
    final int milliDateA = a["milliDate"];
    final int milliDateB = b["milliDate"];
    return milliDateB.compareTo(milliDateA);
  });
  return inputList;
}

