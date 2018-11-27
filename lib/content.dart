import 'package:flutter/material.dart';
import 'package:worcadeflutter/content_footer.dart';
import 'package:worcadeflutter/message.dart';
import 'package:worcadeflutter/sender.dart';

class ContentWidget extends StatelessWidget {
  final Content content;

  const ContentWidget({
    Key key,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: Column(children: _children()),
      alignment: content.mine ? Alignment.centerRight : Alignment.centerLeft,
      widthFactor: 0.8,
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
