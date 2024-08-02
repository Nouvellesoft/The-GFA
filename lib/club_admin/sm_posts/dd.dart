import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc_navigation_bloc/navigation_bloc.dart';

Color backgroundColor = const Color.fromRGBO(235, 238, 239, 1.0);

class MyAddClubSponsorPage extends StatefulWidget implements NavigationStates {
  final String clubId;
  const MyAddClubSponsorPage({super.key, required this.clubId});

  @override
  State<MyAddClubSponsorPage> createState() => MyAddClubSponsorPageState();
}

class MyAddClubSponsorPageState extends State<MyAddClubSponsorPage> {
  // Define variables to store form input
  final TextEditingController _sponsorNameController = TextEditingController();
  final TextEditingController _clubSponsoringSummaryController = TextEditingController();

  String? sponsorName;

  bool _isSubmitting = false;

  // Create a GlobalKey for the form
  final _formKey = GlobalKey<FormState>();

  // Firebase Firestore instance
  final firestore = FirebaseFirestore.instance;

  // Function to check if a member with the same name exists
  Future<bool> doesNameExist(String fullName, String collectionName) async {
    final querySnapshot = await firestore.collection('clubs').doc(widget.clubId).collection(collectionName).where('name', isEqualTo: fullName).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Map<String, dynamic> data = {
    'id': '10',
    'about_us': '',
    'address': '',
    'category': '',
    'email': '',
    'facebook': '',
    'image':
        'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/ClubSponsors%2Fclub_sponsor_default.jpeg?alt=media&token=20a8e9c6-b2dd-413a-9bbc-cc189d7bfe9f',
    'image_two':
        'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/ClubSponsors%2Fclub_sponsor_default.jpeg?alt=media&token=20a8e9c6-b2dd-413a-9bbc-cc189d7bfe9f',
    'image_three':
        'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/ClubSponsors%2Fclub_sponsor_default.jpeg?alt=media&token=20a8e9c6-b2dd-413a-9bbc-cc189d7bfe9f',
    'image_four':
        'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/ClubSponsors%2Fclub_sponsor_default.jpeg?alt=media&token=20a8e9c6-b2dd-413a-9bbc-cc189d7bfe9f',
    'image_five':
        'https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/ClubSponsors%2Fclub_sponsor_default.jpeg?alt=media&token=20a8e9c6-b2dd-413a-9bbc-cc189d7bfe9f',
    'instagram': '',
    'name': '',
    'our_services': '',
    'phone': '',
    'snapchat': '',
    'sponsor_icon': '',
    'twitter': '',
    'website': '',
    'youtube': '',
  };

  // Implement a function to handle form submission
  _submitForm() async {
    if (_formKey.currentState!.validate() && !_isSubmitting) {
      setState(() {
        _isSubmitting = true; // Start submitting
      });
      final firestore = FirebaseFirestore.instance;
      sponsorName = _sponsorNameController.text;
      final clubSponsorSummary = _clubSponsoringSummaryController.text;

      String collectionName = 'ClubSponsors';

      // Check if the name already exists
      bool nameExists = await doesNameExist(sponsorName!, collectionName);

      if (nameExists) {
        // Show error toast
        _showErrorToast('Sponsor name already exists.');
        setState(() {
          _isSubmitting = false; // Stop submitting
        });
        return;
      }

      // Update the data values
      data['name'] = sponsorName;
      data['about_us'] = clubSponsorSummary;

      try {
        if (collectionName.isNotEmpty) {
          /// Add the new member if the name doesn't exist
          DocumentReference newSponsorRef = await firestore.collection('clubs').doc(widget.clubId).collection(collectionName).add(data);

          // Check if images are selected before calling _uploadAndSaveImages
          if (_imageOne != null || _imageTwo != null || _imageThree != null || _imageFour != null || _imageFive != null) {
            // Upload and update images
            await _uploadAndSaveImages(newSponsorRef.id);
          }

          // Show success toast
          _showSuccessToast();

          // Update UI to reflect changes
          setState(() {
            _sponsorNameController.clear();
            _clubSponsoringSummaryController.clear();

            // Reset images to null
            _imageOne = null;
            _imageTwo = null;
            _imageThree = null;
            _imageFour = null;
            _imageFive = null;

            _isSubmitting = false; // Stop submitting
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unsupported role: $collectionName'),
              ),
            );
          }
          // Update UI to stop submitting
          setState(() {
            _isSubmitting = false;
          });
        }
      } catch (e) {
        // Show error toast
        _showErrorToast(e.toString());
        // Update UI to stop submitting
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  ////

  final ImagePicker _picker = ImagePicker();
  File? _imageOne;
  File? _imageTwo;
  File? _imageThree;
  File? _imageFour;
  File? _imageFive;

  Future<void> _uploadAndSaveImages(String documentId) async {
    try {
      String? imageUrlOne = _imageOne != null ? await _uploadImageToStorage(_imageOne!, 'image_one.jpg') : null;
      String? imageUrlTwo = _imageTwo != null ? await _uploadImageToStorage(_imageTwo!, 'image_two.jpg') : null;
      String? imageUrlThree = _imageThree != null ? await _uploadImageToStorage(_imageThree!, 'image_three.jpg') : null;
      String? imageUrlFour = _imageFour != null ? await _uploadImageToStorage(_imageFour!, 'image_four.jpg') : null;
      String? imageUrlFive = _imageFive != null ? await _uploadImageToStorage(_imageFive!, 'image_five.jpg') : null;

      // Update Firestore document with image URLs
      await firestore.collection('clubs').doc(widget.clubId).collection('ClubSponsors').doc(documentId).update({
        'image': imageUrlOne ?? data['image'],
        'image_two': imageUrlTwo ?? data['image_two'],
        'image_three': imageUrlThree ?? data['image_three'],
        'image_four': imageUrlFour ?? data['image_four'],
        'image_five': imageUrlFive ?? data['image_five'],
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading images: $e');
      }
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile, String imageName) async {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('${widget.clubId}/club_sponsor_images').child(sponsorName!).child(imageName);
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() {});
      final String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }

  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    return File(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _sponsorNameController,
                decoration: const InputDecoration(labelText: 'Sponsor Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sponsor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _clubSponsoringSummaryController,
                decoration: const InputDecoration(labelText: 'Summary of Sponsorship'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter summary of sponsorship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildImagePickerButton('Image 1', _imageOne, (pickedImage) {
                setState(() {
                  _imageOne = pickedImage;
                });
              }),
              _buildImagePickerButton('Image 2', _imageTwo, (pickedImage) {
                setState(() {
                  _imageTwo = pickedImage;
                });
              }),
              _buildImagePickerButton('Image 3', _imageThree, (pickedImage) {
                setState(() {
                  _imageThree = pickedImage;
                });
              }),
              _buildImagePickerButton('Image 4', _imageFour, (pickedImage) {
                setState(() {
                  _imageFour = pickedImage;
                });
              }),
              _buildImagePickerButton('Image 5', _imageFive, (pickedImage) {
                setState(() {
                  _imageFive = pickedImage;
                });
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting ? const CircularProgressIndicator() : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerButton(String label, File? imageFile, Function(File?) onImagePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                final pickedImage = await pickImage();
                onImagePicked(pickedImage);
              },
              child: const Text('Pick Image'),
            ),
            const SizedBox(width: 10),
            imageFile != null ? Image.file(imageFile, width: 100, height: 100) : const Text('No image selected'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showSuccessToast() {
    Fluttertoast.showToast(
      msg: "Sponsor added successfully!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: "Error: $message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
