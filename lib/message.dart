import 'package:flutter/material.dart';
import 'package:worcadeflutter/model.dart';

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
    var theme = Theme.of(context);
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
          color: mine ? theme.primaryColorLight : theme.primaryColor,
          borderRadius: BorderRadius.all(const Radius.circular(7))),
    );
  }
}
