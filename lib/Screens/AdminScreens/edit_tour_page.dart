import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditTourPage extends StatefulWidget {
  final Map<String, dynamic> tourDetails;

  const EditTourPage({super.key, required this.tourDetails});

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

  DateTime? _selectedDate;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tourIdController =
        TextEditingController(text: widget.tourDetails["tourId"]);
    nameController =
        TextEditingController(text: widget.tourDetails["tourName"]);
    descriptionController =
        TextEditingController(text: widget.tourDetails["description"]);
    startingPointController =
        TextEditingController(text: widget.tourDetails["startingPoint"]);
    endPointController =
        TextEditingController(text: widget.tourDetails["endPoint"]);
    priceController =
        TextEditingController(text: widget.tourDetails["price"].toString());
    durationController =
        TextEditingController(text: widget.tourDetails["duration"].toString());
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
      String fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      var storageReference =
      firebase_storage.FirebaseStorage.instance.ref()
          .child('tour_images')
          .child('$fileName.jpg');
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
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
            'Edit Tour',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField("Name", nameController, TextInputType.text),
              _buildUneditableField("Tour ID", tourIdController.text, ),
              _buildEditableField("Starting Point", startingPointController, TextInputType.text),
              _buildEditableField("End Point", endPointController, TextInputType.text),
              _buildEditableField("Price", priceController, TextInputType.number),
              _buildEditableField("Duration", durationController,TextInputType.number),
              _buildEditableDescriptionField("Description", descriptionController),
              const SizedBox(height: 5,),
              _buildEditableDateField("Tour Date"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: getImage,
                child: _image == null
                    ? Container(
                  width: 150,
                  height: 150,
                  color: Colors.white,
                  child: widget.tourDetails["imageUrl"] != null
                      ? Image.network(widget.tourDetails["imageUrl"])
                      : const Center(child: Text("No Image")),
                )
                    : Image.file(
                  _image!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: const Color(0xFFa2d19f).withOpacity(1),
                  ),

                  onPressed: () async {
                    // Check if all fields are filled
                    if (!_areAllFieldsFilled()) {
                      _showToast(
                        'Please fill in all fields and select a date and image.',
                      );
                      return;
                    }
                    // Update the image URL if a new image is selected
                    if (_image != null) {
                      String? imageUrl = await uploadImageToFirebaseStorage(
                          _image!);
                      if (imageUrl != null) {
                        // Update the image URL in the tour details
                        widget.tourDetails["imageUrl"] = imageUrl;
                      }
                    }

                    // Update the tour details with the edited values
                    widget.tourDetails["tourName"] = nameController.text;
                    widget.tourDetails["description"] = descriptionController.text;
                    widget.tourDetails["startingPoint"] = startingPointController.text;
                    widget.tourDetails["endPoint"] = endPointController.text;
                    widget.tourDetails["price"] = priceController.text;
                    widget.tourDetails["duration"] = durationController.text;

                    // Format the selected date before updating
                    // Convert the selected date to a timestamp
                    if (_selectedDate != null) {
                      widget.tourDetails["tourDate"] = Timestamp.fromDate(_selectedDate!);
                    }

                    // Save the updated data to Firebase Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('Tour')
                          .doc(widget.tourDetails["tourId"])
                          .update(widget.tourDetails);
                      print('Document updated successfully!');

                      // Show a toast indicating successful updation
                      _showToast('Tour updated successfully!', backgroundColor: Colors.green);
                    } catch (e) {
                      print('Error updating document: $e');
                      _showToast('Error updating the tour. Please try again.');
                      // Handle the error appropriately
                    }
                    // Navigate back or perform any other action after saving
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  },
                  child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.black87)),
                ),
              ),
            ],
          ),
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


  Widget _buildEditableDateField(String label) {
    // Initialize _selectedDate with the date from Firebase if available
    _selectedDate ??= (widget.tourDetails["tourDate"] as Timestamp?)?.toDate();

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: _selectedDate == null
          ? Container(
        width: 380,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFa2d19f),
          borderRadius: BorderRadius.circular(100.0),
        ),
        alignment: Alignment.center,
        child: const Text('Select Date'),
      )
          : Container(
        width: 380,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFa2d19f),
          borderRadius: BorderRadius.circular(100.0),
        ),
        alignment: Alignment.center,
        child: Text(
          '${_selectedDate!.toLocal()}'.split(' ')[0],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFa2d19f),
            hintColor: const Color(0xFFa2d19f),
            colorScheme: const ColorScheme.light(primary: Color(0xFFa2d19f)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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

  bool _areAllFieldsFilled() {
    print('Name: ${nameController.text.isNotEmpty}');
    print('Description: ${descriptionController.text.isNotEmpty}');
    print('Starting Point: ${startingPointController.text.isNotEmpty}');
    print('End Point: ${endPointController.text.isNotEmpty}');
    print('Price: ${priceController.text.isNotEmpty}');
    print('Duration: ${durationController.text.isNotEmpty}');
    print('Selected Date: ${_selectedDate != null}');
    print('Image: ${_image != null}');

    return nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        startingPointController.text.isNotEmpty &&
        endPointController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        _selectedDate != null;
  }


  void _showToast(String message, {Color? backgroundColor, Color? textColor}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor ?? Colors.red,
      textColor: textColor ?? Colors.white,
      fontSize: 16.0,
    );
  }


}
