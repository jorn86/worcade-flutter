import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:worcadeflutter/auth.dart';
import 'package:worcadeflutter/model.dart';
import 'package:worcadeflutter/parser.dart';

const api = 'https://dev.worcade.net/api/v2';
const _headers = const <String, String>{
  'Worcade-User': 'DIGEST $loginToken',
  'Accept': 'application/json',
};

final _userCache = <String, Future<Sender>>{};

Future<Sender> getUser(String id) => _userCache.putIfAbsent(
    id,
    () => http
        .get('$api/user/$id', headers: _headers)
        .then((response) => parseUser(response.body)));

Future<List<Conversation>> getConversationList() => http
    .get('$api/conversation?limit=5&field=name&field=number&order=-modified', headers: _headers)
    .then((response) => parseConversationList(response.body));

Future<Conversation> getConversation(String id) => http
    .get('$api/conversation/$id', headers: _headers)
    .then((response) => parseConversation(response.body));
