import 'package:dio/dio.dart';
import 'package:smarthealthsytemmobil/Models/banner_model.dart';
import 'package:smarthealthsytemmobil/Models/test_result_model.dart';
import '../models/login_model.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

class ApiService {
  // Emülatör için bilgisayarın localhost adresi
  static const String _baseUrl = "http://10.0.2.2:5096/api";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 5),
      contentType: "application/json",
    ),
  );

  // 1. Banner Verilerini Getirme (Dio Versiyonu)
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _dio.get("/Banners");

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> bannerList = response.data['banners'];
        return bannerList.map((json) => BannerModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("Banner Yükleme Hatası: ${e.response?.data ?? e.message}");
      throw Exception('Bannerlar yüklenemedi: ${e.message}');
    }
  }

  // 2. Giriş Yapma Fonksiyonu
  Future<TokenModel?> login(LoginModel loginModel) async {
    try {
      final response = await _dio.post(
        "/Users/login",
        data: loginModel.toJson(),
      );

      if (response.statusCode == 200) {
        var tokenData = response.data['token'];
        if (tokenData != null) {
          print("Bağlantı Başarılı! Token: ${tokenData['accessToken']}");
          return TokenModel.fromJson(tokenData);
        }
      }
    } on DioException catch (e) {
      print("Giriş Hatası: ${e.response?.data ?? e.message}");
    }
    return null;
  }

  // 3. Profil Bilgilerini Getirme
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(
        "/Users/get-all",
        queryParameters: {'SearchTerm': userId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> allUsers = response.data;

        final matchedUser = allUsers.firstWhere(
          (user) =>
              user['id'].toString().toLowerCase() ==
              userId.trim().toLowerCase(),
          orElse: () => null,
        );

        if (matchedUser != null) {
          return UserModel.fromJson(matchedUser);
        }
      }
    } on DioException catch (e) {
      print("Profil Getirme Hatası: ${e.message}");
    }
    return null;
  }

  // 4. Tüm Geçmiş Analiz Sonuçlarını Detaylı Getirme (Güncellendi 🚀)
  Future<List<TestResultModel>> fetchTestResults(String userId) async {
    try {
      // 🌟 Backend'deki düz entity dönen yeni güvenli URL'e bağladık
      final response = await _dio.get(
        "/TestResultApi/GetMyResultsDirectEntity/$userId",
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['isSuccess'] == true) {
          final List<dynamic> resultsList = response.data['results'];
          return resultsList
              .map((json) => TestResultModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      print("Test Sonuçları Yükleme Hatası: ${e.response?.data ?? e.message}");
      throw Exception('Analiz sonuçları yüklenemedi: ${e.message}');
    }
  }
}
