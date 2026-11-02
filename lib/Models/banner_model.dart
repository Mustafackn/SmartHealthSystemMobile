class BannerModel {
  final String? id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? targetUrl;

  BannerModel({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.targetUrl,
  });
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String? rawUrl = json['imageUrl'];
    String? finalUrl;

    if (rawUrl != null) {
      // 1. Eğer URL "localhost" içeriyorsa 10.0.2.2 ile değiştir
      if (rawUrl.contains('localhost')) {
        finalUrl = rawUrl.replaceAll('localhost', '10.0.2.2');
      }
      // 2. Eğer URL domain içermiyor, sadece "/img/..." diye başlıyorsa domain ekle
      else if (rawUrl.startsWith('/')) {
        finalUrl = "http://10.0.2.2:5096$rawUrl";
      } else {
        finalUrl = rawUrl;
      }
    }

    return BannerModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: finalUrl,
      targetUrl: json['targetUrl'],
    );
  }
}
