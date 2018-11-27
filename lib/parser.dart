import 'dart:convert';

import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/auth.dart';
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
    result.add(Conversation(id: conversation['id'] as String, name: conversation['name'] as String, number: conversation['number'] as String));
  }
  return result;
}

Conversation parseConversation(String source) {
  var map = json.decode(source) as Map<String, dynamic>;
  var conversation = map['data'] as Map<String, dynamic>;
  var rawContent = conversation['content'] as List<dynamic>;
  var result = <Content>[];

  var readBy = <String, DateTime>{};
  var lastRead = DateTime.fromMillisecondsSinceEpoch(0);
  for (var value in conversation['views']) {
    var entry = value as Map<String, dynamic>;
    var userId = entry['id'] as String;
    if (isMe(userId)) continue;

    var time = DateTime.fromMillisecondsSinceEpoch(
        (entry['lastView'] as int) * 1000,
        isUtc: true);

    readBy[userId] = time;

    if (lastRead.isBefore(time)) lastRead = time;
  }

  for (var value in rawContent) {
    var content = value as Map<String, dynamic>;
    if ((content['type'] as String) != 'MESSAGE') continue;

    var sender = _reference(content['source']);
    var time = DateTime.fromMillisecondsSinceEpoch(
        (content['timestamp'] as int) * 1000,
        isUtc: true);

    result.add(Content(
      messages: <Message>[Message(content['message'] as String)],
      sender: sender,
      footer: ContentFooter(
        time: time,
        isRead: !lastRead.isBefore(time),
      ),
    ));
  }
  return Conversation(
      number: conversation['number'] as String,
      name: conversation['name'] as String,
      content: result);
}

Reference _reference(dynamic content) {
  var c = content as Map<String, dynamic>;
  return Reference(id: c['id'] as String, type: c['type'] as String);
}
