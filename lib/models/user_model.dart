/// Model representing a user in FishGram.
class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final String? fishingType; // Laut, Sungai, Danau, etc.
  final String? location;
  final int followersCount;
  final int followingCount;
  final int catchesCount;
  final bool isFollowing;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    this.fishingType,
    this.location,
    this.followersCount = 0,
    this.followingCount = 0,
    this.catchesCount = 0,
    this.isFollowing = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      fishingType: json['fishing_type'] as String?,
      location: json['location'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      catchesCount: json['catches_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'fishing_type': fishingType,
      'location': location,
      'followers_count': followersCount,
      'following_count': followingCount,
      'catches_count': catchesCount,
      'is_following': isFollowing,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? avatar,
    String? bio,
    String? fishingType,
    String? location,
    int? followersCount,
    int? followingCount,
    int? catchesCount,
    bool? isFollowing,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      fishingType: fishingType ?? this.fishingType,
      location: location ?? this.location,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      catchesCount: catchesCount ?? this.catchesCount,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
