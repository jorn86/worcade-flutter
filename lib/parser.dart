import 'dart:convert';

import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/model.dart';

const _emptyMap = const <String, dynamic>{};

Sender parseUser(String source) {
  var map = json.decode(source) as Map<String, dynamic>;
  var user = map['data'] as Map<String, dynamic>;
  var pictureId =
      (user['picture'] as Map<String, dynamic> ?? _emptyMap)['id'] as String;

  return Sender(
    name: user['name'] as String,
    company: (user['company'] as Map<String, dynamic> ?? _emptyMap)['name']
        as String,
    picture: pictureId == null ? null : '$api/attachment/$pictureId/data',
  );
}

List<Conversation> parseConversationList(String source) {
  var map = json.decode(source) as Map<String, dynamic>;
  var conversations = map['data'] as List<dynamic>;
  var result = <Conversation>[];
  for (var value in conversations) {
    var conversation = value as Map<String, dynamic>;
    var myLastView = _lastView(conversation);
    var modified = _timestamp(conversation, 'modified');

    result.add(Conversation(
      id: conversation['id'] as String,
      name: conversation['name'] as String,
      number: conversation['number'] as String,
      read: !modified.isAfter(myLastView),
      modified: modified,
      reporter: reference(conversation['reporter']),
      assignee: reference(conversation['assignee']),
    ));
  }
  return result;
}

AttachmentData parseAttachment(String source, String api) {
  var data = json.decode(source)['data'] as Map<String, dynamic>;
  var id = data['id'] as String;
  return AttachmentData(
    id: id,
    mimeType: data['mimeType'] as String,
    name: data['name'] as String,
    uri: '$api/attachment/$id/data',
  );
}

DateTime _lastView(Map<String, dynamic> conversation) {
  var views = conversation['views'] as List<dynamic>;
  if (views == null || views.isEmpty) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  return _timestamp(views[0] as Map<String, dynamic>, 'lastView');
}

Conversation parseConversation(String source) {
  var map = json.decode(source) as Map<String, dynamic>;
  var conversation = map['data'] as Map<String, dynamic>;
  var rawContent = conversation['content'] as List<dynamic>;

  var readBy = <String, DateTime>{};
  var lastRead = DateTime.fromMillisecondsSinceEpoch(0);
  for (var value in conversation['views']) {
    var entry = value as Map<String, dynamic>;
    var userId = entry['id'] as String;
    if (isMe(userId)) continue;

    var time = _timestamp(entry, 'lastView');

    readBy[userId] = time;

    if (lastRead.isBefore(time)) lastRead = time;
  }
  var builder = _ConversationBuilder(
      number: conversation['number'] as String,
      name: conversation['name'] as String,
      lastRead: lastRead);

  rawContent.forEach(builder.addContent);

  return builder.finish();
}

Reference reference(dynamic content) {
  var c = content as Map<String, dynamic>;
  return c == null
      ? null
      : Reference(id: c['id'] as String, type: c['type'] as String);
}

DateTime _timestamp(Map<String, dynamic> map, String key) =>
    DateTime.fromMillisecondsSinceEpoch((map[key] as int) * 1000);

class _ConversationBuilder {
  final String number;
  final String name;
  final DateTime lastRead;

  List<Message> messages = [];
  DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(0);
  Reference lastSender = Reference();
  List<Entry> contents = [];

  _ConversationBuilder({this.number, this.name, this.lastRead});

  void addContent(dynamic content) {
    var c = content as Map<String, dynamic>;

    var sender = reference(c['source']);
    var time = _timestamp(c, 'timestamp');
    var type = c['type'] as String;

    if (type != 'MESSAGE' ||
        sender.id != lastSender.id ||
        time.difference(lastTime).inMinutes > 3) {
      _flush();
    }

    switch (type) {
      case 'MESSAGE':
        _addMessage(sender, time, c['message'] as String);
        break;
      case 'EVALUATION':
        _addEvaluation(sender, time, c['rating'] as int);
        break;
      case 'ATTACHMENT':
        var data = (c['content'] as Map<String, dynamic>);
        _addAttachment(
            sender, time, data['name'] as String, data['id'] as String);
        break;
      default:
        print(c);
    }
  }

  void _addMessage(Reference sender, DateTime time, String message) {
    lastSender = sender;
    lastTime = time;
    messages.add(Message(message));
  }

  void _addEvaluation(Reference sender, DateTime time, int rating) {
    contents.add(Evaluation(
      rating: rating,
      sender: sender,
      footer: _footer(time),
    ));
  }

  void _addAttachment(Reference sender, DateTime time, String name, String id) {
    contents.add(Attachment(
      id: id,
      name: name,
      sender: sender,
      footer: _footer(time),
    ));
  }

  void _reset() {
    messages = [];
    lastTime = DateTime.fromMillisecondsSinceEpoch(0);
    lastSender = Reference();
  }

  void _flush() {
    if (messages.isNotEmpty) {
      contents.add(Content(
        messages: messages,
        sender: lastSender,
        footer: _footer(lastTime),
      ));
      _reset();
    }
  }

  ContentFooter _footer(DateTime time) => ContentFooter(
        time: time,
        isRead: !lastRead.isBefore(time),
      );

  Conversation finish() {
    _flush();
    return Conversation(
      number: number,
      name: name,
      content: contents,
    );
  }
}
