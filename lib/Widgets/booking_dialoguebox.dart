import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class BookingDialog extends StatefulWidget {
  final String tourName;
  final String tourID;
  final String tourDate; // Add this line

  BookingDialog({
  required this.tourName,
  required this.tourID,
  required this.tourDate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  File? _receiptImage;
  bool _imageSelected = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _receiptImageUrl;

  @override
  void initState() {
    super.initState();
    _receiptImageUrl = '';
  }


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
    // Ensure _receiptImageUrl is initialized before using it
    if (_receiptImageUrl == null || _receiptImageUrl.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please upload receipt",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // Update user's database with booking information
      await FirebaseFirestore.instance.collection('users').doc(
          _auth.currentUser!.uid).update({
        'bookings': FieldValue.arrayUnion([
          {
            'tourName': widget.tourName,
            'tourUid': widget.tourID,
            'receiptImageUrl': _receiptImageUrl,
            'verified': false,
          }
        ]),
      });

      // Show toast when tour is confirmed
      Fluttertoast.showToast(
        msg: 'Booking Confirmed!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Close the dialog
      Navigator.pop(context);
    }
  }

  @override
      Widget build(BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _imageSelected
                  ? Container(
                width: 150,
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 70,
                      color: Color(0xFFa2d19f),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFa2d19f)),
                ),
                onPressed: () {
                  // Handle Confirm Tour button click
                  _confirmTour();
                },
                child: const Text('Confirm Tour',style: TextStyle(color: Colors.black),),
              ),
              const SizedBox(height: 10,),
            ],
          ),
        );
      }
}





