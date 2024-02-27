import 'package:flutter/material.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/screens/reviews/add_review_screen.dart';
import '../models/user.dart';

class ReviewsWidget extends StatelessWidget {
  final Offer offer; // Assuming you need the offer ID to add a review

  const ReviewsWidget({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        // Your existing widget content
        child: Text('Reviews'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReviewScreen(offer: offer)),
          );
        },
        tooltip: 'Add Review',
        child: const Icon(Icons.add),
      ),
    );
  }
}
