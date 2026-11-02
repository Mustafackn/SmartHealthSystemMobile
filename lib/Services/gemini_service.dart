import 'dart:typed_data'; // 🔥 Resim byte verisi için bu import şart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "BURAYA_API_ANAHTARI_GELECEK";

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      // 🚀 1. DÜZELTME: Günlerdir aldığınız v1beta hatasını kökten çözen sihirli satır
      requestOptions: const RequestOptions(apiVersion: 'v1'),
    );

    _chatSession = _model.startChat();
  }

  void clearHistory() {
    _chatSession = _model.startChat();
  }

  // 🚀 2. DÜZELTME: Fonksiyonu hem metin hem de isteğe bağlı resim alacak şekilde güncelledik
  Future<String> askHealthQuestion(
    String prompt, {
    Uint8List? imageBytes,
  }) async {
    try {
      _chatSession ??= _model.startChat();

      // Gemini'ye gidecek çoklu içerik listesini (parts) oluşturuyoruz
      final List<Part> parts = [];

      // Eğer kullanıcı arayüzden bir resim seçtiyse bunu pakete ekliyoruz
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      // Kullanıcının yazdığı metni ekliyoruz.
      // Eğer kullanıcı sadece resim gönderip yazı yazmadıysa bota varsayılan bir komut veriyoruz.
      parts.add(
        TextPart(
          prompt.isEmpty
              ? "Bu görseli analiz et ve sağlık asistanı olarak yorumla."
              : prompt,
        ),
      );

      // Content.text yerine Content.multi kullanarak resmi ve yazıyı tek seferde gönderiyoruz
      final response = await _chatSession!.sendMessage(Content.multi(parts));

      return response.text ?? "Yanıt alınamadı.";
    } catch (e) {
      print("*****************************************");
      print("GEMINI HATASI: $e");
      print("*****************************************");
      return "Yapay zeka servisine bağlanılamadı. Lütfen internetinizi veya API ayarlarınızı kontrol edin.";
    }
  }
}
