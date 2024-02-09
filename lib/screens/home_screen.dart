import 'package:flutter/material.dart';
import 'package:petapp/screens/auth/login_screen.dart';
import 'package:petapp/screens/messages/messages_screen.dart';
import 'package:petapp/screens/offer/offers_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:petapp/screens/profile/user_profile_screen.dart';
import 'package:petapp/storage/token_storage.dart';

class HomeScreen extends StatefulWidget {
  final String initialSection;

  const HomeScreen({super.key, this.initialSection = 'offers'});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  late final PageController _pageController;
  late bool _isLoggedIn = false;

  List<Widget> get _pages => [
    const OffersScreen(),
    const MessagesScreen(),
    _isLoggedIn ? const UserProfileScreen() : const LoginScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _selectedIndex = _getIndexForSection(widget.initialSection);
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    String? token = await TokenStorage.getToken();
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  int _getIndexForSection(String section) {
    switch (section) {
      case 'offers':
        return 0;
      case 'messages':
        return 1;
      case 'profile':
        return 2;
      default:
        return 0; // Default to the first tab
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index); // Jump to the selected page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: AppLocalizations.of(context)!.navigation_offers,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message),
            label: AppLocalizations.of(context)!.navigation_messages,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.navigation_profile,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
