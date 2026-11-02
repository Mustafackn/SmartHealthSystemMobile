import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // PAKET EKLENDİ
import '../Services/api_service.dart';
import '../models/login_model.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_userController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Lütfen tüm alanları doldurun", Colors.orangeAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loginData = LoginModel(
        userNameOrEmail: _userController.text,
        password: _passwordController.text,
      );

      // result burada TokenModel tipinde dönüyor
      final result = await _apiService.login(loginData);

      if (result != null && result.accessToken != null) {
        if (!mounted) return;

        // --- TOKEN DECODE İŞLEMİ BAŞLANGIÇ ---
        String token = result.accessToken!;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        // .NET API'lerinde userId genellikle bu uzun claim adı altında saklanır
        String extractedUserId =
            decodedToken["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"] ??
            "";
        // --- TOKEN DECODE İŞLEMİ BİTİŞ ---

        // VERİ GÖNDERİMİ: Decode ettiğimiz gerçek userId'yi gönderiyoruz
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: _userController.text,
              userId: extractedUserId, // Artık API'den gelen gerçek ID gidiyor
            ),
          ),
        );
      } else {
        _showSnackBar(
          "Giriş Başarısız: Bilgilerinizi kontrol edin.",
          Colors.redAccent,
        );
      }
    } catch (e) {
      _showSnackBar("Bir hata oluştu: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.2,
              child: _buildCircle(size.width * 0.5, Colors.white10),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    children: [
                      _buildHeader(size),
                      const SizedBox(height: 40),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildStyledTextField(
                                  controller: _userController,
                                  label: "Kullanıcı Adı / Email",
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 20),
                                _buildStyledTextField(
                                  controller: _passwordController,
                                  label: "Şifre",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 30),
                                _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : _buildLoginButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            text: "Hesabınız yok mu? ",
                            style: TextStyle(color: Colors.white70),
                            children: [
                              TextSpan(
                                text: "Hemen Kayıt Olun",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "SMART HEALTH",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const Text(
          "Geleceğin Sağlık Takip Sistemi",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "GİRİŞ YAP",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
