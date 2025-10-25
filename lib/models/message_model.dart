class MessageModel {
  final String id;
  final String? conversationId;
  final String? senderId;
  final String? content;
  final String? imageUrl;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    this.conversationId,
    this.senderId,
    this.content,
    this.imageUrl,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'image_url': imageUrl,
    };
  }
}
