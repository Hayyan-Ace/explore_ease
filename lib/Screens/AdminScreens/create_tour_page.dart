import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateTourPage extends StatefulWidget {
  const CreateTourPage({super.key});

  @override
  _CreateTourPageState createState() => _CreateTourPageState();
}

class _CreateTourPageState extends State<CreateTourPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  // Controllers for each form field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingPointController =
      TextEditingController();
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

    // Check if any field is empty
    if (name.isEmpty ||
        description.isEmpty ||
        startingPoint.isEmpty ||
        endPoint.isEmpty ||
        price.isEmpty ||
        duration.isEmpty ||
        _selectedDate == null ||
        _image == null) {
      // Show a toast indicating that all fields must be filled
      Fluttertoast.showToast(
          msg: 'Please fill in all fields and select a date and image.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    // Omitting the tourId field so Firestore will auto-generate a document ID
    DocumentReference tourDocumentReference =
    await FirebaseFirestore.instance.collection('Tour').add({
      'tourName': name,
      'description': description,
      'startingPoint': startingPoint,
      'endPoint': endPoint,
      'price': price,
      'duration': duration,
      'imageUrl': '',
      'tourDate': _selectedDate,
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

      // Show a toast indicating successful tour creation
      Fluttertoast.showToast(
          msg: 'Tour created successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }).catchError((error) {
      // Handle errors during the image URL and tourId update
      print('Error updating image URL and tourId in Firestore: $error');

      // Show a toast indicating an error
      Fluttertoast.showToast(
          msg: 'Error creating the tour. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
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
    var storageReference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('tour_images')
        .child('$fileName.jpg');

    // Upload the file to Firebase Storage
    await storageReference.putFile(_image!);

    // Get the download URL
    String imageUrl = await storageReference.getDownloadURL();

    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Create Tour',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildEditableField('Name', _nameController, TextInputType.text),
              // Remove the Tour ID field from the form
              // _buildTextField(_tourIdController, 'Tour ID'),
              _buildEditableField('Starting Point', _startingPointController,
                  TextInputType.text),
              _buildEditableField(
                  'End Point', _endPointController, TextInputType.text),
              _buildEditableField(
                  'Price', _priceController, TextInputType.number),
              _buildEditableField(
                  'Duration', _durationController, TextInputType.number),
              _buildEditableDescriptionField('Description', _descriptionController),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.add_a_photo, size: 50),
                      )
                    : Image.file(_image!,
                        width: 150, height: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context), // Show date picker
                child: _selectedDate == null
                    ? Container(
                        width: 20,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFa2d19f),
                          borderRadius:
                              BorderRadius.circular(100.0), // Set border radius
                        ),
                        alignment: Alignment.center,
                        child: const Text('Select Date'),
                      )
                    : Container(
                        width: 20,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFa2d19f),
                          borderRadius:
                              BorderRadius.circular(100.0), // Set border radius
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${_selectedDate!.toLocal()}'
                              .split(' ')[0], // Display selected date
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: const Color(0xFFa2d19f).withOpacity(1),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Perform the tour creation logic here
                    _createTour();
                  }
                },
                child: const Text(
                  'Create Tour',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableDescriptionField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: 10,
        textInputAction: TextInputAction.newline, // Enable new-line action
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide:
                BorderSide(color: Color(0xFFa2d19f)), // Set the focused border color
          ),
          labelStyle: const TextStyle(
              color: Colors.black87), // Set the label (hint) color
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFa2d19f), // header background color
            hintColor: const Color(0xFFa2d19f), // color of selected day
            colorScheme: const ColorScheme.light(primary: Color(0xFFa2d19f)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );



    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

}
