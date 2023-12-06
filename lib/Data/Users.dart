class User {
  final String name;
  final String pic;
  final String email;
  final String isAdmin;
  final String uid;

  User(
      this.name,
      this.pic,
      this.email,
      this.isAdmin,
      this.uid
      );

  toJson(){
    return {"email": email, "isAdmin": isAdmin, "profilePicture": pic, "uid": uid, "username": name };
  }

}