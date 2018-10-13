import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

const platform = const MethodChannel('app.channel.markdown.data');
const stream = const EventChannel('app.channel.shared.data');
class Getter {  
  static errHandler (context, var err) {
    print('catchError: $err');
    Getter.showSnackbar(context, 'Error: $err');
  }
  
  static updateIntent(sharedData) {
    debugPrint("Received $sharedData");
    getMarkdown(sharedData).then((markdown) {
      return '{"url":$sharedData,"markdown":$markdown';
    });
  }

  static Future<String> getMarkdown(String markdown) async {
    print('Invoking getMarkdown with "$markdown"');
    String result = await platform.invokeMethod('urltomarkdown', {"url": markdown});
    print('Result is "$result"'); 
    return result;
  }

  static showSnackbar(BuildContext context, String text) {
    return Scaffold.of(context)
     .showSnackBar(
       new SnackBar(
        content: new Text(text)
      )
    );                        
  }

}
 