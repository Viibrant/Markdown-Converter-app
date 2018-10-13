import 'dart:async';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdownconverter/getter/communicator.dart';
import 'package:validator/validator.dart';


class First extends StatefulWidget {  
  const First({ Key key }) : super(key: key);
  @override
  _FirstState createState() => new _FirstState();
}
 
 
String text = '';
String url = '';
const stream = const EventChannel('app.channel.shared.data');
StreamSubscription _intentSubscription;

class _FirstState extends State<First> with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //setState(() {_notification = state; });
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      if (_intentSubscription != null) {
        _intentSubscription.cancel();
      }
      break;
      case AppLifecycleState.suspending:
      case AppLifecycleState.resumed: {
      debugPrint("Resumed!");
      _intentSubscription = stream.receiveBroadcastStream().listen(
        (received) {
          debugPrint("Received $received");
          if (isURL(received) == true){
            Getter.updateIntent(received).then((result){
              Map parsed = json.decode(result);
              url = parsed["url"];
              setState(() {
                text = parsed["markdown"];
              });
            });
          }
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
          children: <Widget>[            
          //   new Card( 
          //     child: new Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: <Widget>[
          //         const ListTile(
          //       leading: const Icon(Icons.work),
          //       title: const Text('Simple Markdown Viewer'),
          //     ),
          //       new Padding(
          //         padding: new EdgeInsets.all(8.0),
          //         child: Center(
          //         )),
          //       new ButtonTheme.bar( 
          //         child: new ButtonBar( 
          //           children: <Widget>[
          //             new FlatButton(
          //               child: const Text('Export to file'),
          //               onPressed: () {
          //                 if (url != '' || isURL(url) == true) {
          //                   Getter.showSnackbar(context, "Saving...");
          //                   getExternalStorageDirectory().then((location) {
          //                     new Directory(("$location/markdown")).create()
          //                       .then((Directory directory){
          //                         new File(formatDate(DateTime.now(), [yyyy, mm, dd])).writeAsString(text)
          //                           .then(Getter.showSnackbar(context, "Saved!"));
          //                       }).catchError((err) => Getter.errHandler(context, err));
          //                   });
          //                 } else {Getter.errHandler(context, "Not a valid url");}
          //               }
          //             ),
          //           ],
          //         ), 
          //       ),
          //     ], 
          //   ),
          // ),
          new Text("TO DO: CHOOSE AND DISPLAY MARKDOWN"),
          new Expanded(
            child: new Markdown(data: text)
          ),
        ],
      )
    ); 
  }
}
 