import 'dart:io'; // Bu importu ekle
import 'package:flutter/material.dart';
import 'views/login_screen.dart';

// Yerel sertifika hatalarını görmezden gelmek için
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

//Mustafa@123
void main() {
  // Uygulama başlamadan önce sertifika iznini veriyoruz
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen()),
  );
}
