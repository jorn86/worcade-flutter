import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worcadeflutter/model.dart';
import 'package:worcadeflutter/parser.dart';

const api = 'https://dev.worcade.net/api/v2';

String _apiKey;
String _myId;

bool isMe(String id) => id == _myId;

final _userCache = <String, Future<User>>{};

class ConversationListQuery {
  final String title; // This does not belong here
  final String reporterId;
  final String assigneeId;
  final int limit;

  ConversationListQuery(this.title,
      {this.reporterId, this.assigneeId, this.limit = 100});

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
  if (_apiKey == null) throw 'API key not available';
  var response = await http.get('$api/authentication', headers: _headers);
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

Future<void> sendNotificationToken(String token) async {
  http.post('$api/user/$_myId/firebaseToken', headers: _headers, body: json.encode({'token': token})).then((v) => print(v.statusCode));
}

Future<Reference> loginUser(String email, String password) async {
  var tokenResponse = await http
      .get('$api/authentication/user/email', headers: {
    'Authorization': 'BASIC ${base64.encode(utf8.encode('$email:$password'))}'
  });

  if (tokenResponse.statusCode != 200) throw 'Authentication failed';

  var tokenBody = parseData(tokenResponse.body) as Map<String, dynamic>;
  _myId = reference(tokenBody['authenticated']).id;

  var keyResponse = await http.post(
      '$api/user/$_myId/apikey?apiKeyDescription=MobileApp',
      headers: <String, String>{
        'Worcade-User': 'DIGEST ${tokenBody['token']}',
        'Accept': 'application/json',
      });

  if (keyResponse.statusCode != 200) throw 'Creating API key failed';

  _apiKey =
      (parseData(keyResponse.body) as Map<String, dynamic>)['apiKey'] as String;

  var prefs = await SharedPreferences.getInstance();
  prefs.setString('apikey', _apiKey);
  return null;
}

Future<List<Conversation>> getConversationList(ConversationListQuery query) {
  var url =
      '$api/conversation?limit=${query.limit}&field=name&field=number&field=reporter&field=assignee&field=views&field=creator&field=modified&order=-modified';
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

Future<User> getMyUser() => getUser(_myId);

Future<User> getUser(String id) => _userCache.putIfAbsent(
    id,
    () => http
        .get('$api/user/$id', headers: _headers)
        .then((response) => parseUser(response.body)));

Future<AttachmentData> getAttachmentData(String id) => http
    .get('$api/attachment/$id', headers: _headers)
    .then((response) => parseAttachment(response.body, api));

Future<Reference> createConversation(String name) {
  return http
      .post('$api/conversation',
          headers: _headers,
          body: json.encode({
            'name': name,
            'watchers': [
              {'id': _myId}
            ]
          }))
      .then((response) {
    print('got ${response.statusCode}: ${response.body}');
    return reference(parseData(response.body));
  });
}

Future<void> addMessage(String conversationId, String text) {
  return http.post('$api/conversation/$conversationId/content/message',
      headers: _headers, body: json.encode({'text': text}));
}

Future<void> addAttachment(String conversationId, Future<File> future) async {
  var file = await future;
  var request = http.MultipartRequest("POST", Uri.parse('$api/attachment'));
  request.headers.addAll(_headers);
  request.files.add(
    http.MultipartFile('file',
        new http.ByteStream(DelegatingStream.typed(file.openRead())), await file.length(),
        filename: 'photo.jpg', contentType: MediaType('image', 'jpeg')),
  );
  var response = await request.send();
  var responseBody = await response.stream.transform(utf8.decoder).join();
  return await http.post('$api/conversation/$conversationId/content',
      headers: _headers, body: json.encode(<Object>[parseData(responseBody)]));
}

Map<String, String> get _headers => <String, String>{
      'Worcade-User': 'APIKEY $_apiKey',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
