import 'package:worcadeflutter/api.dart';

class Conversation {
  final String id;
  final String number;
  final String name;
  final bool read;
  final DateTime modified;
  final Reference reporter;
  final Reference assignee;
  final List<Entry> content;

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

class Entry {
  final Reference sender;
  final ContentFooter footer;
  final EntryType type;

  Entry(this.type, {this.sender, this.footer});

  bool get mine => sender != null && isMe(sender.id);
}

class Content extends Entry {
  final List<Message> messages;

  Content({this.messages, Reference sender, ContentFooter footer})
      : super(EntryType.content, sender: sender, footer: footer);

  @override
  String toString() =>
      '(sender: $sender, messages: $messages, footer: $footer)';
}

class Evaluation extends Entry {
  final int rating;

  Evaluation({this.rating, Reference sender, ContentFooter footer})
      : super(EntryType.evaluation, sender: sender, footer: footer);

  @override
  String toString() => '(rating: $rating)';
}

class Attachment extends Entry {
  final String id;
  final String name;
  Attachment({this.id, this.name, Reference sender, ContentFooter footer})
      : super(EntryType.attachment, sender: sender, footer: footer);
}

enum EntryType {
  content,
  evaluation,
  attachment,
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

class AttachmentData {
  final String id;
  final String name;
  final String uri;
  final String mimeType;

  AttachmentData({this.id, this.mimeType, this.name, this.uri});

  bool get isImage => mimeType.startsWith('image/');

  @override
  String toString() => '$id $mimeType $name, $uri';
}
