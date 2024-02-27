import 'package:petapp/models/user.dart';

class Rating {
  final String id;
  final String review;
  final String userId;
  final String offerId;
  final double rating;
  final String createdAt;
  final String updatedAt;
  final User user; // Using the User class to represent the nested object

  Rating({
    required this.id,
    required this.review,
    required this.userId,
    required this.offerId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      review: json['review'],
      userId: json['user_id'],
      offerId: json['offer_id'],
      rating: (json['rating'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: User.fromJson(json['user']), // Deserialize the nested User object
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review': review,
      'user_id': userId,
      'offer_id': offerId,
      'rating': rating,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user.toJson(), // Serialize the nested User object
    };
  }
}
