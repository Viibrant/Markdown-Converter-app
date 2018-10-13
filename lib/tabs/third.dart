import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:markdownconverter/getter/communicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:validator/validator.dart';

String url = '';
String contents = '';
TextEditingController _controller = new TextEditingController();

class Third extends StatefulWidget {
  const Third({ Key key }) : super(key: key);
  @override
  _ThirdState createState() => new _ThirdState();
}
   
awaitResult (Future<String> string) async {
  return(await(string));
}


  

class _ThirdState extends State<Third> with WidgetsBindingObserver {
  StreamSubscription _intentSubscription;

  
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
    print(state);
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      if (_intentSubscription != null) {
        _intentSubscription.cancel();
        break;
      }
      break;
      case AppLifecycleState.suspending:
      case AppLifecycleState.resumed: {
      debugPrint("Resumed!");
      _intentSubscription = stream.receiveBroadcastStream().listen(
        (received) {
          debugPrint("Received $received");
          setState(() {
            url = received;  
            _controller.text = url;
            convertToMD();
          });
      });
      }
    }
  }


  markdownBoi() {
    return new Expanded(child: 
    new Markdown(
      data: contents,
    ));
  }

  saveToFile(filename) {
    debugPrint(url);
    if (url != '' || isURL(url) == true) {
      SimplePermissions.requestPermission(Permission.WriteExternalStorage).then((validation){
        if (validation == true) {
        Getter.showSnackbar(context, "Saving...");
        getExternalStorageDirectory().then((location) {
          new Directory(location.path+"/markdown").create(recursive: true)
            .then((Directory directory){
              debugPrint(filename+".md");
              new File(
                directory.path+"/"+filename+".md")
                .writeAsString(contents);
                Getter.showSnackbar(context, "Saved!");
            }).catchError((err) => Getter.errHandler(context, err));
        });
        } else {Getter.errHandler(context, "I");}
      });
      
    } else {Getter.errHandler(context, "Not a valid url");}
  }

  convertToMD () async {
    if (url != ''){
      Getter.showSnackbar(context, "Converting ...");
      url = url.replaceAll(" ", '').replaceAll("  ", '');
      print('Sending "$url"');
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await http.read(
          (url.contains("http") == false || url.contains("https") == false)
          ? new Uri.https(url, "")
          : url)
        .timeout(const Duration(seconds: 10), 
          onTimeout: () => Getter.errHandler(context, "Network Error!"))
        .then((contents) {
          return Getter.getMarkdown(contents);  
        }).catchError((err) => Getter.errHandler(context, err))
        .then((value){
          setState(() {
            contents = value;
          });
        }).catchError((err) => 
          Getter.errHandler(context, "An error occurred! (malformed URL?)"));
      } catch (e) {
        print(e);
      }  
    }
  }
  
  clearStuff() {
    Getter.showSnackbar(context, "Clearing...");
    print("Clearing");
    setState(() {
      url = ''; contents = '';
      _controller.clear();                    
    });
  }

  exportToFile() {
    TextEditingController urlController = new TextEditingController();
    String filename;
    url.contains("https") ? filename = url.replaceAll("https://", '') : filename = url.replaceAll("http://", '');
    urlController.text = filename;
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Rewind and remember'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: "Filename",
                    hintText: "Enter a filename",
                  ),
                  onChanged: (String value) {
                    if (value != ''){
                      setState(() {
                        filename = value;                        
                      });
                    }
                  }
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                saveToFile(filename);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: const Color(0xfffffafa),
      child: new Column( 
          children: <Widget>[            
            new Card( 
              color: const Color(0xff080808),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                leading: const Icon(Icons.work),
                title: const Text('URL To Markdown'),
              ),
                new Padding(
                  padding: new EdgeInsets.all(8.0),
                  child: Center(
                    child: new TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "URL",
                        hintText: "Enter a URL",
                      ),
                      onChanged: (String value) {
                        if (value != ''){
                          setState(() {
                            url = value;                        
                          });
                        }
                      }
                    ),
                  )),
                new ButtonTheme.bar( 
                  child: new ButtonBar( 
                    children: <Widget>[
                      new FlatButton(
                        child: const Text('Clear'),
                        onPressed: () => clearStuff()
                      ),
                      new FlatButton(
                        child: const Text('Convert'),
                        onPressed: () => convertToMD()
                      ),
                      new FlatButton(
                        child: const Text('Export to file'),
                        onPressed: () => exportToFile()
                      ),
                    ],
                  ),
                ),
              ], 
            ),
          ),
          markdownBoi(),
        ],
      )
    );
  } 
} 