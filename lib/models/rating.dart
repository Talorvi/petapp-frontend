class Rating {
  final int id;
  final int offerId;
  final int userId;
  final double rating;
  // Add other fields as required

  Rating({required this.id, required this.offerId, required this.userId, required this.rating});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      offerId: json['offer_id'],
      userId: json['user_id'],
      rating: json['rating'].toDouble(),
      // Initialize other fields
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offer_id': offerId,
      'user_id': userId,
      'rating': rating,
      // Convert other fields to JSON
    };
  }
}
