import 'package:flutter/material.dart';
import 'package:petapp/enums/order_option.dart';
import 'package:petapp/enums/sort_option.dart';
import 'package:petapp/models/user.dart';
import 'package:petapp/screens/profile/profile_screen.dart';
import 'package:petapp/widgets/offers_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OffersScreen extends StatefulWidget {
  final Function(String? query, double? minimumRating, String? sortBy,
      String? sortDirection)? onSearchUpdated;

  const OffersScreen({super.key, this.onSearchUpdated});

  @override
  // ignore: library_private_types_in_public_api
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<OffersWidgetState> _offersWidgetKey =
      GlobalKey<OffersWidgetState>();
  String? _searchQuery;
  double? _minimumRating;
  String? _sortBy;
  String? _sortDirection;
  TextEditingController searchController = TextEditingController();
  List<String> ratingOptions = ['2.0', '3.0', '4.0', '4.5'];
  String? selectedRating;
  SortOption _selectedSort = SortOption.date;
  OrderOption _selectedOrder = OrderOption.desc;

void navigateToAddOfferScreen() async {
  _refreshOffers();
}

void _refreshOffers() {
  // Assuming OffersWidget takes a key or you can directly call a method to refresh
  _offersWidgetKey.currentState?.refreshOffers();
}

  void _showAdvancedSearch(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!
                          .offersScreen_searchByTextInput,
                      hintText: AppLocalizations.of(context)!
                          .offersScreen_enterSearchTermHint,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        AppLocalizations.of(context)!
                            .offersScreen_minimumRating,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: List<Widget>.generate(
                      ratingOptions.length,
                      (int index) {
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(ratingOptions[index]),
                              const SizedBox(
                                  width: 4), // Space between text and icon
                              const Icon(Icons.star_border,
                                  size: 16), // Outlined star icon
                            ],
                          ),
                          selected: selectedRating == ratingOptions[index],
                          onSelected: (bool selected) {
                            setState(() {
                              selectedRating =
                                  selected ? ratingOptions[index] : null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        AppLocalizations.of(context)!.offersScreen_sortBy,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  SegmentedButton<SortOption>(
                    segments: <ButtonSegment<SortOption>>[
                      ButtonSegment<SortOption>(
                        value: SortOption.date,
                        label: Text(
                            AppLocalizations.of(context)!.offersScreen_date),
                        icon: const Icon(Icons.date_range),
                      ),
                      ButtonSegment<SortOption>(
                        value: SortOption.rating,
                        label: Text(
                            AppLocalizations.of(context)!.offersScreen_rating),
                        icon: const Icon(Icons.star),
                      ),
                      ButtonSegment<SortOption>(
                        value: SortOption.price,
                        label: Text(
                            AppLocalizations.of(context)!.offersScreen_price),
                        icon: const Icon(Icons.attach_money),
                      ),
                    ],
                    selected: <SortOption>{_selectedSort},
                    onSelectionChanged: (Set<SortOption> newSelection) {
                      setState(() {
                        _selectedSort = newSelection.first;
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        AppLocalizations.of(context)!.offersScreen_order,
                        style: const TextStyle(fontSize: 16)),
                  ),
                  SegmentedButton<OrderOption>(
                    segments: <ButtonSegment<OrderOption>>[
                      ButtonSegment<OrderOption>(
                        value: OrderOption.desc,
                        label: Text(AppLocalizations.of(context)!
                            .offersScreen_descending),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment<OrderOption>(
                        value: OrderOption.asc,
                        label: Text(AppLocalizations.of(context)!
                            .offersScreen_ascending),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: <OrderOption>{_selectedOrder},
                    onSelectionChanged: (Set<OrderOption> newSelection) {
                      setState(() {
                        _selectedOrder = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context)!
                        .offersScreen_searchButton),
                    onPressed: () {
                      setState(() {
                        _searchQuery = searchController.text.isNotEmpty
                            ? searchController.text
                            : null;
                        _minimumRating = selectedRating != null
                            ? double.parse(selectedRating!)
                            : null;
                        _sortBy = _selectedSort == SortOption.date
                            ? 'updated_at'
                            : _selectedSort == SortOption.rating
                                ? 'rating'
                                : 'price';
                        _sortDirection =
                            _selectedOrder == OrderOption.asc ? 'asc' : 'desc';
                      });
                      _updateSearchCriteria();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateSearchCriteria() {
    setState(() {
      _searchQuery =
          searchController.text.isNotEmpty ? searchController.text : null;
      _minimumRating =
          selectedRating != null ? double.parse(selectedRating!) : null;
      _sortBy = _selectedSort == SortOption.date
          ? 'updated_at'
          : _selectedSort == SortOption.rating
              ? 'rating'
              : 'price'; // Add this line
      _sortDirection = _selectedOrder == OrderOption.asc ? 'asc' : 'desc';
    });
    // Pass the updated search criteria to the OffersWidget.
    if (widget.onSearchUpdated != null) {
      widget.onSearchUpdated!(
        _searchQuery,
        _minimumRating,
        _sortBy,
        _sortDirection,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navigation_offers),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showAdvancedSearch(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 8.0, right: 8.0), // Increased bottom padding
        child: OffersWidget(
          key: _offersWidgetKey,
          widgetKey: _offersWidgetKey,
          user: null,
          onProfileTap: (User user) {
            // Navigate to the profile screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(user: user),
              ),
            );
          },
          onSearchUpdated: (String? query, double? minimumRating,
              String? sortBy, String? sortDirection) {
            setState(() {
              _searchQuery = query;
              _minimumRating = minimumRating;
              _sortBy = sortBy;
              _sortDirection = sortDirection;
            });
          },
          // Pass the search criteria to the OffersWidget
          query: _searchQuery,
          minimumRating: _minimumRating,
          sortBy: _sortBy,
          sortDirection: _sortDirection,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToAddOfferScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive =>
      true; // Keep state alive for AutomaticKeepAliveClientMixin
}
