import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/services/api_service.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddOfferScreenState createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  int _currentStep = 0;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<XFile> _imageFiles = [];
  final _formKey = GlobalKey<FormState>();
  Offer? _createdOffer;
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Offer'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _getSteps(),
        type: StepperType.horizontal,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          final isBackButtonVisible = _currentStep == 1;
          bool isLastStep = _currentStep == _getSteps().length - 1;

          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                if (isBackButtonVisible)
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                const SizedBox(width: 8),
                if (_isSubmitting)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'Finish' : 'Next'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      _titleAndDescriptionStep(),
      _createOfferStep(),
      _imageUploadStep(),
    ];
  }

  Step _titleAndDescriptionStep() {
    return Step(
      title: const Text('Details'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Description is required' : null,
              maxLines: 6,
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
    );
  }

  Step _createOfferStep() {
    return Step(
      title: const Text('Create Offer'),
      content: _createdOffer != null
          ? Text('Offer created: ${_createdOffer!.title}')
          : Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Ready to create offer'),
            ),
      isActive: _currentStep >= 1,
    );
  }

  Step _imageUploadStep() {
    return Step(
      title: const Text('Images'),
      content: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Prevents grid from scrolling inside the stepper
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              childAspectRatio: 1, // Ensures square cells
            ),
            itemCount: _imageFiles.length + 1, // +1 for the add button
            itemBuilder: (context, index) {
              if (index < _imageFiles.length) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(_imageFiles[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () =>
                            setState(() => _imageFiles.removeAt(index)),
                      ),
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  onPressed: _imageFiles.length < 10 ? _pickImage : null,
                );
              }
            },
          ),
          if (_imageFiles.length == 10)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Maximum of 10 images can be uploaded.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      isActive: _currentStep >= 2,
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFiles.add(image);
      });
    }
  }

  void _onStepContinue() async {
    final isLastStep = _currentStep == _getSteps().length - 1;
    if (_currentStep == 0 && _formKey.currentState!.validate()) {
      setState(() {
        _currentStep += 1;
      });
    } else if (_currentStep == 1 && !isLastStep) {
      if (!_isSubmitting) {
        setState(() {
          _isSubmitting = true;
        });
        try {
          final createdOffer = await _apiService.createOffer(
            _titleController.text,
            _descriptionController.text,
            null, // Assuming price is null for simplicity
          );
          setState(() {
            _createdOffer = createdOffer;
            _currentStep += 1;
          });
        } catch (e) {
          // ignore: use_build_context_synchronously
          _showErrorDialog(context, e.toString());
        } finally {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } else if (_currentStep == 2 && isLastStep && _createdOffer != null) {
      if (!_isSubmitting && _imageFiles.isNotEmpty) {
        setState(() {
          _isSubmitting = true;
        });
        try {
          await _apiService.uploadOfferImages(_createdOffer!.id, _imageFiles);
          // ignore: use_build_context_synchronously
          _showSuccessDialog(context, 'Images uploaded successfully!');
        } catch (e) {
          // ignore: use_build_context_synchronously
          _showErrorDialog(context, e.toString());
        } finally {
          setState(() {
            _isSubmitting = false;
          });
        }
      } else {
        Navigator.of(context)
            .pop(true); // Close the screen if no images to upload or finished uploading
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Close the AddOfferScreen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
