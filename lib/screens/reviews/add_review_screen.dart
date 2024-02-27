// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/services/api_service.dart';

class AddReviewScreen extends StatefulWidget {
  final Offer offer;

  const AddReviewScreen({super.key, required this.offer});

  @override
  // ignore: library_private_types_in_public_api
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _currentRating = 1;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rating", style: Theme.of(context).textTheme.headline6),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              label: _currentRating.round().toString(),
              value: _currentRating,
              onChanged: (double value) {
                setState(() {
                  _currentRating = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: "Review (Optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitReview(),
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview() async {
    // Use ApiService to submit the review
    try {
      await ApiService().createReview(widget.offer.id, _currentRating, review: _reviewController.text);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add review: $e')));
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
