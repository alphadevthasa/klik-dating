class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isMine,
    required this.timeLabel,
  });

  final String text;
  final bool isMine;
  final String timeLabel;
}
