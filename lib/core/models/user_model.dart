class UserModel {
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;

  UserModel({
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
  });
}
