import 'package:flutter/material.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/conversation.dart';
import 'package:worcadeflutter/new_conversation.dart';
import 'package:worcadeflutter/login.dart';
import 'package:worcadeflutter/model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

void main() {
  firebaseMessaging.requestNotificationPermissions();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worcade',
      theme: ThemeData(
        // This is the theme of your application.
        primaryColor: Color.fromARGB(255, 60, 127, 186),
        primaryColorLight: Color.fromARGB(255, 230, 230, 230),
        secondaryHeaderColor: Color.fromARGB(255, 0, 165, 204),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: checkStoredApiKey(), builder: _buildFirstPage);
  }

  Widget _buildFirstPage(
      BuildContext context, AsyncSnapshot<Reference> snapshot) {
    if (snapshot.hasData) {
      firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            print("onMessage: $message");
          },
          onLaunch: (Map<String, dynamic> message) async {
            print("onLaunch: $message");
          },
          onResume: (Map<String, dynamic> message) async {
            print("onResume: $message");
          },
      );
      firebaseMessaging.getToken().then((String token) {
        print('Token $token');
      });
      return openConversationList(context, ConversationListQuery.all);
    }
    if (snapshot.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text('Login to Worcade')),
        body: LoginPage(),
      );
    }
    return Scaffold(
        body: Container(
            child: CircularProgressIndicator(), alignment: Alignment.center));
  }
}

Widget scaffold(BuildContext context, String title,
    {@required Widget body, Widget appBarButton}) {
  return Scaffold(
      appBar: AppBar(
        leading: appBarButton, // defaults to drawer button
        title: Text(title),
      ),
      drawer: Drawer(child: _buildDrawer(context)),
      body: body);
}

Widget _buildDrawer(BuildContext context) {
  Future<Widget> _navigate(ConversationListQuery query) {
    // pop drawer route so 'back' goes to the previous
    // conversation or list, not the drawer
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<Widget>(
            builder: (context) => openConversationList(context, query)),
        (route) => false);
  }

  return ListView(
    children: <Widget>[
      FutureBuilder(future: getMyUser(), builder: _buildUserProfile),
      ListTile(
        leading: Icon(Icons.add),
        title: Text('Start new chat'),
        onTap: () => Navigator.push(
            context, MaterialPageRoute<Widget>(builder: openNewConversation)),
      ),
      ListTile(
        leading: Icon(Icons.chat),
        title: Text('All conversations'),
        onTap: () => _navigate(ConversationListQuery.all),
      ),
      ListTile(
        leading: Icon(Icons.build),
        title: Text('Assigned to me'),
        onTap: () => _navigate(ConversationListQuery.assignedToMe),
      ),
      ListTile(
        leading: Icon(Icons.play_circle_outline),
        title: Text('Reported by me'),
        onTap: () => _navigate(ConversationListQuery.reportedByMe),
      ),
    ],
  );
}

Widget _buildUserProfile(BuildContext context, AsyncSnapshot<User> snapshot) {
  if (snapshot.hasData) {
    return ListTile(
      leading: ClipRRect(
        child: Image.network(
          snapshot.data.picture,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(const Radius.circular(15)),
      ),
      title: Text(snapshot.data.name),
      subtitle: Text(snapshot.data.company),
    );
  }
  if (snapshot.hasError) {
    throw snapshot.error;
  }
  return CircularProgressIndicator();
}
