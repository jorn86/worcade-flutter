import 'package:flutter/material.dart';
import 'package:worcadeflutter/content.dart';
import 'package:worcadeflutter/content_footer.dart';
import 'package:worcadeflutter/message.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'Flutteren Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: Container(
          child: ListView(children: [
            ContentWidget(
              content: Content(
                sourceName: 'Jorn',
                messages: [
                  Message('Hello there, Roel'),
                  Message('How are you?'),
                ],
                mine: false,
                footer: ContentFooter(
                    time: DateTime.now().subtract(Duration(minutes: 3)),
                    isRead: true),
              ),
            ),
            ContentWidget(
              content: Content(
                sourceName: 'Roel',
                messages: [
                  Message(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sed nulla mollis, scelerisque mi vel, dapibus libero. Sed laoreet risus id pellentesque vulputate. Cras cursus felis efficitur ante lobortis, eu elementum justo mattis. Cras tincidunt dui vestibulum, vehicula ligula eget, tristique turpis. Aliquam dictum accumsan lorem sed blandit. Curabitur sed libero blandit, ultrices augue sed, egestas nisl. Fusce ornare, ligula ut condimentum dapibus, nunc sem suscipit elit, ac facilisis magna lectus vitae neque. Ut sit amet laoreet elit. Nunc neque augue, ullamcorper tempus vehicula sed, auctor et mi. Quisque rhoncus lacinia libero, vel sagittis sem eleifend at. Curabitur feugiat aliquet massa, vitae vehicula enim commodo at.'),
                ],
                mine: true,
                footer: ContentFooter(
                    time: DateTime.now().subtract(Duration(seconds: 65)),
                    isRead: false),
              ),
            ),
            ContentWidget(
              content: Content(
                sourceName: 'Jorn',
                messages: [
                  Message(
                      'Vestibulum blandit libero sed nisl eleifend, vitae facilisis est rhoncus. Proin ut lacus non enim sodales sagittis. Praesent ultricies maximus purus ut feugiat. Duis sit amet enim ornare, sagittis nunc non, accumsan nunc. Phasellus sit amet feugiat neque. Mauris pharetra purus sed arcu rhoncus pretium. Fusce nisi urna, luctus sed erat vel, eleifend ullamcorper sem. Aliquam magna ipsum, consequat gravida mattis sagittis, mollis a ex. Nulla facilisi. Maecenas porttitor ligula dolor, sit amet efficitur enim laoreet ut. Sed finibus eu velit quis condimentum. Pellentesque eu purus vitae nisl sollicitudin aliquet nec ac massa. Mauris id massa non tortor semper vehicula. Aenean non lobortis nisi, vitae vulputate dolor. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;'),
                ],
                mine: false,
                footer: ContentFooter(time: DateTime.now(), isRead: false),
              ),
            ),
          ]),
          margin: EdgeInsets.symmetric(vertical: 10)),
    );
  }
}
