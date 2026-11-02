class RegisterModel {
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterModel({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "userDto": {
        // Swagger'daki anahtar tam olarak bu!
        "firstName": firstName,
        "lastName": lastName,
        "userName": userName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      },
    };
  }
}
