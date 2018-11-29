import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        child: FutureBuilder(
            future: getConversationList(), builder: _buildConversationList),
      ),
    );
  }

  Widget _buildConversationList(
      BuildContext context, AsyncSnapshot<List<Conversation>> snapshot) {
    if (snapshot.hasData) {
      var widgets = <Widget>[];
      for (var value in snapshot.data) {
        widgets.add(GestureDetector(
          child: _buildListTile(context, value),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute<Widget>(
                  builder: (context) => _openConversation(value.id))),
        ));
      }
      return ListView(
        children: widgets,
      );
    }
    if (snapshot.hasError) {
      throw snapshot.error;
    }
    return CircularProgressIndicator();
  }

  Widget _openConversation(String id) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
            child: FutureBuilder(
              future: getConversation(id),
              builder: _buildConversation,
            ),
            alignment: Alignment.center,
            margin: EdgeInsets.all(10)));
  }

  Widget _buildConversation(
      BuildContext context, AsyncSnapshot<Conversation> snapshot) {
    if (snapshot.hasData) {
      return Column(children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              Text(snapshot.data.number,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                  child: Text(
                ' ${snapshot.data.name}',
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          padding: EdgeInsets.only(bottom: 5),
        ),
        Expanded(
          child: ListView(
              reverse: true,
              children: snapshot.data.content
                  .map((c) => ContentWidget(entry: c))
                  .toList()
                  .reversed
                  .toList()),
        )
      ]);
    }
    if (snapshot.hasError) {
      throw snapshot.error;
    }
    return CircularProgressIndicator();
  }

  final _dateFormatter = DateFormat('dd MMM', 'en_US');
  final _timeFormatter = DateFormat('HH:mm', 'en_US');
  Widget _buildListTile(BuildContext context, Conversation value) {
    var now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);
    var today = midnight.isBefore(value.modified);
    return Container(
      child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Text(
              '${value.number} ${value.name}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: value.read ? FontWeight.normal : FontWeight.bold),
            )),
            Text((today ? _timeFormatter : _dateFormatter)
                .format(value.modified))
          ],
        ),
        Row(
          children: _buildListSubtitle(context, value),
        ),
      ]),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).primaryColor))),
    );
  }

  List<Widget> _buildListSubtitle(BuildContext context, Conversation value) {
    var result = <Widget>[];
    if (value.reporter != null) {
      if (value.assignee != null && value.assignee.id == value.reporter.id) {
        result.add(FutureBuilder(
            future: getUser(value.reporter.id),
            builder: (context, AsyncSnapshot<Sender> snapshot) =>
                _buildReporter(context, snapshot,
                    [Icons.play_circle_outline, Icons.build])));
      } else {
        result.add(FutureBuilder(
            future: getUser(value.reporter.id),
            builder: (context, AsyncSnapshot<Sender> snapshot) =>
                _buildReporter(
                    context, snapshot, [Icons.play_circle_outline])));
      }
    }
    if (value.assignee != null &&
        (value.reporter == null || value.reporter.id != value.assignee.id)) {
      result.add(FutureBuilder(
          future: getUser(value.assignee.id),
          builder: (context, AsyncSnapshot<Sender> snapshot) =>
              _buildReporter(context, snapshot, [Icons.build])));
    }
    return result;
  }

  Widget _buildReporter(BuildContext context, AsyncSnapshot<Sender> snapshot,
      List<IconData> icons) {
    if (snapshot.hasData) {
      var children = <Widget>[];
      for (var value in icons) {
        children.add(Icon(value));
      }
      children.add(Text(snapshot.data.name));
      return Container(
        child: Row(
          children: children,
        ),
      );
    }
    if (snapshot.hasError) {
      throw snapshot.error;
    }
    return Text('...');
  }
}
