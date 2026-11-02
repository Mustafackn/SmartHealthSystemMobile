import 'package:dio/dio.dart';
import '../Models/register_model.dart';

class RegisterService {
  // Terminalde gördüğün güncel portun 5096 olduğunu biliyoruz
  final String _baseUrl = "http://10.0.2.2:5096/api";

  late final Dio _dio;

  RegisterService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 5),
        contentType: "application/json",
      ),
    );
  }

  Future<bool> register(RegisterModel registerModel) async {
    try {
      // Swagger'daki yol: /api/Users/register
      final response = await _dio.post(
        "/Users/register",
        data: registerModel.toJson(),
      );

      // Başarılı kayıt durumunda 200 veya 201 döner
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Kayıt Başarılı!");
        return true;
      }
    } on DioException catch (e) {
      // API'den gelen hata detayını görmek için
      print("Kayıt Hatası Detayı: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("Beklenmedik Hata: $e");
    }
    return false;
  }
}
