import 'package:flutter/material.dart';

class Sender extends StatelessWidget {
  final String sourceName;

  const Sender({
    Key key,
    this.sourceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Row(
        children: <Widget>[
          Icon(Icons.add),
          Text(sourceName),
        ],
      ),
    );
  }
}
