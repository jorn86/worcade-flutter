import 'package:flutter/material.dart';
import 'package:worcadeflutter/model.dart';

class SenderWidget extends StatelessWidget {
  final User sender;

  const SenderWidget({
    Key key,
    this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: _children(context));
  }

  List<Widget> _children(BuildContext context) {
    var style = TextStyle(color: Theme.of(context).secondaryHeaderColor);
    var result = <Widget>[];
    if (sender.picture != null) {
      result.add(ClipRRect(
        child: Image.network(
          sender.picture,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(const Radius.circular(15)),
      ));
    }
    result.add(Container(
        child: Text(
          sender.name,
          style: style,
        ),
        margin: EdgeInsets.only(left: 5)));
    if (sender.company != null) {
      result.add(Container(
          child: Text(
            '\u00b7 ${sender.company}',
            style: style,
          ),
          margin: EdgeInsets.only(left: 5)));
    }
    return result;
  }
}
