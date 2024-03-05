import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  String _profileImageUrl = '';

  String get profileImageUrl => _profileImageUrl;

  void updateProfileImageUrl(String imageUrl) {
    _profileImageUrl = imageUrl;
    notifyListeners();
  }
}
