class TokenModel {
  String? accessToken;
  String? expiration;
  String? userName;
  String? userId; // Swagger'dan gelen Guid ID için

  // Constructor kısmına userId'yi ekledik
  TokenModel({this.accessToken, this.expiration, this.userName, this.userId});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['accessToken'] as String?,
      expiration: json['expiration'] as String?,
      userName: json['userName'] as String?,
      userId: json['userId'] as String?, // API'den gelen benzersiz ID
    );
  }
}
