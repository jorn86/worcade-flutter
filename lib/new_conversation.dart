import 'package:flutter/material.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/conversation.dart';
import 'package:worcadeflutter/main.dart';

Widget openNewConversation(BuildContext context) {
  return scaffold(context, 'New chat',
      body: NewConversationPage(), appBarButton: BackButton());
}

class NewConversationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewConversationState();
  }
}

class NewConversationState extends State<NewConversationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name;

  void _submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      createConversation(name).then((result) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute<Widget>(
                builder: (context) => openConversation(context, result.id)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                  hintText: 'What is going on?', labelText: 'Chat subject'),
              validator: (value) =>
                  value == null || value == '' ? 'Required' : null,
              onSaved: (value) => this.name = value,
            ),
            RaisedButton(
              onPressed: _submit,
              child: Text('Start chat'),
            )
          ])),
    );
  }
}
