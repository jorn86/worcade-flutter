import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _formatter = DateFormat('dd MMM HH:mm', 'en_US');

class ContentFooterWidget extends StatelessWidget {
  final ContentFooter data;

  const ContentFooterWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _widgets(),
    );
  }

  List<Widget> _widgets() {
    var result = <Widget>[];
    result.add(Text(_formatter.format(data.time)));
    if (data.isRead) result.add(Icon(Icons.check));
    return result;
  }
}

class ContentFooter {
  final DateTime time;
  final bool isRead;

  ContentFooter({this.time, this.isRead});
}
