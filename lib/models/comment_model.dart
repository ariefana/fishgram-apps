/// Model representing a comment on a catch post.
class CommentModel {
  final String id;
  final String catchId;
  final String userId;
  final String userName;
  final String userUsername;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.catchId,
    required this.userId,
    required this.userName,
    required this.userUsername,
    this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'].toString(),
      catchId: json['catch_id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] as String,
      userUsername: json['user_username'] as String? ?? '',
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catch_id': catchId,
      'user_id': userId,
      'user_name': userName,
      'user_username': userUsername,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
