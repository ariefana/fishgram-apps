/// Model representing a fishing catch post in FishGram.
class CatchModel {
  final String id;
  final String userId;
  final String userName;
  final String userUsername;
  final String? userAvatar;
  final String photoUrl;
  final String fishType;
  final double weight; // in kg
  final String bait;
  final String? caption;
  final String? location;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;

  const CatchModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userUsername,
    this.userAvatar,
    required this.photoUrl,
    required this.fishType,
    required this.weight,
    required this.bait,
    this.caption,
    this.location,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
  });

  factory CatchModel.fromJson(Map<String, dynamic> json) {
    return CatchModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userName: json['user_name'] as String,
      userUsername: json['user_username'] as String? ?? '',
      userAvatar: json['user_avatar'] as String?,
      photoUrl: json['photo_url'] as String,
      fishType: json['fish_type'] as String,
      weight: (json['weight'] as num).toDouble(),
      bait: json['bait'] as String,
      caption: json['caption'] as String?,
      location: json['location'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_username': userUsername,
      'user_avatar': userAvatar,
      'photo_url': photoUrl,
      'fish_type': fishType,
      'weight': weight,
      'bait': bait,
      'caption': caption,
      'location': location,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
      'is_bookmarked': isBookmarked,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CatchModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userUsername,
    String? userAvatar,
    String? photoUrl,
    String? fishType,
    double? weight,
    String? bait,
    String? caption,
    String? location,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return CatchModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userUsername: userUsername ?? this.userUsername,
      userAvatar: userAvatar ?? this.userAvatar,
      photoUrl: photoUrl ?? this.photoUrl,
      fishType: fishType ?? this.fishType,
      weight: weight ?? this.weight,
      bait: bait ?? this.bait,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
