import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:worcadeflutter/model.dart';
import 'package:worcadeflutter/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

const api = 'https://dev.worcade.net/api/v2';

String _apiKey;
String _myId;

bool isMe(String id) => id == _myId;

final _userCache = <String, Future<Sender>>{};

class ConversationListQuery {
  final String title; // This does not belong here
  final String reporterId;
  final String assigneeId;
  final int limit;

  ConversationListQuery(this.title,
      {this.reporterId, this.assigneeId, this.limit = 10});

  static ConversationListQuery get all =>
      ConversationListQuery('Worcade conversations');
  static ConversationListQuery get reportedByMe =>
      ConversationListQuery('Reported by me', reporterId: _myId);
  static ConversationListQuery get assignedToMe =>
      ConversationListQuery('Assigned to me', assigneeId: _myId);
}

Future<Reference> checkStoredApiKey() async {
  var prefs = await SharedPreferences.getInstance();
  _apiKey = prefs.getString('apikey');
  var response = await http
      .get('$api/authentication', headers: _headers);
  if (response.statusCode != 200) {
    _apiKey = null;
    throw 'API key no longer valid';
  }
  var data = (json.decode(response.body) as Map<String, dynamic>)['data']
      as Map<String, dynamic>;
  var me = reference(data['user']);
  _myId = me.id;
  return me;
}

Future<Reference> loginUser(String email, String password) {
  return http.get('$api/authentication/user/email', headers: {
    'Authorization': 'BASIC ${base64.encode(utf8.encode('$email:$password'))}'
  }).then((response) {
    if (response.statusCode != 200) throw 'Authentication failed';
    var body = (json.decode(response.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    var subject = reference(body['authenticated']);
    _myId = subject.id;
    return http.post('$api/user/$_myId/apikey?apiKeyDescription=MobileApp',
        headers: <String, String>{
          'Worcade-User': 'DIGEST ${body['token']}',
          'Accept': 'application/json',
        });
  }).then((response) {
    if (response.statusCode != 200) throw 'Creating API key failed';
    var body = (json.decode(response.body) as Map<String, dynamic>)['data']
        as Map<String, dynamic>;
    _apiKey = body['apiKey'] as String;
    return SharedPreferences.getInstance().then((prefs) {
      prefs.setString('apikey', _apiKey);
    });
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
      'Worcade-User': 'APIKEY $_apiKey',
      'Accept': 'application/json',
    };
