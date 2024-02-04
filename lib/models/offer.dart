import 'package:petapp/models/user.dart';

class Offer {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? price;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? averageRating;
  final User user; // Assuming User model is already defined
  final String imageUrl = '';

  Offer({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.averageRating,
    required this.user,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as String?, // Cast as nullable String
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      averageRating: (json['average_rating'] as num?)
          ?.toDouble(), // Cast as nullable num, then to Double
      user: User.fromJson(json['user']
          as Map<String, dynamic>), // Assuming User has a fromJson method
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'average_rating': averageRating,
      'user': user.toJson(), // Serialize the nested User object
    };
  }
}
