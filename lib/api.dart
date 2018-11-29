import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:worcadeflutter/model.dart';
import 'package:worcadeflutter/parser.dart';

const api = 'https://dev.worcade.net/api/v2';

var _loginToken = '/Jv0dGtUZMuMA3Wbj49HbvNuE6QVQWXx';
var _myId = '0e317203-581a-4d79-b8ca-2ac16ba55364';

bool isMe(String id) => id == _myId;

final _userCache = <String, Future<Sender>>{};

class ConversationListQuery {
  final String reporterId;
  final String assigneeId;
  final int limit;

  ConversationListQuery({this.reporterId, this.assigneeId, this.limit = 10});

  static ConversationListQuery get all => ConversationListQuery();
  static ConversationListQuery get reportedByMe =>
      ConversationListQuery(reporterId: _myId);
  static ConversationListQuery get assignedToMe =>
      ConversationListQuery(assigneeId: _myId);
}

Future<Reference> loginUser(String email, String password) {
  return http.get('$api/authentication/user/email', headers: {
    'Authorization': 'BASIC ${base64.encode(utf8.encode('$email:$password'))}'
  }).then((response) {
    if (response.statusCode != 200) throw 'Authentication failed';
    var body = (json.decode(response.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    var subject = reference(body['authenticated']);
    _loginToken = body['token'] as String;
    _myId = subject.id;
    return subject;
  });
}

Future<List<Conversation>> getConversationList(ConversationListQuery query) {
  var url =
      '$api/conversation?limit=${query.limit}&field=name&field=number&field=views&field=modified&field=reporter&field=assignee&order=-modified';
  if (query.assigneeId != null) {
    url += '&assignee=${query.assigneeId}';
  }
  if (query.reporterId != null) {
    url += '&reporter=${query.reporterId}';
  }
  return http
      .get(url, headers: _headers)
      .then((response) => parseConversationList(response.body));
}

Future<Conversation> getConversation(String id) => http
    .get('$api/conversation/$id', headers: _headers)
    .then((response) => parseConversation(response.body));

Future<Sender> getUser(String id) => _userCache.putIfAbsent(
    id,
    () => http
        .get('$api/user/$id', headers: _headers)
        .then((response) => parseUser(response.body)));

Future<AttachmentData> getAttachmentData(String id) => http
    .get('$api/attachment/$id', headers: _headers)
    .then((response) => parseAttachment(response.body, api));

Map<String, String> get _headers => <String, String>{
      'Worcade-User': 'DIGEST $_loginToken',
      'Accept': 'application/json',
    };
