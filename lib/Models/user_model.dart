class UserModel {
  final String id;
  final String fullName;
  final String userName;
  final String email;

  UserModel({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
