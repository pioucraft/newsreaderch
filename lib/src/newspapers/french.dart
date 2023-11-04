import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';  

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
      else if(link.contains("/info/sciences-tech/")) interestsIDs = [3, 4];
      else if(link.contains("/sport/")) interestsIDs = [5];
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
      if(link.contains("/fr/news/suisse/"))interestsIDs = [0]; 
      else if(link.contains("/fr/news/monde/") || link.contains("/fr/news/france/")) interestsIDs = [1];
      else if(link.contains("/fr/news/economie/")) interestsIDs = [2];
      else if(link.contains("/fr/news/tech/")) interestsIDs = [3, 4];
      else if(link.contains("/fr/sport/")) interestsIDs = [5];
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

Future<List<dynamic>> makeLeTemps(List<bool> interests) async {
  final client = http.Client();
  var alreadyArticles = [];
  List<dynamic> returnStatement = [];
  List<Map> urlsLeTemps = [{"interests": [0], "url": "https://www.letemps.ch/suisse.rss"}, {"interests": [1], "url": "https://www.letemps.ch/monde.rss"}, {"interests": [2], "url": "https://www.letemps.ch/economie.rss"}, {"interests": [3], "url": "https://www.letemps.ch/sciences.rss"}, {"interests": [5], "url": "https://www.letemps.ch/sport.rss"}, {"interests": [15], "url": "https://www.letemps.ch/culture.rss"}, {"interests": [16], "url": "https://www.letemps.ch/opinions.rss"}];
  for(var urlLeTemps in urlsLeTemps) {
    if(interests[urlLeTemps["interests"][0]] == true) {
      var response = await client.get(Uri.parse(urlLeTemps["url"]));
      var channel = RssFeed.parse(response.body);
      try {
        for(var j = 0; j < channel.items.length; j++) {
          try {
            var newspaper = "Le Temps";
            var title = channel.items[j].title!;
            var description = channel.items[j].description!.split("<p>")[1].split("</p>")[0];
            var image = channel.items[j].description!.split("src=\"")[1].split("\"")[0];
            var link = channel.items[j].link!;
            var interestsIDs = [];

            //all the things about date
            var pubdate = channel.items[j].pubDate!;
            DateTime gmtDate = DateFormat("E, d MMM y H:m:s Z").parse(pubdate);

            // Convert the GMT date to local date
            DateTime parsedDate = gmtDate.toLocal();
            int millisecondsSinceEpoch = parsedDate.millisecondsSinceEpoch;
            if(!alreadyArticles.contains(link)) {
              returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
              alreadyArticles.add(link);
            }
            
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

Future<List<dynamic>> makeTdg(List<bool> interests) async {
  final client = http.Client();
  var alreadyArticles = [];
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
            if(!alreadyArticles.contains(link)) {
              returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
              alreadyArticles.add(link);
            }
            
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

Future<List<dynamic>> make24Heures(List<bool> interests) async {
  final client = http.Client();
  var alreadyArticles = [];
  List<dynamic> returnStatement = [];
  List<Map> urls24Heures = [{"interests": [0], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/suisse"}, {"interests": [1], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/monde"}, {"interests": [2], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/economie"}, {"interests": [3], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/savoirs/sciences"}, {"interests": [4], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/savoirs/technologie"}, {"interests": [5], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/sports"}, {"interests": [7], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/vaud-regions/"}, {"interests": [13], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/culture"}, {"interests": [14], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/opinion"}, {"interests": [16], "url": "https://partner-feeds.publishing.tamedia.ch/rss/24heures/gastronomie"}];
  for(var url24Heures in urls24Heures) {
    if(interests[url24Heures["interests"][0]] == true) {
      var response = await client.get(Uri.parse(url24Heures["url"]));
      var channel = RssFeed.parse(response.body);
      try {
        for(var j = 0; j < channel.items.length; j++) {
          try {
            var newspaper = "24 Heures";
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
            if(!alreadyArticles.contains(link)) {
              returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
              alreadyArticles.add(link);
            }
            
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

Future<List<dynamic>> makeLeMatin(List<bool> interests) async {
  final client = http.Client();
  var alreadyArticles = [];
  List<dynamic> returnStatement = [];
  List<Map> urlsLeMatin = [{"interests": [0], "url": "https://partner-feeds.lematin.ch/rss/lematin/suisse"}, {"interests": [1], "url": "https://partner-feeds.lematin.ch/rss/lematin/monde"}, {"interests": [2], "url": "https://partner-feeds.lematin.ch/rss/lematin/economie"}, {"interests": [4], "url": "https://partner-feeds.lematin.ch/rss/lematin/hightech"}, {"interests": [5], "url": "https://partner-feeds.lematin.ch/rss/lematin/sports"}, {"interests": [16], "url": "https://partner-feeds.lematin.ch/rss/lematin/bienmanger"}];
  for(var urlLeMatin in urlsLeMatin) {
    if(interests[urlLeMatin["interests"][0]] == true) {
      var response = await client.get(Uri.parse(urlLeMatin["url"]));
      var channel = RssFeed.parse(response.body);
      try {
        for(var j = 0; j < channel.items.length; j++) {
          try {
            var newspaper = "Le Matin";
            var title = channel.items[j].title!;
            var description = channel.items[j].description!;
            var image = channel.items[j].enclosure!.url!.split("?")[0];
            var link = channel.items[j].link!;
            var interestsIDs = [];

            //all the things about date
            var pubdate = channel.items[j].pubDate!;
            DateTime gmtDate = HttpDate.parse(pubdate);

            // Convert the GMT date to local date
            DateTime parsedDate= gmtDate.toLocal();
            int millisecondsSinceEpoch = parsedDate.millisecondsSinceEpoch;
            if(!alreadyArticles.contains(link)) {
              returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
              alreadyArticles.add(link);
            }
            
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

Future<List<dynamic>> make20Minutes(List<bool> interests) async {
  final client = http.Client();
  var alreadyArticles = [];
  List<dynamic> returnStatement = [];
  List<Map> urls20Minutes = [{"interests": [0], "url": "https://partner-feeds.20min.ch/rss/20minutes/suisse"}, {"interests": [1], "url": "https://partner-feeds.20min.ch/rss/20minutes/monde"}, {"interests": [2], "url": "https://partner-feeds.20min.ch/rss/20minutes/economie"}, {"interests": [3], "url": "https://partner-feeds.20min.ch/rss/20minutes/science-et-nature"}, {"interests": [4], "url": "https://partner-feeds.20min.ch/rss/20minutes/hi-tech"}, {"interests": [5], "url": "https://partner-feeds.20min.ch/rss/20minutes/sports"}, {"interests": [16], "url": "https://partner-feeds.20min.ch/rss/20minutes/cuisiner"}];
  for(var url20Minutes in urls20Minutes) {
    if(interests[url20Minutes["interests"][0]] == true) {
      var response = await client.get(Uri.parse(url20Minutes["url"]));
      var channel = RssFeed.parse(response.body);
      print(url20Minutes["interests"]);
      try {
        for(var j = 0; j < channel.items.length; j++) {
          try {
            var newspaper = "20 Minutes";
            var title = channel.items[j].title!;
            var description = channel.items[j].description!;
            var image = channel.items[j].enclosure!.url!.split("?")[0];
            var link = channel.items[j].link!;
            var interestsIDs = [];

            //all the things about date
            var pubdate = channel.items[j].pubDate!;
            DateTime gmtDate = HttpDate.parse(pubdate);

            // Convert the GMT date to local date
            DateTime parsedDate= gmtDate.toLocal();
            int millisecondsSinceEpoch = parsedDate.millisecondsSinceEpoch;
            if(!alreadyArticles.contains(link)) {
              returnStatement.add({"title": title, "newspaper": newspaper,"description": description, "image": image, "link": link, "interestsIDs": interestsIDs, "localDate": parsedDate, "milliDate": millisecondsSinceEpoch}); 
              alreadyArticles.add(link);
            }
            
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



String fixSpecialChars(String str) {
  return utf8.decode(str.runes.toList());
}