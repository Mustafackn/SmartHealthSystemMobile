import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:smarthealthsytemmobil/views/gemini_chat_screen.dart';
import 'dart:ui';
import 'package:smarthealthsytemmobil/views/profile_screen.dart';
// ADIM 1: Test sonuçları ekranını yukarıya import ediyoruz
import 'package:smarthealthsytemmobil/views/test_results_screen.dart';
import '../Models/banner_model.dart';
import '../Services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  List<BannerModel> _banners = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _apiService.fetchBanners();
      setState(() {
        _banners = banners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Banner Yükleme Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      appBar: _buildModernAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: [
          _buildPremiumDashboard(),
          // ADIM 2: Statik yazı yerine alt menüdeki 2. ikon tıklandığında açılacak ekranı bağlıyoruz
          TestResultsScreen(userId: widget.userId),
          const GeminiChatScreen(),
          ProfileScreen(loggedInUserId: widget.userId),
        ],
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.white.withOpacity(0.8)),
        ),
      ),
      title: const Text(
        "SmartHealth",
        style: TextStyle(
          color: Color(0xFF1A237E),
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.indigo,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPremiumDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingSection(),
          const SizedBox(height: 15),
          _buildHealthCarousel(),
          const SizedBox(height: 35),
          _buildHealthOverviewCard(), // Tıklanabilir yaptığımız kart
          const SizedBox(height: 30),
          const Text(
            "Sağlık Özetiniz",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 15),
          _buildAnalysisGrid(),
        ],
      ),
    );
  }

  Widget _buildHealthCarousel() {
    if (_isLoading) {
      return const SizedBox(
        height: 350,
        child: Center(child: CircularProgressIndicator(color: Colors.indigo)),
      );
    }

    if (_banners.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Banner bulunamadı.")),
      );
    }

    return SizedBox(
      height: 420,
      child: Swiper(
        itemCount: _banners.length,
        autoplay: true,
        autoplayDelay: 5000,
        curve: Curves.easeInOutQuart,
        viewportFraction: 0.82,
        scale: 0.9,
        pagination: const SwiperPagination(
          margin: EdgeInsets.only(top: 20),
          builder: DotSwiperPaginationBuilder(
            activeColor: Color(0xFF1A237E),
            color: Colors.black12,
            size: 7,
            activeSize: 11,
          ),
        ),
        itemBuilder: (context, index) {
          final banner = _banners[index];
          String imageUrl = banner.imageUrl ?? '';
          imageUrl = imageUrl.replaceAll('localhost', '10.0.2.2');
          imageUrl = imageUrl.replaceAll(':5037', ':5096');

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Merhaba,",
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B3E),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "#${widget.userId.isNotEmpty ? (widget.userId.length > 4 ? widget.userId.substring(0, 4) : widget.userId) : '...'}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ADIM 3: Dashboard üzerindeki "ML Modelimiz..." kartına tıklandığında yönlendirme sağlandı
  Widget _buildHealthOverviewCard() {
    return GestureDetector(
      onTap: () {
        // Karta basıldığında alt navigasyon barındaki 2. sekmeye (Analiz Raporları) geçiş yapar
        setState(() => _selectedIndex = 1);
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 30),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                "ML Modelimiz verilerinizi analiz etmeye hazır!\nSonuçları görmek için tıklayın.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 18,
      mainAxisSpacing: 18,
      childAspectRatio: 0.92,
      children: [
        _buildStatCard(
          "Böbrek",
          "Normal",
          Icons.water_drop_rounded,
          Colors.blue,
        ),
        _buildStatCard("Kalp", "Normal", Icons.favorite_rounded, Colors.red),
        _buildStatCard(
          "Şeker",
          "95 mg/dl",
          Icons.bloodtype_rounded,
          Colors.orange,
        ),
        _buildStatCard("Su", "2.0 L", Icons.local_drink_rounded, Colors.cyan),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B3E),
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNBItem(0, Icons.grid_view_rounded),
            _buildNBItem(
              1,
              Icons.analytics_rounded,
            ), // Bu sekmeye basınca TestResultsScreen açılır
            _buildNBItem(2, Icons.auto_awesome_rounded),

            _buildNBItem(4, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNBItem(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.white54,
          size: isSelected ? 30 : 26,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
