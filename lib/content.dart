import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/model.dart';
import 'package:worcadeflutter/sender.dart';

class ContentWidget extends StatelessWidget {
  final Entry entry;
  final _SingleRender render;

  ContentWidget({
    Key key,
    Entry entry,
  })  : render = _contentRenderer(entry),
        this.entry = entry,
        super(key: key);

  @override
  Widget build(BuildContext context) => render(context, entry);

  static _SingleRender _contentRenderer(Entry entry) {
    switch (entry.type) {
      case EntryType.content:
        return _fractional(_headered(_footered(_messages)));
      case EntryType.evaluation:
        return _fractional(_headered(_footered(_evaluation)));
      case EntryType.attachment:
        return _fractional(_headered(_footered(_attachment)));
      default:
        return _unsupported;
    }
  }
}

List<Widget> _attachment(BuildContext context, Entry entry) => <Widget>[
      _bubble(context, _fetchAttachment((entry as Attachment)), entry.mine)
    ];

Widget _fetchAttachment(Attachment attachment) {
  Widget _buildAttachment(
    BuildContext context,
    AsyncSnapshot<AttachmentData> snapshot,
  ) {
    if (snapshot.hasData) {
      return snapshot.data.isImage
          ? _image(context, snapshot.data)
          : _file(context, snapshot.data);
    }
    if (snapshot.hasError) {
      throw snapshot.error;
    }
    return CircularProgressIndicator();
  }

  return FutureBuilder(
    future: getAttachmentData(attachment.id),
    builder: _buildAttachment,
  );
}

Widget _image(BuildContext context, AttachmentData data) {
  return _raised(context, Flex(
      direction: Axis.vertical,
      children: <Widget>[Image.network(
    data.uri,
    width: 30,
    height: 30,
    fit: BoxFit.scaleDown,
  )],), false);
}

Widget _file(BuildContext context, AttachmentData data) {
  return _raised(context, Text(data.name), true);
}

Widget _raised(BuildContext context, Widget child, bool roundedCorners) =>
    Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: roundedCorners
            ? BorderRadius.circular(5)
            : BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1.0,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: child,
    );

List<Widget> _evaluation(BuildContext context, Entry entry) => <Widget>[
      _bubble(
          context,
          _raised(
            context,
            _rating(context, (entry as Evaluation).rating),
            true,
          ),
          entry.mine)
    ];

const _ratingText = [
  'Uh',
  'Oops...',
  'Better next time',
  'OK',
  'Great',
  'Excelent!'
];

Widget _rating(BuildContext context, int rating) {
  var stars = <Widget>[];
  for (var i = 0; i < 5; i++) {
    if (i + 1 <= rating) {
      stars.add(Icon(Icons.star, color: Colors.yellow));
    } else {
      stars.add(Icon(Icons.star_border, color: Colors.grey));
    }
  }
  return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: stars,
        ),
        Text(
          ' ${_ratingText[rating]}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
}

List<Widget> _messages(BuildContext context, Entry entry) => (entry as Content)
    .messages
    .map((m) => _message(context, m, entry.mine))
    .toList();

Widget _message(BuildContext context, Message message, bool mine) =>
    _bubble(context, _text(message.message, mine), mine);

Widget _text(String text, bool mine) => Text(
      text,
      softWrap: true,
      style: TextStyle(color: mine ? Colors.black : Colors.white),
    );

_ListRender _headered(_ListRender contents) =>
    (BuildContext context, Entry entry) {
      Widget _buildSender(
          BuildContext context, AsyncSnapshot<Sender> snapshot) {
        if (snapshot.hasData) {
          return SenderWidget(sender: snapshot.data);
        }
        if (snapshot.hasError) {
          throw snapshot.error;
        }
        return Text('...');
      }

      return <Widget>[]
        ..add(FutureBuilder(
          future: getUser(entry.sender.id),
          builder: _buildSender,
        ))
        ..addAll(contents(context, entry));
    };

Widget _bubble(BuildContext context, Widget child, bool mine) => Container(
      child: Column(
        children: <Widget>[child],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
          color: mine
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(const Radius.circular(7))),
    );

_SingleRender _fractional(_ListRender contents) =>
    (BuildContext context, Entry entry) => FractionallySizedBox(
          child: Column(children: contents(context, entry)),
          alignment: entry.mine ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: 0.9,
        );

final _formatter = DateFormat('dd MMM HH:mm', 'en_US');

_ListRender _footered(_ListRender contents) =>
    (BuildContext context, Entry entry) {
      List<Widget> _widgets() {
        var result = <Widget>[];
        result.add(Text(_formatter.format(entry.footer.time)));
        if (entry.footer.isRead) result.add(Icon(Icons.check));
        return result;
      }

      return <Widget>[]
        ..addAll(contents(context, entry))
        ..add(Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _widgets(),
        ));
    };

_SingleRender _bar(_ListRender contents) {}

Widget _unsupported(BuildContext context, Entry entry) =>
    Text('Unsupported entry type ${entry.type}');

typedef List<Widget> _ListRender(BuildContext context, Entry entry);
typedef Widget _SingleRender(BuildContext context, Entry entry);
