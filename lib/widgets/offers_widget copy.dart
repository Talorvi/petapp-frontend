// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:petapp/models/user.dart';
// import 'package:petapp/models/offer.dart';
// import 'package:petapp/services/api_service.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// // ignore: must_be_immutable
// class OffersWidget extends StatefulWidget {
//   final User? user;
//   final bool? isListView;
//   final Function(User)? onProfileTap;
//   final String? query;
//   final double? minimumRating;
//   final DateTime? fromDate;
//   final DateTime? toDate;
//   final String? sortBy;
//   final String? sortDirection;
//   Function(String? query, double? minimumRating, String? sortBy,
//       String? sortDirection)? onSearchUpdated;

//   OffersWidget({
//     super.key,
//     required this.user,
//     this.isListView,
//     this.onProfileTap,
//     this.query,
//     this.minimumRating,
//     this.fromDate,
//     this.toDate,
//     this.sortBy,
//     this.sortDirection,
//     this.onSearchUpdated,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _OffersWidgetState createState() => _OffersWidgetState();
// }

// class _OffersWidgetState extends State<OffersWidget> {
//   final ApiService _apiService = ApiService();
//   final List<Offer> _offers = [];
//   bool _isLoading = false;
//   int _currentPage = 1;
//   final ScrollController _scrollController = ScrollController();
//   bool _isEndOfList = false;
//   bool _hasError = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchOffers(
//       query: widget.query,
//       minimumRating: widget.minimumRating,
//       sortBy: widget.sortBy,
//       sortDirection: widget.sortDirection,
//     );
//     _scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       _fetchMoreOffers();
//     }
//   }

//   Future<void> _fetchOffers({
//     String? query,
//     double? minimumRating,
//     String? sortBy,
//     String? sortDirection,
//   }) async {
//     setState(() {
//       _isLoading = true;
//       _offers.clear();
//       _currentPage = 1;
//       _isEndOfList = false;
//     });

//     try {
//       List<Offer> offers = await _apiService.getOffers(
//           page: _currentPage,
//           query: query,
//           minimumRating: minimumRating,
//           sortBy: sortBy,
//           sortDirection: sortDirection,
//           userId: widget.user?.id);
//       setState(() {
//         _offers.addAll(offers);
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _hasError = true;
//         _errorMessage = e.toString(); // You can customize this message
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchMoreOffers() async {
//     if (!_isLoading && !_isEndOfList) {
//       setState(() {
//         _isLoading = true;
//       });
//       _currentPage++;
//       try {
//         List<Offer> moreOffers = await _apiService.getOffers(
//             page: _currentPage,
//             query: widget.query,
//             minimumRating: widget.minimumRating,
//             sortBy: widget.sortBy,
//             sortDirection: widget.sortDirection,
//             userId: widget.user?.id);
//         if (moreOffers.isEmpty) {
//           setState(() {
//             _isEndOfList = true;
//             _currentPage--;
//           });
//         } else {
//           setState(() {
//             _offers.addAll(moreOffers.where((offer) =>
//                 !_offers.any((existingOffer) => existingOffer.id == offer.id)));
//           });
//         }
//       } catch (e) {
//         _currentPage--;
//         setState(() {
//           _isLoading = false;
//           _hasError = true;
//           _errorMessage = e.toString(); // You can customize this message
//         });
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: () => _fetchOffers(
//         query: widget.query,
//         minimumRating: widget.minimumRating,
//         sortBy: widget.sortBy,
//         sortDirection: widget.sortDirection,
//       ),
//       child: ListView.builder(
//         itemCount: _offers.length + (_isLoading ? 1 : 0) + (_hasError ? 1 : 0),
//         controller: _scrollController,
//         padding:
//             EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 64),
//         itemBuilder: (context, index) {
//           if (index < _offers.length) {
//             return widget.isListView ?? false
//                 ? _buildOfferListItem(_offers[index])
//                 : _buildOfferCard(_offers[index]);
//           } else if (_isLoading && index == _offers.length) {
//             // Loading indicator
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: 10),
//               child: Center(child: CircularProgressIndicator()),
//             );
//           } else if (_hasError &&
//               index == _offers.length + (_isLoading ? 1 : 0)) {
//             // Error message and retry button
//             return _buildErrorWidget();
//           } else {
//             // Placeholder for the end of the list
//             return const SizedBox(height: 32);
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildOfferCard(Offer offer) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.only(top: 10),
//       child: InkWell(
//         onTap: () {
//           // Action for tapping the whole card
//           print("Whole Offer ${offer.title} clicked");
//         },
//         child: Column(
//           children: <Widget>[
//             // Image or placeholder
//             offer.imageUrl.isNotEmpty
//                 ? Image.network(
//                     offer.imageUrl,
//                     fit: BoxFit.cover,
//                     height: 200, // You can adjust the height
//                   )
//                 : SizedBox(
//                     height: 200,
//                     child: Card(
//                       color: Colors.grey[300], // Placeholder color
//                       child: Center(
//                         child: Icon(Icons.image,
//                             size: 50, color: Colors.grey[600]), // Optional icon
//                       ),
//                     ),
//                   ),

//             // Padding for the content below the image
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   // Title and Price
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Flexible(
//                         child: Text(
//                           offer.title.toUpperCase(),
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                           overflow: TextOverflow
//                               .ellipsis, // Prevents text from overflowing
//                         ),
//                       ),
//                       Text(
//                         offer.price != null ? '${offer.price} zł' : '',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   Text(offer.description),
//                   const SizedBox(height: 10),

//                   // User profile section
//                   InkWell(
//                     onTap: () {
//                       // Action for tapping the user profile
//                       widget.onProfileTap?.call(offer.user); // Add this line
//                     },
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(
//                           15), // Set the border radius here
//                       clipBehavior: Clip.hardEdge,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Flexible(
//                             flex: 1, // Occupies half of the space
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[
//                                 // User's avatar
//                                 offer.user.avatarUrl != null
//                                     ? CircleAvatar(
//                                         backgroundImage:
//                                             NetworkImage(offer.user.avatarUrl!),
//                                         radius: 20,
//                                       )
//                                     : Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[300],
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Icon(Icons.person,
//                                             size: 30, color: Colors.grey[600]),
//                                       ),
//                                 const SizedBox(width: 10),
//                                 // User's name
//                                 Flexible(
//                                   child: Text(
//                                     offer.user.name,
//                                     style: const TextStyle(fontSize: 12),
//                                     overflow: TextOverflow
//                                         .ellipsis, // Prevents text from overflowing
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Flexible(
//                             flex: 1, // Occupies the other half of the space
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[
//                                 // Rating section
//                                 offer.user.averageOfferRating != null
//                                     ? Row(
//                                         children: [
//                                           const Icon(Icons.star,
//                                               size: 20, color: Colors.amber),
//                                           Text(
//                                             ' ${offer.user.averageOfferRating!.toStringAsFixed(1)}',
//                                             style:
//                                                 const TextStyle(fontSize: 16),
//                                           ),
//                                         ],
//                                       )
//                                     : const Icon(Icons.star_border,
//                                         size: 20, color: Colors.grey),
//                                 // Date section
//                                 Flexible(
//                                   child: Text(
//                                     DateFormat('dd-MM-yyyy – kk:mm')
//                                         .format(offer.updatedAt),
//                                     style: const TextStyle(
//                                         fontSize: 12, color: Colors.grey),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOfferListItem(Offer offer) {
//     return ListTile(
//       leading: Container(
//         width: 50,
//         height: 50,
//         decoration: offer.imageUrl.isNotEmpty
//             ? BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(offer.imageUrl),
//                   fit: BoxFit.cover,
//                 ),
//               )
//             : BoxDecoration(
//                 color: Colors.grey[300],
//               ),
//         child: offer.imageUrl.isEmpty
//             ? Icon(Icons.image, size: 30, color: Colors.grey[600])
//             : null,
//       ),
//       title: Text(
//         offer.title.toUpperCase(),
//         style: const TextStyle(fontWeight: FontWeight.bold),
//         overflow: TextOverflow.ellipsis,
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             offer.description,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 5),
//           Row(
//             children: [
//               Text(
//                 DateFormat('dd-MM-YYYY – kk:mm').format(offer.updatedAt),
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               if (offer.user.averageOfferRating != null) ...[
//                 const SizedBox(width: 5),
//                 const Icon(Icons.star, size: 16, color: Colors.amber),
//                 Text(
//                   ' ${offer.user.averageOfferRating!.toStringAsFixed(1)}',
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//       trailing: Text(
//         offer.price != null ? '${offer.price} zł' : '',
//         style: const TextStyle(
//           fontSize: 16,
//           color: Colors.green,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       onTap: () {
//         // Action for tapping the list item
//         print("Offer ${offer.title} clicked");
//       },
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20), // Add spacing on top
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Error: $_errorMessage',
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20), // Spacing between text and button
//             ElevatedButton(
//               child: Text(AppLocalizations.of(context)!.offersWidget_retry),
//               onPressed: () {
//                 setState(() {
//                   _hasError = false;
//                   _errorMessage = '';
//                 });
//                 _fetchOffers(
//                   query: widget.query,
//                   minimumRating: widget.minimumRating,
//                   sortBy: widget.sortBy,
//                   sortDirection: widget.sortDirection,
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void didUpdateWidget(OffersWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Check if any of the search criteria have changed.
//     if (widget.query != oldWidget.query ||
//         widget.minimumRating != oldWidget.minimumRating ||
//         widget.sortBy != oldWidget.sortBy ||
//         widget.sortDirection != oldWidget.sortDirection) {
//       // If there's a change, fetch offers with the new criteria.
//       _fetchOffers(
//         query: widget.query,
//         minimumRating: widget.minimumRating,
//         sortBy: widget.sortBy,
//         sortDirection: widget.sortDirection,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
// }
