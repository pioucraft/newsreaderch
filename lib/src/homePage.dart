import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';  
import 'package:url_launcher/url_launcher.dart';

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
    List<dynamic> rtsFeed = await makeRTS();
    List<dynamic> blickFeed = await makeBlick();
    List<dynamic> tdgFeed = await makeTdg(interests!);
    var temporaryFinalFeed = rtsFeed;
    temporaryFinalFeed.addAll(blickFeed);
    temporaryFinalFeed.addAll(tdgFeed);


    for(var item in temporaryFinalFeed) {
      if(item["interestsIDs"].toString() == "[]") {
        finalFeed.add(item);
      }
      for(var interest in item["interestsIDs"]) {
        if(interests![interest] == true) {
          if(finalFeed.contains(item) == false) {
            finalFeed.add(item);
          }
        }
      }
    }
    setState(() {
      isRSSLoaded = true; 
      finalFeed = sortListByMilliDate(finalFeed)!;
    });
  }





  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Swiss News Reader"),
      ),
      body: Center(child:
        SingleChildScrollView(child:
          Padding(padding: const EdgeInsets.only(top: 20.0, bottom: 18.0), child: 
            Column(children: [
              Padding(padding: const EdgeInsets.all(16.0), child: 
                Text(jsonData["welcome"][language]!, style: const TextStyle(fontSize: 20.0), textAlign: TextAlign.center)
              ),
              if(isRSSLoaded) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for(var item in finalFeed) Padding(padding: const EdgeInsets.all(16.0),child: 
                  ElevatedButton(onPressed: () => {_launchUrl(Uri.parse(item["link"]))}, style: ElevatedButton.styleFrom(foregroundColor: Colors.black, shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  ),), child: 
                    Padding(padding: const EdgeInsets.only(top: 5.0, bottom: 5.0), child: 
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item["title"], style: const TextStyle(fontSize: 18.0), textAlign: TextAlign.left),
                        Text("${item['newspaper']} | Date : ${item['localDate'].toString().split(".000")[0]}"),
                        Padding(padding: const EdgeInsets.only(top: 5.0, bottom: 5.0), child: 
                          Image.network(item["image"])
                        ),
                        Text(item["description"]),
                      ])
                    ,)
                    
                  )
                
                )
              ],)
            ])
          )
        )
      )
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}



//all functions for feeds of each newspaper


Future<List<dynamic>> makeRTS() async {
  final client = http.Client();
  List<dynamic> returnStatement = [];
  var response = await client.get(Uri.parse('https://www.rts.ch/info/?format=rss/news'));
  var channel = RssFeed.parse(response.body);
  
  for(var i = 0; i < channel.items.length; i++) {
    try {
      var newspaper = "RTS";
      var title = channel.items[i].title!;
      var description = channel.items[i].description!.split("<p>")[1].split("</p>")[0];
      var image = channel.items[i].description!.split("src=\"")[1].split("?w=")[0];
      var link = channel.items[i].link!;
      var interestsIDs = [];
      if(link.contains("/info/suisse/")) {
        interestsIDs = [0];
      } else if(link.contains("/info/monde/")) interestsIDs = [1];
      else if(link.contains("/info/economie/")) interestsIDs = [2];
      else if(link.contains("/fr/news/tech/")) interestsIDs = [3, 4];
      else if(link.contains("/fr/sport/")) interestsIDs = [5];
      else if(link.contains("/info/regions/geneve/")) interestsIDs = [6];
      else if(link.contains("/info/regions/vaud/")) interestsIDs = [7];
      else if(link.contains("/info/regions/fribourg/")) interestsIDs = [8];
      else if(link.contains("/info/regions/neuchatel/")) interestsIDs = [9];
      else if(link.contains("/info/regions/valais/")) interestsIDs = [10];
      else if(link.contains("/info/regions/jura/")) interestsIDs = [11];
      else if(link.contains("/info/regions/berne/")) interestsIDs = [12];
      else if(link.contains("/info/culture/")) interestsIDs = [13];

      //all the things about date
      var pubdate = channel.items[i].pubDate!;
      DateTime gmtDate = HttpDate.parse(pubdate);

      // Convert the GMT date to local date
      DateTime parsedDate= gmtDate.toLocal();
      int millisecondsSinceEpoch = parsedDate.millisecondsSinceEpoch;
      returnStatement.add({"title": title, "newspaper": newspaper, "description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
    }
    catch(err) {
      print(err);
    }
  }
    
  return returnStatement;
}

Future<List<dynamic>> makeBlick() async {
  final client = http.Client();
  List<dynamic> returnStatement = [];
  var response = await client.get(Uri.parse('https://www.blick.ch/fr/news/rss.xml'));
  var channel = RssFeed.parse(response.body);
  
  for(var i = 0; i < channel.items.length; i++) {
    try {
      var newspaper = "Blick";
      var title = fixSpecialChars(channel.items[i].title!);
      var description = fixSpecialChars(channel.items[i].description!.split("/> ")[1]);
      var image = channel.items[i].description!.split("src=\"")[1].split("\" />")[0];
      var link = channel.items[i].link!;
      var interestsIDs = [];
      if(link.contains("/fr/news/suisse/")) {
        interestsIDs = [0];
      } else if(link.contains("/fr/news/monde/") || link.contains("/fr/news/france/")) interestsIDs = [1];
      else if(link.contains("/fr/news/economie/")) interestsIDs = [2];
      else if(link.contains("/info/sciences-tech/")) interestsIDs = [3];
      else if(link.contains("/info/sciences-tech/")) interestsIDs = [4];
      else if(link.contains("/sport/")) interestsIDs = [5];
      else if(link.contains("/fr/pop-culture/")) interestsIDs = [13];
      else if(link.contains("/fr/news/opinion/")) interestsIDs = [14];
      else if(link.contains("/fr/life/")) interestsIDs = [15];
      else if(link.contains("/fr/food/")) interestsIDs = [16];

      //all the things about date
      var pubdate = channel.items[i].pubDate!;
      DateTime gmtDate = HttpDate.parse(pubdate);

      // Convert the GMT date to local date
      DateTime parsedDate= gmtDate.toLocal();
      int millisecondsSinceEpoch = parsedDate.millisecondsSinceEpoch;
      returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
    }
    catch(err) {
      print(err);
    }
  }
    
  return returnStatement;
}

Future<List<dynamic>> makeTdg(List<bool> interests) async {
  final client = http.Client();
  List<dynamic> returnStatement = [];
  List<Map> urlsTdg = [{"interests": [0], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/suisse"}, {"interests": [1], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/monde"}, {"interests": [2], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/economie"}, {"interests": [3], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/savoirs/sciences"}, {"interests": [4], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/savoirs/technologie"}, {"interests": [5], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/sports"}, {"interests": [6], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/geneve"}, {"interests": [13], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/culture"}, {"interests": [14], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/opinion"}, {"interests": [16], "url": "https://partner-feeds.publishing.tamedia.ch/rss/tdg/gastronomie"}];
  for(var urlTdg in urlsTdg) {
    if(interests[urlTdg["interests"][0]] == true) {
      var response = await client.get(Uri.parse(urlTdg["url"]));
      var channel = RssFeed.parse(response.body);
      try {
        for(var j = 0; j < channel.items.length; j++) {
          try {
            var newspaper = "Tribune De Genève";
            var title = channel.items[j].title!;
            var description = channel.items[j].description!;
            var image = channel.items[j].enclosure!.url!.split("?")[0];
            var link = channel.items[j].link!;
            var interestsIDs = [];

            //all the things about date
            var pubdate = channel.items[j].pubDate!;
            DateTime gmtDate = DateTime.parse(pubdate);

            // Convert the GMT date to local date
            DateTime parsedDate= gmtDate.toLocal();
            int millisecondsSinceEpoch = parsedDate.millisecondsSinceEpoch;
            returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
          }
          catch(err) {
            print(err);
          }
        }
      }
      catch(err) {
        print(err);
      }
    }
    
  }
  return returnStatement;
}



//other functions
List? sortListByMilliDate(List? inputList) {
  inputList!.sort((a, b) {
    final int milliDateA = a["milliDate"];
    final int milliDateB = b["milliDate"];
    return milliDateB.compareTo(milliDateA);
  });
  return inputList;
}

String fixSpecialChars(String str) {
  return utf8.decode(str.runes.toList());
}
