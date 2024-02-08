import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/screens/profile_screen.dart';
import 'package:petapp/storage/token_storage.dart';
import 'package:petapp/widgets/user_profile_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfferDetailScreen extends StatefulWidget {
  final Offer offer;

  const OfferDetailScreen({super.key, required this.offer});

  @override
  // ignore: library_private_types_in_public_api
  _OfferDetailScreenState createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  String? _loggedInUserId;
  final CarouselController _carouselController = CarouselController();
  int _currentCarouselPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUserId();
  }

  Future<void> _fetchLoggedInUserId() async {
    final userId = await TokenStorage.getUserId();
    setState(() {
      _loggedInUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs for details and reviews
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.offer.title.toUpperCase()),
          bottom: TabBar(
            tabs: [
              Tab(
                  text:
                      AppLocalizations.of(context)!.offerDetailScreen_details),
              Tab(
                  text:
                      AppLocalizations.of(context)!.offerDetailScreen_reviews),
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
          widget.offer.images.isNotEmpty
              ? Column(
                  children: [
                    CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: 250.0,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentCarouselPage = index;
                          });
                        },
                        // Other options as needed
                      ),
                      items: widget.offer.images.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () => _openImageFullscreen(imageUrl),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.offer.images.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              _carouselController.animateToPage(entry.key),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(_currentCarouselPage == entry.key
                                      ? 0.9
                                      : 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                        style: Theme.of(context).textTheme.headline5,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    widget.offer.price != null
                        ? Text(
                            '${widget.offer.price} zł',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          )
                        : Container(),
                  ],
                ),
                Row(
                  children: List.generate(5, (index) {
                    int rating = widget.offer.averageRating?.round() ?? 0;
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
                const Divider(),
                Text(
                  widget.offer.description,
                  style: Theme.of(context).textTheme.bodyText2,
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
    // Check if the logged-in user is the owner of the offer
    bool isOwner = _loggedInUserId == widget.offer.user.id.toString();

    // Owner's view: Show Edit Offer button
    if (isOwner) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Implementation for editing the offer
            },
            child:
                Text(AppLocalizations.of(context)!.offerDetailScreen_editOffer),
          ),
        ],
      );
    }

    // Viewer's view: Show Send Message button if the user is logged in and not the owner
    else if (_loggedInUserId != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Implementation for contacting the seller
            },
            child: Text(
                AppLocalizations.of(context)!.offerDetailScreen_sendMessage),
          ),
        ],
      );
    }

    // Return an empty Container if none of the conditions are met (e.g., not logged in)
    return Container();
  }

  void _openImageFullscreen(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: false, // Set it to false to prevent panning.
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
