import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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
  late TextEditingController descriptionController;
  late TextEditingController startingPointController;
  late TextEditingController endPointController;
  late TextEditingController priceController;
  late TextEditingController durationController;
  late TextEditingController tourIdController;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tourIdController = TextEditingController(text: widget.tourDetails["tourId"]);
    nameController = TextEditingController(text: widget.tourDetails["tourName"]);
    descriptionController = TextEditingController(text: widget.tourDetails["description"]);
    startingPointController = TextEditingController(text: widget.tourDetails["startingPoint"]);
    endPointController = TextEditingController(text: widget.tourDetails["endPoint"]);
    priceController = TextEditingController(text: widget.tourDetails["price"].toString());
    durationController = TextEditingController(text: widget.tourDetails["duration"].toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    startingPointController.dispose();
    endPointController.dispose();
    priceController.dispose();
    durationController.dispose();
    tourIdController.dispose();
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

  Future<String?> uploadImageToFirebaseStorage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageReference =
      firebase_storage.FirebaseStorage.instance.ref().child('tour_images').child('$fileName.jpg');
      await storageReference.putFile(image);
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Widget _buildUneditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        enabled: false, // Set to false to make it uneditable
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
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
              _buildUneditableField("Tour ID", tourIdController.text),
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
                  child: widget.tourDetails["imageUrl"] != null
                      ? Image.network(widget.tourDetails["imageUrl"])
                      : Center(child: Text("No Image")),
                )
                    : Image.file(
                  _image!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Your existing code for updating tour details

                  // Update the image URL if a new image is selected
                  if (_image != null) {
                    String? imageUrl = await uploadImageToFirebaseStorage(_image!);
                    if (imageUrl != null) {
                      // Update the image URL in the tour details
                      widget.tourDetails["imageUrl"] = imageUrl;
                    }
                  }

                  // Save the updated data to Firebase Firestore
                  try {
                    await FirebaseFirestore.instance.collection('Tour').doc(widget.tourDetails["tourId"]).update(widget.tourDetails);
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
