import 'dart:async';

import 'package:flutter/material.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/content.dart';
import 'package:worcadeflutter/model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Worcade',
      theme: new ThemeData(
        // This is the theme of your application.
        primaryColor: Color.fromARGB(255, 60, 127, 186),
        primaryColorLight: Color.fromARGB(255, 230, 230, 230),
        secondaryHeaderColor: Color.fromARGB(255, 0, 165, 204),
      ),
      home: new MyHomePage(title: 'Worcade chat'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: Container(
          child: FutureBuilder(
            future: _conversation(),
            builder: _buildConversation,
          ),
          alignment: Alignment.center,
          margin: EdgeInsets.all(10)),
    );
  }

  Widget _buildConversation(
      BuildContext context, AsyncSnapshot<Conversation> snapshot) {
    if (snapshot.hasData) {
      return Column(children: <Widget>[
        Container(child: Row(
          children: <Widget>[
            Text(snapshot.data.number,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Expanded(child: Text(' ${snapshot.data.name}',
              style: TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),padding: EdgeInsets.only(bottom: 5),),
        Expanded(
          child: ListView(
              children: snapshot.data.content
                  .map((c) => ContentWidget(content: c))
                  .toList()),
        )
      ]);
    }
    if (snapshot.hasError) {
      throw snapshot.error;
    }
    return CircularProgressIndicator();
  }

  Future<Conversation> _conversation() =>
      getConversation('ed0c2ace-f024-4af6-b621-7ee4e2c19c32');
}
