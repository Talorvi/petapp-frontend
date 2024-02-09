// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:petapp/screens/home_screen.dart';
import 'package:petapp/screens/auth/registration_screen.dart';
import 'package:petapp/services/api_service.dart';
import 'package:petapp/services/dialog_service.dart';
import 'package:petapp/storage/token_storage.dart';
// import your ApiService here

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  final Map<String, String> _formErrors = {};

  @override
  Widget build(BuildContext context) {
    ApiService().currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loginScreen_title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.loginScreen_emailField,
                  errorText: _formErrors['email'],
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.loginScreen_enterEmail;
                  }
                  if (!RegExp(r'\S+@\S+.\S+').hasMatch(value)) {
                    return AppLocalizations.of(context)!
                        .loginScreen_invalidEmail;
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.loginScreen_passwordField,
                  errorText: _formErrors['password'],
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .loginScreen_enterPassword;
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child:
                    Text(AppLocalizations.of(context)!.loginScreen_loginButton),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegistrationScreen()));
                },
                child: Text(
                  AppLocalizations.of(context)!.loginScreen_signupButton,
                  style: TextStyle(
                    color: Theme.of(context)
                        .primaryColor, // Use the primary color of the app
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Call the login method with the form data
      _performLogin(_email, _password);
      // Handle the response (e.g., navigate to another screen or show error message)
    }
  }

  void _performLogin(String email, String password) async {
    try {
      var response = await ApiService().loginUser(email, password);
      var token = response['token'];
      await TokenStorage.saveToken(token);

      // ignore: use_build_context_synchronously
      var user = await ApiService().getUserInfo(context);
      await TokenStorage.saveUser(user);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomeScreen(initialSection: 'offers')));
    } catch (error) {
      // Handle errors during login
      setState(() {
        _formErrors.clear();
        if (error is String) {
          if (error == 'Invalid credentials') {
            DialogService.showErrorDialog(
                AppLocalizations.of(context)!.loginScreen_invalidCredentials,
                context);
          } else if (error == 'Failed to log in') {
            DialogService.showErrorDialog(
                AppLocalizations.of(context)!.loginScreen_unauthorized,
                context);
          }
        } else if (error is Map<String, dynamic>) {
          error.forEach((key, value) {
            _formErrors[key] = value[0];
          });
        } else {
          DialogService.showErrorDialog(
              AppLocalizations.of(context)!.loginScreen_generalError, context);
        }
      });
    }
  }
}
