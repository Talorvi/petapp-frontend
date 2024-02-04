import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/screens/profile_screen.dart';
import 'package:petapp/widgets/user_profile_section.dart'; // Make sure this path matches your Offer model

class OfferDetailScreen extends StatefulWidget {
  final Offer offer;

  const OfferDetailScreen({super.key, required this.offer});

  @override
  // ignore: library_private_types_in_public_api
  _OfferDetailScreenState createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs for details and reviews
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.offer.title.toUpperCase()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOfferDetailsTab(context),
            _buildReviewsTab(context), // This will be updated to show reviews
          ],
        ),
      ),
    );
  }

Widget _buildOfferDetailsTab(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        widget.offer.imageUrl.isNotEmpty
            ? Image.network(
                widget.offer.imageUrl,
                fit: BoxFit.cover,
                height: 250,
              )
            : Container(
                height: 250,
                color: Colors.grey[300], // Placeholder color
                child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
              ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.offer.title.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.visible, // Change to `visible`
                    ),
                  ),
                  widget.offer.price != null
                      ? Text(
                          '${widget.offer.price} zł',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        )
                      : Container(),
                ],
              ),
              const Divider(),
              Text(
                widget.offer.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Divider(),
              _buildUserProfileSection(widget.offer),
              const Divider(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildReviewsTab(BuildContext context) {
    return const Center(
      child: Text("Reviews will be implemented here"),
    );
  }

  Widget _buildUserProfileSection(Offer offer) {
    return InkWell(
      onTap: () {
        // Directly navigate to the user profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(user: offer.user),
          ),
        );
      },
      child: Row(
        children: <Widget>[
          UserProfileSection(user: offer.user),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('dd-MM-yyyy – kk:mm').format(offer.updatedAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            // Implementation for contacting the seller
          },
          child: const Text('Contact Seller'),
        ),
      ],
    );
  }
}
