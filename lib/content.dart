import 'package:flutter/material.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/auth.dart';
import 'package:worcadeflutter/content_footer.dart';
import 'package:worcadeflutter/message.dart';
import 'package:worcadeflutter/model.dart';
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
      alignment: isMe(content.sender.id) ? Alignment.centerRight : Alignment.centerLeft,
      widthFactor: 0.9,
    );
  }

  List<Widget> _children() {
    var children = <Widget>[];
    children.add(FutureBuilder(future: getUser(content.sender.id), builder: _buildSender));
    for (var message in content.messages) {
      children.add(MessageWidget(message: message, mine: isMe(content.sender.id)));
    }
    children.add(ContentFooterWidget(data: content.footer));
    return children;
  }

  Widget _buildSender(BuildContext context, AsyncSnapshot<Sender> snapshot) {
    if (snapshot.hasData) {
      return SenderWidget(sender: snapshot.data);
    }
    if (snapshot.hasError) {
      throw snapshot.error;
    }
    return Text('...');
  }
}
