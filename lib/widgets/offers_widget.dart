import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petapp/models/user.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/screens/offer/offer_detail_screen.dart';
import 'package:petapp/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:petapp/widgets/user_profile_section.dart';

// ignore: must_be_immutable
class OffersWidget extends StatefulWidget {
  final User? user;
  final bool? isListView;
  final Function(User)? onProfileTap;
  final String? query;
  final double? minimumRating;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? sortBy;
  final String? sortDirection;
  Function(String? query, double? minimumRating, String? sortBy,
      String? sortDirection)? onSearchUpdated;

  OffersWidget({
    super.key,
    required this.user,
    this.isListView,
    this.onProfileTap,
    this.query,
    this.minimumRating,
    this.fromDate,
    this.toDate,
    this.sortBy,
    this.sortDirection,
    this.onSearchUpdated, 
    required GlobalKey<OffersWidgetState>? widgetKey,
  });

  @override
  // ignore: library_private_types_in_public_api
  OffersWidgetState createState() => OffersWidgetState();
}

class OffersWidgetState extends State<OffersWidget> {
  final ApiService _apiService = ApiService();
  final List<Offer> _offers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isEndOfList = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOffers(
      query: widget.query,
      minimumRating: widget.minimumRating,
      sortBy: widget.sortBy,
      sortDirection: widget.sortDirection,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreOffers();
    }
  }

  void refreshOffers() {
    _fetchOffers();
  }

  Future<void> _fetchOffers({
    String? query,
    double? minimumRating,
    String? sortBy,
    String? sortDirection,
  }) async {
    setState(() {
      _isLoading = true;
      _offers.clear();
      _currentPage = 1;
      _isEndOfList = false;
    });

    try {
      List<Offer> offers = await _apiService.getOffers(
          page: _currentPage,
          query: query,
          minimumRating: minimumRating,
          sortBy: sortBy,
          sortDirection: sortDirection,
          userId: widget.user?.id);
      setState(() {
        _offers.addAll(offers);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString(); // You can customize this message
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreOffers() async {
    if (!_isLoading && !_isEndOfList) {
      setState(() {
        _isLoading = true;
      });
      _currentPage++;
      try {
        List<Offer> moreOffers = await _apiService.getOffers(
            page: _currentPage,
            query: widget.query,
            minimumRating: widget.minimumRating,
            sortBy: widget.sortBy,
            sortDirection: widget.sortDirection,
            userId: widget.user?.id);
        if (moreOffers.isEmpty) {
          setState(() {
            _isEndOfList = true;
            _currentPage--;
          });
        } else {
          setState(() {
            _offers.addAll(moreOffers.where((offer) =>
                !_offers.any((existingOffer) => existingOffer.id == offer.id)));
          });
        }
      } catch (e) {
        _currentPage--;
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString(); // You can customize this message
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _fetchOffers(
        query: widget.query,
        minimumRating: widget.minimumRating,
        sortBy: widget.sortBy,
        sortDirection: widget.sortDirection,
      ),
      child: ListView.builder(
        itemCount: _offers.length + (_isLoading ? 1 : 0) + (_hasError ? 1 : 0),
        controller: _scrollController,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 64),
        itemBuilder: (context, index) {
          if (index < _offers.length) {
            return widget.isListView ?? false
                ? _buildOfferListItem(_offers[index])
                : _buildOfferCard(_offers[index]);
          } else if (_isLoading && index == _offers.length) {
            // Loading indicator
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (_hasError &&
              index == _offers.length + (_isLoading ? 1 : 0)) {
            // Error message and retry button
            return _buildErrorWidget();
          } else {
            // Placeholder for the end of the list
            return const SizedBox(height: 32);
          }
        },
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 10, left: 0, right: 0, bottom: 0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10), // Set the border radius of the card
      ),
      child: InkWell(
        onTap: () {
          // Action for tapping the whole card
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => OfferDetailScreen(offer: offer)));
        },
        child: Column(
          children: <Widget>[
            // Image or placeholder with rounded corners
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10)), // Match the card's border radius
              child: offer.images.isNotEmpty
                  ? Image.network(
                      offer.images[0],
                      fit: BoxFit.cover,
                      width: double.infinity, // Set width to fill the card
                      height: 200, // Adjust the height as needed
                    )
                  : Container(
                      width: double.infinity, // Set width to fill the card
                      height: 200,
                      color: Colors.grey[300], // Placeholder color
                      child: Center(
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey[600]),
                      ),
                    ),
            ),

            // Padding for the content below the image
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          offer.title.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        offer.price != null ? '${offer.price} zł' : '',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      int rating = offer.averageRating?.round() ?? 0;
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: const Color.fromARGB(119, 3, 168, 244),
                      );
                    }),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _trimDescription(offer.description),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(),

                  // User profile section
                  InkWell(
                    onTap: () {
                      // Action for tapping the user profile
                      widget.onProfileTap?.call(offer.user);
                    },
                    child: Row(
                      children: <Widget>[
                        UserProfileSection(user: offer.user),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              DateFormat('dd-MM-yyyy – kk:mm')
                                  .format(offer.updatedAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferListItem(Offer offer) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: offer.images.isNotEmpty
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(offer.images[0]),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(
                color: Colors.grey[300],
              ),
        child: offer.images.isEmpty
            ? Icon(Icons.image, size: 30, color: Colors.grey[600])
            : null,
      ),
      title: Text(
        offer.title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            offer.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                DateFormat('dd-MM-yyyy – kk:mm').format(offer.updatedAt),
                style: const TextStyle(fontSize: 12, color: Color.fromARGB(119, 3, 168, 244)),
              ),
              if (offer.user.averageOfferRating != null) ...[
                const SizedBox(width: 5),
                const Icon(Icons.star, size: 16, color: Color.fromARGB(119, 3, 168, 244)),
                Text(
                  ' ${offer.user.averageOfferRating!.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Text(
        offer.price != null ? '${offer.price} zł' : '',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // Action for tapping the list item
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer)));
      },
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 20), // Add spacing on top
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Spacing between text and button
            ElevatedButton(
              child: Text(AppLocalizations.of(context)!.offersWidget_retry),
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
                _fetchOffers(
                  query: widget.query,
                  minimumRating: widget.minimumRating,
                  sortBy: widget.sortBy,
                  sortDirection: widget.sortDirection,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(OffersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if any of the search criteria have changed.
    if (widget.query != oldWidget.query ||
        widget.minimumRating != oldWidget.minimumRating ||
        widget.sortBy != oldWidget.sortBy ||
        widget.sortDirection != oldWidget.sortDirection) {
      // If there's a change, fetch offers with the new criteria.
      _fetchOffers(
        query: widget.query,
        minimumRating: widget.minimumRating,
        sortBy: widget.sortBy,
        sortDirection: widget.sortDirection,
      );
    }
  }

  String _trimDescription(String description) {
    const int maxLength = 200;
    if (description.length > maxLength) {
      return '${description.substring(0, maxLength)}...';
    }
    return description;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
