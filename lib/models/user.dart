// The local class in which users from (a) Firebase snapshot(s) is parsed into
class UserModel {
  String? id;
  String? name;
  String? email;
  String? profileImageUrl;

  UserModel({this.id, this.name, this.email, this.profileImageUrl});
}
