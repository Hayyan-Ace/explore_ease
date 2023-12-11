class MyAppUser {
  final String uid;
  final String email;
  final String username;
  final String profilePicture;
  final bool isAdmin;
  final String fullName;
  final String phoneNo;
  final String cnic;
  MyAppUser({
    required this.fullName,
    required this.phoneNo,
    required this.cnic,
    required this.uid,
    required this.email,
    required this.username,
    required this.profilePicture,
    required this.isAdmin,
  });


  factory MyAppUser.fromMap(Map<String, dynamic> map) {
    return MyAppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      fullName: map['fullName'] ?? '',
      phoneNo: map['phoneNo'] ?? '',
      cnic: map['cnic'] ?? ''
    );
  }
}