import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/model.dart';
import 'package:worcadeflutter/sender.dart';

class ContentWidget extends StatelessWidget {
  final Entry entry;
  final _Render render;

  ContentWidget({
    Key key,
    Entry entry,
  })  : render = _contentRenderer(entry),
        this.entry = entry,
        super(key: key);

  @override
  Widget build(BuildContext context) => render(context, entry);

  static _Render _contentRenderer(Entry entry) {
    switch (entry.type) {
      case EntryType.content:
        return _fractional(_headered(_footered(_messages)));
      case EntryType.evaluation:
        return _fractional(_headered(_footered(_evaluation)));
      case EntryType.attachment:
        return _fractional(_headered(_footered(_attachment)));
      case EntryType.event:
        return _footered(_bar(_event, _eventBackgroundColor));
      default:
        return _unsupported;
    }
  }
}

Color _eventBackgroundColor(Entry entry) {
  var e = entry as Event;
  switch (e.eventType) {
    case 'CLOSE':
      return Color.fromARGB(255, 240, 251, 247);
    case 'SET_NAME':
    case 'REOPEN':
      return Color.fromARGB(255, 240, 250, 252);
    case 'REMOVE_ASSIGNEE':
    case 'REMOVE_REPORTER':
      return Color.fromARGB(255, 243, 243, 243);
    default:
      return Color.fromARGB(255, 239, 244, 247);
  }
}

Color _eventColor(Entry entry) {
  var e = entry as Event;
  switch (e.eventType) {
    case 'CLOSE':
      return Color.fromARGB(255, 0, 132, 78);
    case 'SET_NAME':
    case 'REOPEN':
      return Color.fromARGB(255, 0, 165, 204);
    case 'REMOVE_ASSIGNEE':
    case 'REMOVE_REPORTER':
      return Colors.black;
    default:
      return Color.fromARGB(255, 0, 75, 114);
  }
}

Widget _attachment(BuildContext context, Entry entry) => _bubble(
      context,
      _fetchAttachment((entry as Attachment)),
      entry.mine,
    );

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

Widget _image(BuildContext context, AttachmentData data) => _raised(
    context,
    Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Image.network(
          data.uri,
        )
      ],
    ),
    false);

Widget _file(BuildContext context, AttachmentData data) {
  return _raised(context, _downloadableAttachment(context, data), true);
}

Widget _downloadableAttachment(BuildContext context, AttachmentData data) {
  return GestureDetector(
      onLongPress: () {
        print('Downloading ${data.name}');
        _launchURL(data);
      },
      child: Row(children: <Widget>[
        Icon(Icons.attach_file),
        Expanded(
          child: Container(
            child: Text(data.name),
            margin: EdgeInsets.only(left: 10.0),
          ),
        ),
      ]));
}

void _launchURL(AttachmentData data) async {
  print('Downloading ${data.name} from ${data.uri}');
  if (await canLaunch(data.uri)) {
    await launch(data.uri);
  } else {
    throw 'Could not launch ${data.uri}';
  }
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

Widget _evaluation(BuildContext context, Entry entry) => _bubble(
      context,
      _raised(
        context,
        _rating(context, (entry as Evaluation).rating),
        true,
      ),
      entry.mine,
    );

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

Widget _messages(BuildContext context, Entry entry) => Column(
      children: (entry as Content)
          .messages
          .map((m) => _message(context, m, entry.mine))
          .toList(),
    );

Widget _message(BuildContext context, Message message, bool mine) =>
    _bubble(context, _text(message.message, mine), mine);

Widget _text(String text, bool mine) => Text(
      text,
      softWrap: true,
      style: TextStyle(color: mine ? Colors.black : Colors.white),
    );

Widget _event(BuildContext context, Entry entry) {
  var color = _eventColor(entry);
  var event = entry as Event;

  Widget _circle(
          {Icon icon, double borderWidth = 2, Color fill, Color borderColor}) =>
      Container(
        child: icon,
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
      );

  Widget _avatar(String id) {
    Widget _generate(User sender) {
      if (sender.picture != null) {
        return ClipRRect(
          child: Image.network(
            sender.picture,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(const Radius.circular(20)),
        );
      }
      return Container(
        child: Text(
          sender.name.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    Widget _build(BuildContext context, AsyncSnapshot<User> snapshot) {
      if (snapshot.hasData) {
        return _generate(snapshot.data);
      }
      if (snapshot.hasError) {
        throw snapshot.error;
      }
      return Text('...');
    }

    return FutureBuilder<User>(
      future: getUser(id),
      builder: _build,
    );
  }

  Widget _iconed(IconData icon, String text) => Row(
        children: [
          _circle(
            icon: Icon(
              icon,
              color: color,
            ),
            borderColor: color,
            fill: Colors.white,
          ),
          Container(
            child: Text.rich(
              TextSpan(
                  text: '${event.sender.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  children: [
                    TextSpan(
                        text: ' $text',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                        ))
                  ]),
            ),
            margin: EdgeInsets.only(left: 10),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );

  Widget _subjected(String message, Widget overlay) => Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              _avatar(event.subject.id),
              Container(
                child: overlay,
                padding: EdgeInsets.only(
                  left: 25,
                  top: 25,
                ),
              ),
            ],
          ),
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  event.subject.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            margin: EdgeInsets.only(left: 10),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );

  Widget _removed(String text, IconData icon) => Row(
        children: <Widget>[
          _circle(
            icon: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            fill: Color.fromARGB(255, 255, 72, 26),
            borderWidth: 3,
            borderColor: Color.fromARGB(255, 255, 72, 26),
          ),
          Container(
            child: Text(
              text,
              style: TextStyle(
                color: color,
              ),
            ),
            margin: EdgeInsets.only(left: 10),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );

  Widget _overlay(IconData iconData, Color color) => _circle(
        icon: Icon(
          iconData,
          size: 10,
          color: _eventBackgroundColor(entry),
        ),
        fill: color,
        borderWidth: 3,
        borderColor: _eventBackgroundColor(entry),
      );

  switch (event.eventType) {
    case 'CLOSE':
      return _iconed(Icons.check, 'closed the chat');
    case 'REOPEN':
      return _iconed(Icons.undo, 'reopened the chat');
    case 'SET_REPORTER':
      return _subjected(
        'is set as reporter by ${event.sender.name}',
        _overlay(Icons.play_arrow, Colors.green),
      );
    case 'SET_ASSIGNEE':
      return _subjected(
        'is assigned by ${event.sender.name}',
        _overlay(Icons.build, color),
      );
    case 'SET_NAME':
      return _iconed(Icons.mode_edit, 'changed the subject to\n${event.name}');
    case 'ADD_WATCHER':
      return _subjected(
        'was invited by ${event.sender.name}',
        _overlay(Icons.build, color),
      );
    case 'REMOVE_ASSIGNEE':
      return _removed('Made unassigned by ${event.sender.name}', Icons.build);
    case 'REMOVE_REPORTER':
      return _removed(
          'Reporter removed by ${event.sender.name}', Icons.play_arrow);
    default:
      return Text('Unsupported event type ${event.eventType}');
  }
}

_Render _headered(_Render contents) => (BuildContext context, Entry entry) {
      Widget _buildSender(BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          return SenderWidget(sender: snapshot.data);
        }
        if (snapshot.hasError) {
          throw snapshot.error;
        }
        return Text('...');
      }

      return Column(children: [
        FutureBuilder(
          future: getUser(entry.sender.id),
          builder: _buildSender,
        ),
        contents(context, entry),
      ]);
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

_Render _fractional(_Render contents) =>
    (BuildContext context, Entry entry) => FractionallySizedBox(
          child: contents(context, entry),
          alignment: entry.mine ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: 0.9,
        );

final _formatter = DateFormat('dd MMM HH:mm', 'en_US');

_Render _footered(_Render contents) => (BuildContext context, Entry entry) {
      List<Widget> _widgets() {
        var result = <Widget>[];
        result.add(Text(_formatter.format(entry.footer.time)));
        if (entry.footer.isRead) result.add(Icon(Icons.check));
        return result;
      }

      return Column(
        children: <Widget>[
          contents(context, entry),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _widgets(),
          ),
        ],
      );
    };

_Render _bar(_Render contents, Color color(Entry e)) =>
    (BuildContext context, Entry entry) {
      return Container(
        alignment: Alignment.center,
        child: contents(context, entry),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: color(entry),
        ),
      );
    };

Widget _unsupported(BuildContext context, Entry entry) =>
    Text('Unsupported entry type ${entry.type}');

typedef Widget _Render(BuildContext context, Entry entry);
