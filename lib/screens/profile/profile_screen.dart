import 'package:flutter/material.dart';
import 'package:petapp/models/user.dart';
import 'package:petapp/widgets/offers_widget.dart';
import 'package:petapp/widgets/user_reviews_widget.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedSegment = 'Offers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            Center(
              child: widget.user.avatarUrl != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(widget.user.avatarUrl!),
                      radius: 60,
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.person, size: 60, color: Colors.grey[600]),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // This makes the Row only as wide as its children
                children: List.generate(5, (index) {
                  int rating = widget.user.averageOfferRating?.round() ?? 0;
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: const Color.fromARGB(119, 3, 168, 244),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'Offers',
                    label: Text('Offers'),
                  ),
                  ButtonSegment<String>(
                    value: 'Reviews',
                    label: Text('Reviews'),
                  ),
                ],
                selected: <String>{selectedSegment},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedSegment = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: selectedSegment == 'Offers'
                  ? OffersWidget(
                      user: widget.user,
                      isListView: true, 
                      widgetKey: null,
                    )
                  : UserReviewsWidget(
                      user: widget.user,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
