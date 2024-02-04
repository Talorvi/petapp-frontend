// ignore_for_file: unused_field, unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:petapp/screens/login_screen.dart';
import 'package:petapp/services/api_service.dart';
import 'package:petapp/services/dialog_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  String _name = '';
  String _email = '';
  String _password = '';
  String _passwordConfirmation = '';
  Map<String, String> _formErrors = {};

  @override
  Widget build(BuildContext context) {
    ApiService().currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registrationScreen_title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!
                        .registrationScreen_nameField,
                    errorText: _formErrors[
                        'name'], // Display the error message for the name field
                    border: const OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_enterName;
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!
                      .registrationScreen_emailField,
                  errorText: _formErrors[
                      'email'], // Display the error message for the email field
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_enterEmail;
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_invalidEmail;
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  helperText: AppLocalizations.of(context)!
                      .registrationScreen_passwordHelper,
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!
                      .registrationScreen_passwordField,
                  errorText: _formErrors[
                      'password'], // Display the error message for the password field
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_enterPassword;
                  }
                  if (value.length < 6) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_passwordTooShort;
                  }
                  // Add more complexity checks if required
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordConfirmationController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)!
                      .registrationScreen_passwordConfirmationField,
                  errorText: _formErrors[
                      'password_confirmation'], // Display the error message for the password field
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_enterPasswordConfirmation;
                  }
                  if (value != _passwordController.text) {
                    return AppLocalizations.of(context)!
                        .registrationScreen_passwordMismatch;
                  }
                  return null;
                },
                onSaved: (value) => _passwordConfirmation = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(AppLocalizations.of(context)!
                    .registrationScreen_registerButton),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                },
                child: Text(
                  AppLocalizations.of(context)!.registrationScreen_loginButton,
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

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Check if all the form fields are valid
    if (_formKey.currentState!.validate()) {
      // Save the current state of the form
      _formKey.currentState!.save();

      // Retrieve the values from the TextEditingControllers
      String password = _passwordController.text;
      String passwordConfirmation = _passwordConfirmationController.text;

      // Call the performRegistration method with the form data
      _performRegistration(_name, _email, password, passwordConfirmation);
    }
  }

  void _clearForm() {
    // Clear the TextEditingController for each field
    _passwordController.clear();
    _passwordConfirmationController.clear();

    // Reset the form's state
    _formKey.currentState!.reset();

    _name = '';
    _email = '';
    _password = '';
    _passwordConfirmation = '';

    DialogService.showSuccessDialog(
        AppLocalizations.of(context)!.registrationScreen_registrationSuccessful,
        context);

    // Call setState to update the UI
    setState(() {});
  }

  void _performRegistration(String name, String email, String password,
      String passwordConfirmation) async {
    try {
      var response = await ApiService()
          .registerUser(name, email, password, passwordConfirmation);
      // Handle successful registration
      // print('Registration successful: $response');
      setState(() {
        _formErrors
            .clear(); // Clear any existing errors on successful registration
      });

      _clearForm();
    } catch (error) {
      if (error is Map<String, dynamic>) {
        // Handle validation errors
        setState(() {
          _formErrors = {};
          error.forEach((key, value) {
            _formErrors[key] = value[0];
          });
        });
      } else {
        // Handle other types of errors
        print('Error during registration: $error');
        setState(() {
          _formErrors.clear();
          // Optionally, set a general error message
          // _formErrors['general'] = 'An unexpected error occurred';
        });
      }
    }
  }
}
