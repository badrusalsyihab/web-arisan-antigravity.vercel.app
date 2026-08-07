class UserModel {
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final bool isPremium;

  UserModel({
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.isPremium = false,
  });
}
