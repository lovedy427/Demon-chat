enum MessageType { user, character }

class Message {
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final String? characterId;

  Message({
    required this.text,
    required this.type,
    required this.timestamp,
    this.characterId,
  });
}
