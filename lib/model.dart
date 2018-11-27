class Conversation {
  final String id;
  final String number;
  final String name;
  final bool read;
  final DateTime modified;
  final Reference reporter;
  final Reference assignee;
  final List<Content> content;

  Conversation(
      {this.id,
      this.number,
      this.name,
      this.read,
      this.modified,
      this.reporter,
      this.assignee,
      this.content});

  @override
  String toString() => '($number $name content: $content)';
}

class Content {
  final Reference sender;
  final List<Message> messages;
  final ContentFooter footer;

  Content({this.messages, this.sender, this.footer});

  @override
  String toString() =>
      '(sender: $sender, messages: $messages, footer: $footer)';
}

class Message {
  final String message;

  Message(this.message);

  @override
  String toString() => message;
}

class Sender {
  final String name;
  final String company;
  final String picture;

  Sender({this.name, this.company, this.picture});

  @override
  String toString() => '$name \u00b7 $company; pic: ${picture != null}';
}

class ContentFooter {
  final DateTime time;
  final bool isRead;

  ContentFooter({this.time, this.isRead});

  @override
  String toString() => '$time $isRead';
}

class Reference {
  final String id;
  final String type;

  Reference({this.id, this.type});

  @override
  String toString() => '$type $id';
}
