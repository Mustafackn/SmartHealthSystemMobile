import 'dart:ui';
import 'package:flutter/material.dart';
import '../Services/register_service.dart';
import '../Models/register_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final RegisterService _registerService = RegisterService();

  // Kontrolcüler
  final _fName = TextEditingController();
  final _lName = TextEditingController();
  final _uName = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _isLoading = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final model = RegisterModel(
        firstName: _fName.text.trim(),
        lastName: _lName.text.trim(),
        userName: _uName.text.trim(),
        email: _email.text.trim(),
        password: _pass.text,
        confirmPassword: _confirmPass.text,
      );

      final success = await _registerService.register(model);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar("Hesabınız başarıyla oluşturuldu!", Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackBar(
          "Kayıt başarısız. Bilgileri kontrol edin.",
          Colors.redAccent,
        );
      }
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

  // --- VALIDATORS ---
  String? _requiredValidator(String? value, String label) {
    if (value == null || value.isEmpty) return "$label girilmelidir";
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return "E-posta boş olamaz";
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Geçerli bir e-posta adresi giriniz";
    }
    return null;
  }

  String? _passValidator(String? value) {
    if (value == null || value.isEmpty) return "Şifre boş olamaz";
    if (value.length < 6) return "Şifre en az 6 karakter olmalıdır";
    return null;
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
            // Dekoratif Arka Plan
            Positioned(
              bottom: -size.height * 0.1,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .health_and_safety_rounded, // Burayı yukarıdaki seçeneklerden biriyle değiştirebilirsin
                        size: 80, // Biraz daha büyüterek vurguyu artırabilirsin
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Kayıt Ol",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Glassmorphism Form
                      Form(
                        key: _formKey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildField(
                                          _fName,
                                          "Ad",
                                          Icons.person,
                                          (v) => _requiredValidator(v, "Ad"),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildField(
                                          _lName,
                                          "Soyad",
                                          Icons.person_outline,
                                          (v) => _requiredValidator(v, "Soyad"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  _buildField(
                                    _uName,
                                    "Kullanıcı Adı",
                                    Icons.account_circle,
                                    (v) =>
                                        _requiredValidator(v, "Kullanıcı adı"),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildField(
                                    _email,
                                    "E-posta",
                                    Icons.email,
                                    _emailValidator,
                                    type: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildField(
                                    _pass,
                                    "Şifre",
                                    Icons.lock,
                                    _passValidator,
                                    isPass: true,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildField(
                                    _confirmPass,
                                    "Şifre Tekrar",
                                    Icons.lock_reset,
                                    (v) {
                                      if (v != _pass.text)
                                        return "Şifreler eşleşmiyor";
                                      return _requiredValidator(
                                        v,
                                        "Şifre tekrarı",
                                      );
                                    },
                                    isPass: true,
                                  ),
                                  const SizedBox(height: 25),

                                  _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : _buildRegisterButton(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Zaten hesabınız var mı? Giriş Yapın",
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
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

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String? Function(String?)? validator, {
    bool isPass = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      keyboardType: type,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.orangeAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF00c6ff), Color(0xFF0072ff)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          "KAYIT OL",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fName.dispose();
    _lName.dispose();
    _uName.dispose();
    _email.dispose();
    _pass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }
}
