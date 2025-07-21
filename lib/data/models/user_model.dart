class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final bool isVerified;
  final String? createdAt;
  final String? updatedAt;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      isVerified: json['email_verified_at'] != null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
     g
  }
}
