import 'package:flutter/material.dart';
import 'package:petapp/models/rating.dart';
import 'package:petapp/services/api_service.dart';

class ReviewsListWidget extends StatelessWidget {
  final String offerId;

  const ReviewsListWidget({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Rating>>(
      future: ApiService().getRatingsByOfferId(offerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          List<Rating> ratings = snapshot.data!;
          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              Rating rating = ratings[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(rating.user.avatarUrl ?? ''),
                  ),
                  title: Text(rating.user.name),
                  subtitle: Text(rating.review ?? 'No review'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < rating.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ),
              );
            },
          );
        } else {
          return const Text("No ratings found.");
        }
      },
    );
  }
}
