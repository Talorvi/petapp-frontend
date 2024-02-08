import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petapp/models/user.dart'; // Assuming this is the path to your User model
import 'package:petapp/services/api_service.dart'; // Assuming this is the path to your API service
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with AutomaticKeepAliveClientMixin {
  User? user;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      var userInfo = await ApiService()
          .getUserInfo(context); // Implement getUserInfo in your ApiService
      setState(() {
        user = userInfo;
        _isUploading = false;
      });
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> _changeAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        setState(() {
          _isUploading = true;
        });
        // Call API to update avatar
        await ApiService().updateUserAvatar(image.path);
        _loadUserData(); // Reload user data to reflect the new avatar
        setState(() {
          _isUploading = false;
        });
        // ignore: use_build_context_synchronously
        ApiService.showSuccessToast(
            AppLocalizations.of(context)!.apiService_avatar_change_successful);
      } catch (exception) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiService().currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userProfileScreen_title),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_isUploading) const LinearProgressIndicator(),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: ClipOval(
                            child: user!.avatarUrl != null
                                ? Image.network(
                                    user!.avatarUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // White background color
                              shape: BoxShape.circle, // Circular shape
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 2), // Changes position of shadow
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: _changeAvatar,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user!.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user!.averageOfferRating != null)
                    Text(
                      'Average Rating: ${user!.averageOfferRating!.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ApiService().logoutUser(context, showToast: false);
                    },
                    child: Text(
                        AppLocalizations.of(context)!.userProfileScreen_logout),
                  ),
                  // Add more widgets here as per your requirement
                ],
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive =>
      true; // Keep state alive for AutomaticKeepAliveClientMixin
}
