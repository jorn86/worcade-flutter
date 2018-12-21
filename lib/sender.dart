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
      result.add(profilePicture(sender.picture, 30));
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

Widget profilePicture(String url, double size) {
  Widget child = url == null
      ? Icon(Icons.person)
      : Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
  return ClipRRect(child: child, borderRadius: BorderRadius.circular(size / 2));
}
