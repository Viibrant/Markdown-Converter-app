import 'package:flutter/material.dart';
import 'package:markdownconverter/tabs/first.dart';
import 'package:markdownconverter/tabs/third.dart';
void main() {
  runApp(new MaterialApp(
      title: "Markdown Converter",
      theme: ThemeData(
        textTheme: new TextTheme(
        body1: new TextStyle(color: const Color(0xffff1744)),
      ),
        brightness: Brightness.dark,
        accentColor: const Color(0xffff1744),
        primaryColor: Colors.redAccent[400],
      ),
      home: new MyHome()));
}

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => new MyHomeState();
}


class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  TabBar getTabBar() {
    return new TabBar(
      tabs: <Tab>[
        new Tab(
          icon: new Icon(Icons.web),
        ),

      ],
      controller: controller,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      children: tabs,
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("Markdown"),
            backgroundColor: Theme.of(context).accentColor,
            bottom: getTabBar()),
        body: getTabBarView(<Widget>[new Third()]));
  }
} 
