class ChatMessage {
  final String id;
  final String userId;
  final String nickname;
  final String message;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
