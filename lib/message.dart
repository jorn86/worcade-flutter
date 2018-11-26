import 'package:flutter/material.dart';

const _mine = Color.fromARGB(255, 230, 230, 230);
const _notMine = Color.fromARGB(255, 60, 127, 186);

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool mine;

  const MessageWidget({
    Key key,
    this.message,
    this.mine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            message.message,
            softWrap: true,
            style: TextStyle(color: mine ? Colors.black : Colors.white),
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
          color: mine ? _mine : _notMine,
          borderRadius: BorderRadius.all(const Radius.circular(7))),
    );
  }
}

class Message {
  final String message;

  Message(this.message);
}
