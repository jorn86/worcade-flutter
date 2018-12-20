import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:worcadeflutter/api.dart';
import 'package:worcadeflutter/content.dart';
import 'package:worcadeflutter/main.dart';
import 'package:worcadeflutter/model.dart';

Widget openConversationList(BuildContext context, ConversationListQuery query) {
  return scaffold(context, query.title,
      body: Container(
          child: FutureBuilder(
              future: getConversationList(query),
              builder: _buildConversationList),
          alignment: Alignment.center));
}

Widget openConversation(BuildContext context, String id) {
  return scaffold(context, 'Worcade chat',
      appBarButton: BackButton(),
      body: Container(
        child: FutureBuilder(
          future: getConversation(id),
          builder: _buildConversation,
        ),
        alignment: Alignment.center,
      ));
}

Widget _buildConversationList(
    BuildContext context, AsyncSnapshot<List<Conversation>> snapshot) {
  if (snapshot.hasData) {
    var widgets = <Widget>[];
    for (var value in snapshot.data) {
      widgets.add(GestureDetector(
        child: _buildListTile(context, value),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute<Widget>(
                builder: (context) => openConversation(context, value.id))),
      ));
    }
    return ListView(
      children: widgets,
    );
  }
  if (snapshot.hasError) {
    throw snapshot.error;
  }
  return CircularProgressIndicator();
}

Widget _buildConversation(
    BuildContext context, AsyncSnapshot<Conversation> snapshot) {
  if (snapshot.hasData) {
    view(snapshot.data.id);
    return Column(children: <Widget>[
      ConversationContent(data: snapshot.data),
      ConversationInput(conversationId: snapshot.data.id)
    ]);
  }
  if (snapshot.hasError) {
    throw snapshot.error;
  }
  return CircularProgressIndicator();
}

final _dateFormatter = DateFormat('dd MMM', 'en_US');
final _timeFormatter = DateFormat('HH:mm', 'en_US');
Widget _buildListTile(BuildContext context, Conversation value) {
  var now = DateTime.now();
  var midnight = DateTime(now.year, now.month, now.day);
  var today = midnight.isBefore(value.modified);
  return Container(
    child: Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: Text(
            '${value.number} ${value.name}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: value.read ? FontWeight.normal : FontWeight.bold),
          )),
          Text((today ? _timeFormatter : _dateFormatter).format(value.modified))
        ],
      ),
      Row(
        children: _buildListSubtitle(context, value),
      ),
    ]),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Theme.of(context).primaryColor))),
  );
}

List<Widget> _buildListSubtitle(BuildContext context, Conversation value) {
  var result = <Widget>[];
  if (value.reporter != null) {
    if (value.assignee != null && value.assignee.id == value.reporter.id) {
      result.add(FutureBuilder(
          future: getUser(value.reporter.id),
          builder: (context, AsyncSnapshot<User> snapshot) => _buildReporter(
              context, snapshot, [Icons.play_circle_outline, Icons.build])));
    } else {
      result.add(FutureBuilder(
          future: getUser(value.reporter.id),
          builder: (context, AsyncSnapshot<User> snapshot) =>
              _buildReporter(context, snapshot, [Icons.play_circle_outline])));
    }
  }
  if (value.assignee != null &&
      (value.reporter == null || value.reporter.id != value.assignee.id)) {
    result.add(FutureBuilder(
        future: getUser(value.assignee.id),
        builder: (context, AsyncSnapshot<User> snapshot) =>
            _buildReporter(context, snapshot, [Icons.build])));
  }
  return result;
}

Widget _buildReporter(
    BuildContext context, AsyncSnapshot<User> snapshot, List<IconData> icons) {
  if (snapshot.hasData) {
    var children = <Widget>[];
    for (var value in icons) {
      children.add(Icon(value));
    }
    children.add(Text(snapshot.data.name));
    return Container(
      child: Row(
        children: children,
      ),
    );
  }
  if (snapshot.hasError) {
    throw snapshot.error;
  }
  return Text('...');
}

class ConversationContent extends StatefulWidget {
  static ConversationContentState latest;

  final Conversation data;

  const ConversationContent({Key key, this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return latest = ConversationContentState(data);
  }
}

class ConversationContentState extends State<ConversationContent> {
  Conversation conversation;

  ConversationContentState(this.conversation);

  String get conversationId => conversation.id;

  void reload() {
    getConversation(conversationId)
        .then((conversation) => update(conversation));
  }

  void update(Conversation conversation) {
    setState(() {
      this.conversation = conversation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(children: <Widget>[
      Container(
        child: Row(
          children: <Widget>[
            Text(conversation.number,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
                child: Text(
              ' ${conversation.name}',
              style: TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
        padding: EdgeInsets.only(bottom: 5),
      ),
      Expanded(
        child: ListView(
            padding: EdgeInsets.all(10),
            reverse: true,
            children: conversation.content
                .map((c) => ContentWidget(entry: c))
                .toList()
                .reversed
                .toList()),
      )
    ]));
  }
}

class ConversationInput extends StatefulWidget {
  final String conversationId;

  const ConversationInput({Key key, this.conversationId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConversationInputState(conversationId);
}

class ConversationInputState extends State<ConversationInput> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String conversationId;
  String text;

  ConversationInputState(this.conversationId);

  void _submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
      addMessage(conversationId, text).then(_reload);
      _formKey.currentState.reset();
    }
  }

  void _upload() {
    addAttachment(
            conversationId, ImagePicker.pickImage(source: ImageSource.camera))
        .then(_reload);
  }

  void _reload(void value) {
    ConversationContent.latest.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
          child: Row(children: <Widget>[
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: _upload,
            ),
            Flexible(
                child: TextFormField(
              maxLines: 2,
              decoration: InputDecoration(hintText: 'Type a message...'),
              onSaved: (value) => this.text = value,
            )),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _submit, // TODO debounce
            ),
          ]),
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Theme.of(context).primaryColor)))),
    );
  }
}
