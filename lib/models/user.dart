class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final double? averageOfferRating;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.averageOfferRating,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      averageOfferRating: json['average_offer_rating'] as double?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'average_offer_rating': averageOfferRating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
