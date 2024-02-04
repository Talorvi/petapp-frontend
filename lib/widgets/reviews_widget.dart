import 'package:flutter/material.dart';
import '../models/user.dart';

class ReviewsWidget extends StatelessWidget {
  final User user;

  const ReviewsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual reviews widget implementation
    return Center(
      child: Text('Reviews for ${user.name}'),
    );
  }
}