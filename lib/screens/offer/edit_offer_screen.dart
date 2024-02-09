import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petapp/models/offer.dart';
import 'package:petapp/services/api_service.dart';

class EditOfferScreen extends StatefulWidget {
  final Offer offer;

  const EditOfferScreen({super.key, required this.offer});

  @override
  // ignore: library_private_types_in_public_api
  _EditOfferScreenState createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends State<EditOfferScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<XFile> _newImageFiles = [];
  final List<String> _existingImageUrls = [];
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.offer.title;
    _descriptionController.text = widget.offer.description;
    _existingImageUrls
        .addAll(widget.offer.images); // Assuming offer.images is a list of URLs
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImageFiles.add(image);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  void _removeExistingImage(String imageUrl) async {
    final imageName =
        imageUrl.split('/').last; // Extract the image name from URL
    try {
      await _apiService.deleteOfferImage(widget.offer.id, imageName);
      setState(() {
        _existingImageUrls.remove(imageUrl);
      });
    } catch (e) {
      _showErrorDialog('Failed to delete image: $e');
    }
  }

  Future<void> _updateOffer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        await _apiService.updateOffer(
          widget.offer.id,
          _titleController.text,
          _descriptionController.text,
          // Add other details as needed, such as 'price'
        );

        // Assuming _existingImageUrls initially contains all images,
        // and any removals are already handled by _removeExistingImage.

        // Upload new images
        if (_newImageFiles.isNotEmpty) {
          await _apiService.uploadOfferImages(widget.offer.id, _newImageFiles);
        }

        // ignore: use_build_context_synchronously
        Navigator.pop(context, true); // Indicate success and go back
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Offer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 20),
                Text('Images', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _existingImageUrls
                          .map((imageUrl) => Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.network(imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeExistingImage(imageUrl),
                                  ),
                                ],
                              ))
                          .toList() +
                      _newImageFiles
                          .map((file) => Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.file(File(file.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => _removeNewImage(
                                        _newImageFiles.indexOf(file)),
                                  ),
                                ],
                              ))
                          .toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Image'),
                ),
                const SizedBox(height: 20),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _updateOffer,
                        child: const Text('Update Offer'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
