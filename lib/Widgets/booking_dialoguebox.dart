import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class BookingDialog extends StatefulWidget {

  final String tourName;
  final String tourID;
  BookingDialog({required this.tourName, required this.tourID});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  File? _receiptImage;
  bool _imageSelected = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _receiptImageUrl;


  Future<void> _selectImage() async {
    var imagePicker = ImagePicker();
    var pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload image to Firebase Storage
      String fileName = path.basename(pickedFile.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('receipts/$fileName');
      UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get image URL
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Update state with image details
      setState(() {
        _receiptImage = File(pickedFile.path);
        _imageSelected = true;
        _receiptImageUrl = imageUrl; // Assuming receiptImageUrl is a state variable
      });
    }
  }

  Future<void> _confirmTour() async {

    // Update user's database with booking information
    await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).update({
      'bookings': FieldValue.arrayUnion([
        {
          'tourName' : widget.tourName,
          'tourUid': widget.tourID,
          'receiptImageUrl': _receiptImageUrl,
          'verified': false,
        }
      ]),
    });

    // Navigate back to the tour details page
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _imageSelected
              ? Container(
            width: 150,
            height: 450,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(_receiptImage!),
                fit: BoxFit.cover,
              ),
            ),
          )
              : GestureDetector(
            onTap: _selectImage,
            child: Container(
              width: 150,
              height: 150,
              color: Colors.grey, // You can customize the color
              child: const Center(
                child: Icon(
                  Icons.add_a_photo,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle Confirm Tour button click
              _confirmTour();
            },
            child: Text('Confirm Tour'),
          ),
        ],
      ),
    );
  }

}





