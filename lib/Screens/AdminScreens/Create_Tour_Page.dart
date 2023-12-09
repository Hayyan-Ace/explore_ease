import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateTourPage extends StatefulWidget {
  const CreateTourPage({Key? key}) : super(key: key);

  @override
  _CreateTourPageState createState() => _CreateTourPageState();
}

class _CreateTourPageState extends State<CreateTourPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each form field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  // Image related
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _createTour() async {
    // Access the entered values from the controllers
    final String name = _nameController.text;
    final String description = _descriptionController.text;
    final String startingPoint = _startingPointController.text;
    final String endPoint = _endPointController.text;
    final String price = _priceController.text;
    final String duration = _durationController.text;

    // Omitting the tourId field so Firestore will auto-generate a document ID
    DocumentReference tourDocumentReference = await FirebaseFirestore.instance.collection('Tour').add({
      'tourName': name,
      'description': description,
      'startingPoint': startingPoint,
      'endPoint': endPoint,
      'price': price,
      'duration': duration,
      'imageUrl': '', // Placeholder for the image URL, update with the actual URL
    });

    // Retrieve the auto-generated tour ID
    String newTourId = tourDocumentReference.id;

    // Upload the image to Firebase Storage
    String imageUrl = await uploadImageToFirebaseStorage();

    // Update the 'imageUrl' field in the Firestore document with the actual URL
    await FirebaseFirestore.instance.collection('Tour').doc(newTourId).update({
      'imageUrl': imageUrl,
      'tourId': newTourId, // Store the document ID as 'tourId'
    }).then((_) {
      // Image URL and tourId updated successfully
      print('Image URL and tourId updated in Firestore');
    }).catchError((error) {
      // Handle errors during the image URL and tourId update
      print('Error updating image URL and tourId in Firestore: $error');
    });

    // Successfully added tour to Firebase
    print('Tour added to Firebase with document ID: $newTourId');

    //navigate back to the previous screen or perform other actions.
    Navigator.pop(context);
  }




  Future<String> uploadImageToFirebaseStorage() async {
    if (_image == null) {
      // No image to upload
      return '';
    }

    // Generate a unique filename based on the current timestamp
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Reference to the Firebase Storage bucket with a dynamic file name
    var storageReference = firebase_storage.FirebaseStorage.instance.ref().child('tour_images').child('$fileName.jpg');

    // Upload the file to Firebase Storage
    await storageReference.putFile(_image!);

    // Get the download URL
    String imageUrl = await storageReference.getDownloadURL();

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Tour'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Name'),
              // Remove the Tour ID field from the form
              // _buildTextField(_tourIdController, 'Tour ID'),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(_startingPointController, 'Starting Point'),
              _buildTextField(_endPointController, 'End Point'),
              _buildTextField(_priceController, 'Price'),
              _buildTextField(_durationController, 'Duration'),
              SizedBox(height: 16),
              GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? Container(
                  width: 150,
                  height: 150,
                  color: Colors.grey[200],
                  child: Icon(Icons.add_a_photo, size: 50),
                )
                    : Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Perform the tour creation logic here
                    _createTour();
                  }
                },
                child: Text('Create Tour'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
