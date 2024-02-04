import 'package:flutter/material.dart';
import 'package:petapp/models/user.dart'; // Ensure this import is correct based on your project structure

class UserProfileSection extends StatelessWidget {
  final User user;

  const UserProfileSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        user.avatarUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(user.avatarUrl!),
                radius: 20,
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
              ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(user.name),
            Row(
              children: List.generate(5, (index) {
                int rating = user.averageOfferRating?.round() ?? 0;
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: const Color.fromARGB(119, 3, 168, 244),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}
