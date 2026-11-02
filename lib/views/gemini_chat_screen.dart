import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smarthealthsytemmobil/Services/gemini_service.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages =
      []; // Resim yollarını tutabilmek için 'dynamic' yaptık
  bool _isLoading = false;

  XFile? _selectedImage; // Kullanıcının seçtiği anlık resmi tutar
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Galeriden resim seçme fonksiyonu
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    // Eğer hem yazı boşsa hem de resim seçilmediyse hiçbir şey yapma
    if (text.isEmpty && _selectedImage == null) return;

    final currentImage =
        _selectedImage; // State değişimlerinden etkilenmemesi için kopyalıyoruz

    setState(() {
      _messages.add({
        "role": "user",
        "text": text,
        "imagePath": currentImage?.path, // Eğer resim varsa yolunu kaydediyoruz
      });
      _isLoading = true;
      _selectedImage = null; // Giriş alanındaki resmi temizle
    });
    _controller.clear();

    // Resmi byte dizisine dönüştür
    Uint8List? imageBytes;
    if (currentImage != null) {
      imageBytes = await currentImage.readAsBytes();
    }

    // Servise hem yazıyı hem de resmi gönderiyoruz
    final response = await _geminiService.askHealthQuestion(
      text,
      imageBytes: imageBytes,
    );

    setState(() {
      _messages.add({"role": "model", "text": response, "imagePath": null});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Akıllı Sağlık Asistanı",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 26),
            onPressed: () {
              setState(() {
                _messages.clear();
                _geminiService.clearHistory();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mesaj Listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return _buildChatBubble(msg["text"]!, isUser, msg["imagePath"]);
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF1A237E),
              backgroundColor: Colors.transparent,
            ),

          // Resim seçildiyse giriş alanının hemen üstünde küçük önizleme gösterir
          if (_selectedImage != null) _buildImagePreview(),

          // Giriş Alanı
          _buildInputArea(),
        ],
      ),
    );
  }

  // Yenilenen Mesaj Balonu (Resim Desteği ile)
  Widget _buildChatBubble(String text, bool isUser, String? imagePath) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1A237E) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eğer mesaja ait bir resim yolu varsa balonda resmi gösterir
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 10,
                  bottom: 95, // Alt menünün üstünde kalması için gereken boşluk
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    fit: FileImage == null ? BoxFit.cover : BoxFit.fill,
                  ),
                ),
              ),
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Seçilen resmin yazı kutusunun üstündeki küçük önizleme tasarımı
  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_selectedImage!.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Artık Sol Tarafında Fotoğraf Ekleme Butonu Olan Alt Bar
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 95,
      ), // Navigasyon bar taşma koruması aktif
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 📷 Resim Ekleme Butonu
          IconButton(
            icon: const Icon(
              Icons.image_rounded,
              color: Color(0xFF1A237E),
              size: 28,
            ),
            onPressed: _pickImage,
          ),
          const SizedBox(width: 4),
          // TextField Alanı
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "Sorunuzu yazın veya resim ekleyin...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Gönderme Butonu
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
