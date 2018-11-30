import 'package:flutter/material.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/conversation.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = 'j+roel@worcade.com';
  String password = '12345678';

  void _submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      loginUser(email, password).then((result) {
        return Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<Widget>(
                builder: (context) =>
                    openConversationList(context, ConversationListQuery.all)), (result) => false);
      }, onError: ([Object error, StackTrace stacktrace]) {
        print('auth for $email failed with $error: $stacktrace');
        // TODO show error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: TextEditingController(text: this.email),
                  autocorrect: false,
                  autofocus: true,
                  decoration: InputDecoration(
                      hintText: 'you@company.com', labelText: 'E-mail address'),
                  onSaved: (value) {
                    this.email = value;
                  },
                ),
                TextFormField(
                  controller: TextEditingController(text: this.password),
                  decoration: InputDecoration(
                      hintText: 'Password', labelText: 'Password'),
                  obscureText: true,
                  autocorrect: false,
                  onSaved: (value) {
                    this.password = value;
                  },
                ),
                RaisedButton(
                  onPressed: () => _submit(),
                  child: Text('Log in'),
                )
              ],
            )));
  }
}
