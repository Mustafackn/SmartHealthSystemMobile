class LoginModel {
  final String userNameOrEmail;
  final String password;

  LoginModel({required this.userNameOrEmail, required this.password});

  Map<String, dynamic> toJson() {
    return {
      "loginDto": {
        // Swagger'ın beklediği paketleme
        "userNameOrEmail": userNameOrEmail,
        "password": password,
      },
    };
  }
}
