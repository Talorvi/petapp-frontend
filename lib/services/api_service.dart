import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/models/user.dart';
import 'package:petapp/screens/home_screen.dart';
import 'package:petapp/storage/token_storage.dart';

class ApiService {
  Locale? currentLocale;

  final String baseAddress;
  late final String baseUrl;

  //ApiService({this.baseAddress = '51.20.76.225'}) {
  ApiService({this.baseAddress = 'localhost'}) {
    baseUrl = 'http://$baseAddress:8080/api';
  }

  void logoutUser(BuildContext context, {bool showToast = true}) async {
    await TokenStorage.deleteToken();
    await TokenStorage.deleteUser();

    if (showToast) {
      showErrorToast('Session expired. Please log in again.');
    }

    // Navigating to the HomeScreen and refreshing the state
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const HomeScreen(initialSection: 'offers'),
    ));
  }

  Future<List<User>> getUsers({int page = 1}) async {
    var url = Uri.parse('$baseUrl/users?page=$page');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      List<dynamic> usersData = body['data']; // Extract the 'data' list
      List<User> users =
          usersData.map((dynamic item) => User.fromJson(item)).toList();
      return users;
    } else {
      throw Exception("Can't get users. Status code: ${response.statusCode}");
    }
  }

  // Method to register a new user
  Future<Map<String, dynamic>> registerUser(String name, String email,
      String password, String passwordConfirmation) async {
    var url = Uri.parse('$baseUrl/register');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept-Language': _getLocale(),
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 422) {
      // Validation error
      final errors = jsonDecode(response.body)['messages'];
      throw errors;
    } else if (response.statusCode == 401) {
      // Unauthorized
      throw 'Unauthorized access';
    } else {
      // Other errors
      throw 'Failed to register user';
    }
  }

  // Method to login a user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    var url = Uri.parse('$baseUrl/login');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept-Language': _getLocale()
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful login
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Unauthorized or login failure
      throw 'Invalid credentials'; // Customize this message as needed
    } else {
      // Other errors
      throw 'Failed to log in';
    }
  }

  // Method to fetch the offers
  Future<List<Offer>> getOffers({
    int page = 1,
    String? query,
    String? userId,
    double? minimumRating,
    String? sortBy,
    String? sortDirection,
  }) async {
    // Build the query parameters
    final queryParams = {
      'page': page.toString(),
      if (query != null) 'query': query,
      if (userId != null) 'user_id': userId,
      if (minimumRating != null) 'minimum_rating': minimumRating.toString(),
      if (sortBy != null && ['date', 'rating', 'price'].contains(sortBy))
        'sort_by': sortBy,
      if (sortDirection != null) 'sort_direction': sortDirection,
    };

    var url =
        Uri.parse('$baseUrl/offers').replace(queryParameters: queryParams);
    var response = await http.get(url, headers: {
      'Accept-Language': _getLocale(),
    });

    if (response.statusCode == 200) {
      try {
        var body = jsonDecode(response.body);
        List<dynamic> offersData = body['data']; // Extract the 'data' list
        List<Offer> offers = offersData
            .map((dynamic item) {
              try {
                return Offer.fromJson(item);
              } catch (e) {
                // Handle the error or log it
                // ignore: avoid_print
                print('Error parsing offer: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<Offer>()
            .toList();
        return offers;
      } catch (e) {
        // Handle the error or log it
        throw Exception("Error parsing offers: $e");
      }
    } else {
      throw Exception("Can't get offers. Status code: ${response.statusCode}");
    }
  }

  Future<User> getUserInfo(BuildContext context, {String? userId}) async {
    String url;
    if (userId != null) {
      url = '$baseUrl/user/$userId';
    } else {
      url = '$baseUrl/user/me'; // Endpoint that relies on bearer token
    }

    // Fetch the token directly
    String? token = await TokenStorage.getToken();

    // Create headers with the token
    var headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      'Accept-Language': _getLocale(),
    };

    var response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      // ignore: use_build_context_synchronously
      logoutUser(context);
      throw Exception("Unauthorized access. User has been logged out.");
    } else {
      // Handle errors
      throw Exception('Failed to load user data');
    }
  }

  Future<void> updateUserAvatar(String filePath) async {
    String url = '$baseUrl/user/avatar';
    String? token = await TokenStorage.getToken();

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll({
        'Content-Type': 'multipart/form-data',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept-Language': _getLocale(),
      })
      ..files.add(await http.MultipartFile.fromPath('avatar', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      var responseBody = jsonDecode(response.body);
      String errorMessage = _extractErrorMessage(responseBody);
      showErrorToast(errorMessage);
      throw Exception(
          'Failed to upload avatar. Status code: ${response.statusCode}');
    }
  }

  Future<Offer> createOffer(
      String title, String description, String? price) async {
    var url = Uri.parse('$baseUrl/offers');
    var token = await TokenStorage.getToken();
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': _getLocale(),
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      return Offer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create offer');
    }
  }

  Future<void> uploadOfferImages(String offerId, List<XFile> images) async {
    var url = Uri.parse('$baseUrl/offers/$offerId/images');
    var token = await TokenStorage.getToken();
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept-Language': _getLocale(),
      });

    for (var image in images) {
      request.files
          .add(await http.MultipartFile.fromPath('images[]', image.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Failed to upload images');
    }
  }

  String _getLocale() {
    return currentLocale?.toLanguageTag() ?? 'en';
  }

  String _extractErrorMessage(dynamic responseBody) {
    if (responseBody is Map<String, dynamic> &&
        responseBody.containsKey('messages')) {
      Map<String, dynamic> messages = responseBody['messages'];
      if (messages.isNotEmpty) {
        // Concatenate all error messages
        return messages.values.expand((x) => x as Iterable).join('\n');
      }
    }
    return 'An unknown error occurred';
  }

  static void showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  // Add other API interactions here, like POST, PUT, DELETE methods
}
