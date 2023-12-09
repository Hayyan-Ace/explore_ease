import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditTourPage extends StatefulWidget {
  final Map<String, dynamic> tourDetails;

  const EditTourPage({Key? key, required this.tourDetails}) : super(key: key);

  @override
  _EditTourPageState createState() => _EditTourPageState();
}

class _EditTourPageState extends State<EditTourPage> {
  late TextEditingController nameController;
  late TextEditingController tourIdController;
  late TextEditingController descriptionController;
  late TextEditingController startingPointController;
  late TextEditingController endPointController;
  late TextEditingController priceController;
  late TextEditingController durationController;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.tourDetails["tourName"]);
    tourIdController = TextEditingController(text: widget.tourDetails["tourId"]);
    descriptionController = TextEditingController(text: widget.tourDetails["description"]);
    startingPointController = TextEditingController(text: widget.tourDetails["startingPoint"]);
    endPointController = TextEditingController(text: widget.tourDetails["endPoint"]);
    priceController = TextEditingController(text: widget.tourDetails["price"].toString());
    durationController = TextEditingController(text: widget.tourDetails["duration"].toString());

    // Load the existing image URL and display it
    String? imageUrl = widget.tourDetails["imageUrl"] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      _image = File(imageUrl);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    tourIdController.dispose();
    descriptionController.dispose();
    startingPointController.dispose();
    endPointController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tour'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField("Name", nameController),
              _buildEditableField("Tour ID", tourIdController),
              _buildEditableField("Description", descriptionController),
              _buildEditableField("Starting Point", startingPointController),
              _buildEditableField("End Point", endPointController),
              _buildEditableField("Price", priceController),
              _buildEditableField("Duration", durationController),
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
                onPressed: () async {
                  // Access updated values using controllers
                  String tourName = nameController.text;
                  String tourId = tourIdController.text;
                  String description = descriptionController.text;
                  String startingPoint = startingPointController.text;
                  String endPoint = endPointController.text;
                  double price = double.parse(priceController.text);
                  int duration = int.parse(durationController.text);

                  // Access updated image using _image
                  File? updatedImage = _image;

                  // Create a map with the updated data
                  Map<String, dynamic> updatedData = {
                    "tourName": tourName,
                    "tourId": tourId,
                    "description": description,
                    "startingPoint": startingPoint,
                    "endPoint": endPoint,
                    "price": price,
                    "duration": duration,
                    // Add other fields as needed
                  };

                  // Update the image URL if an image is selected
                  if (updatedImage != null) {
                    // Upload the image to Firebase Storage and get the download URL
                    // You need to implement the image upload logic using Firebase Storage
                    // Once uploaded, update the image URL in the updatedData
                    // For example:
                    // String imageUrl = await uploadImageToFirebaseStorage(updatedImage);
                    // updatedData["imageUrl"] = imageUrl;
                  }

                  // Save the updated data to Firebase Firestore
                  try {
                    await FirebaseFirestore.instance.collection('Tour').doc(tourId).update(updatedData);
                  } catch (e) {
                    print('Error updating document: $e');
                    // Handle the error appropriately
                  }

                  // Navigate back or perform any other action after saving
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
