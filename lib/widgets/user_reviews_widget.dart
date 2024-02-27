import 'package:flutter/material.dart';
import 'package:petapp/models/user.dart';

class UserReviewsWidget extends StatelessWidget {
  final User user;

  const UserReviewsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual reviews widget implementation
    return Center(
      child: Text('Reviews for ${user.name}'),
    );
  }
}