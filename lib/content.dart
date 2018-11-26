import 'package:flutter/material.dart';
import 'package:worcadeflutter/content_footer.dart';
import 'package:worcadeflutter/message.dart';
import 'package:worcadeflutter/sender.dart';

const _left = EdgeInsets.only(left: 10, right: 50);
const _right = EdgeInsets.only(left: 50, right: 10);

class ContentWidget extends StatelessWidget {
  final Content content;

  const ContentWidget({
    Key key,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: _children(),
      ),
      margin: content.mine ? _right : _left,
    );
  }

  List<Widget> _children() {
    var children = <Widget>[];
    children.add(Sender(sourceName: content.sourceName));
    for (var message in content.messages) {
      children.add(MessageWidget(message: message, mine: content.mine));
    }
    children.add(ContentFooterWidget(data: content.footer));
    return children;
  }
}

class Content {
  final String sourceName;
  final List<Message> messages;
  final bool mine;
  final ContentFooter footer;

  Content({this.messages, this.sourceName, this.mine, this.footer});
}
