import 'package:flutter/material.dart';
import '../Services/api_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  final String loggedInUserId;

  const ProfileScreen({super.key, required this.loggedInUserId});

  @override
  Widget build(BuildContext context) {
    // Modern & Soft Renk Paleti
    const Color kPrimary = Color(0xFF1e3c72);
    const Color kBackground = Color(0xFFFBFBFD); // Apple-style beyaz

    return Scaffold(
      backgroundColor: kBackground,
      body: FutureBuilder<UserModel?>(
        future: ApiService().getUserProfile(loggedInUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Veri alınamadı."));
          }

          final user = snapshot.data!;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Estetik Üst Bar
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: kBackground,
                elevation: 0,
                floating: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Hesabım",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.black54,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PROFİL ÖZETİ (Avatar + İsim) ---
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: kPrimary,
                            child: Text(
                              user.fullName[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      const Text(
                        "KİŞİSEL DETAYLAR",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- BİLGİ BLOĞU (İç içe değil, tek bir temiz yüzeyde) ---
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSimpleRow(
                              "Kullanıcı Adı",
                              user.userName,
                              Icons.alternate_email,
                            ),
                            _buildDivider(),
                            _buildSimpleRow(
                              "Sistem ID",
                              user.id.substring(0, 12),
                              Icons.fingerprint,
                            ),
                            _buildDivider(),
                            _buildSimpleRow(
                              "Üyelik Tipi",
                              "Premium",
                              Icons.verified_user_outlined,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- AKSİYONLAR ---
                      const Text(
                        "HESAP YÖNETİMİ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildActionButton(
                        context,
                        "Profili Düzenle",
                        Icons.edit_note_rounded,
                        Colors.blue.shade700,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        context,
                        "Oturumu Kapat",
                        Icons.logout_rounded,
                        Colors.redAccent,
                        isLogout: true,
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Temiz bir satır yapısı
  Widget _buildSimpleRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black26),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
    height: 1,
    indent: 55,
    endIndent: 20,
    color: Colors.grey.withOpacity(0.1),
  );

  // Modern Buton Yapısı
  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: () {
        if (isLogout)
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
