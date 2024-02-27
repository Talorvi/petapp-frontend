// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/screens/offer/edit_offer_screen.dart';
import 'package:petapp/screens/profile/profile_screen.dart';
import 'package:petapp/services/api_service.dart';
import 'package:petapp/storage/token_storage.dart';
import 'package:petapp/widgets/offers_widget.dart';
import 'package:petapp/widgets/reviews_view_widget.dart';
import 'package:petapp/widgets/reviews_widget.dart';
import 'package:petapp/widgets/user_profile_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class OfferDetailScreen extends StatefulWidget {
  Offer offer; // Make it non-final

  OfferDetailScreen({super.key, required this.offer});

  @override
  // ignore: library_private_types_in_public_api
  _OfferDetailScreenState createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  final GlobalKey<OffersWidgetState> _offersWidgetKey =
      GlobalKey<OffersWidgetState>();
  String? _loggedInUserId;
  final CarouselController _carouselController = CarouselController();
  int _currentCarouselPage = 0;
  bool _needToRefresh = false;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              // Custom back button action
              Navigator.pop(context,
                  _needToRefresh); // Pop with a flag indicating the need to refresh
            },
          ),
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

  Future<void> fetchUpdatedOffer() async {
    try {
      // Assuming ApiService has a method to fetch a single offer by ID
      Offer updatedOffer = await ApiService().getOfferById(widget.offer.id);
      setState(() {
        widget.offer =
            updatedOffer; // Update the offer object with the fetched one
      });
    } catch (error) {
      // Handle any errors, such as showing a message to the user
      print("Error fetching updated offer: $error");
    }
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
                        enableInfiniteScroll: false,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
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
                        style: Theme.of(context).textTheme.headlineSmall,
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
                      color: const Color.fromARGB(119, 3, 168, 244),
                    );
                  }),
                ),
                const Divider(),
                Text(
                  widget.offer.description,
                  style: Theme.of(context).textTheme.bodyMedium,
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
    return ReviewsListWidget(offerId: widget.offer.id);
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

    // Function to show a loading indicator
    void showLoadingDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // User must tap button to dismiss
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Removing offer...'),
                ),
              ],
            ),
          );
        },
      );
    }

    if (isOwner) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditOfferScreen(
                            offer: widget.offer,
                          )));
              if (!_needToRefresh) {
                _needToRefresh = result ?? false;
              }
              // Refresh the offers list after editing the offer
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_offersWidgetKey.currentState != null) {
                  _offersWidgetKey.currentState!.refreshOffers();
                }
              });
              fetchUpdatedOffer();
            },
            child:
                Text(AppLocalizations.of(context)!.offerDetailScreen_editOffer),
          ),
          ElevatedButton(
            onPressed: () async {
              // Confirm dialog before removing the offer
              bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!
                            .offerDetailScreen_removeOfferDialogTitle),
                        content: Text(AppLocalizations.of(context)!
                            .offerDetailScreen_removeOfferDialogMessage),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context)!
                                .offerDetailScreen_cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: Text(AppLocalizations.of(context)!
                                .offerDetailScreen_confirm),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false;

              if (confirm) {
                showLoadingDialog(); // Show loading dialog
                try {
                  // Call API to delete the offer
                  await ApiService().deleteOffer(widget.offer.id);
                  Navigator.of(context).pop(); // Dismiss the loading dialog
                  Navigator.of(context)
                      .pop(true); // Close the detail screen and signal success
                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   if (_offersWidgetKey.currentState != null) {
                  //     _offersWidgetKey.currentState!.refreshOffers();
                  //   }
                  // });
                } catch (e) {
                  Navigator.of(context)
                      .pop(); // Ensure loading dialog is dismissed on error
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .offerDetailScreen_cancelOfferError)));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
                AppLocalizations.of(context)!.offerDetailScreen_removeOffer,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    } else if (_loggedInUserId != null) {
      // Viewer's view: Show Send Message button if the user is logged in and not the owner
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // TODO: Implementation for contacting the seller
            },
            child: Text(
                AppLocalizations.of(context)!.offerDetailScreen_sendMessage),
          ),
        ],
      );
    } else {
      // Return an empty Container if none of the conditions are met (e.g., not logged in)
      return Container();
    }
  }

  void _openImageFullscreen(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.white,
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
