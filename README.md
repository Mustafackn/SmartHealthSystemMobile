# 🏥 SmartHealth — Akıllı Sağlık Analiz, Tahmin ve Karar Destek Sistemi (Mobil İstemci)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![.NET 8](https://img.shields.io/badge/Backend-.NET%208%20Web%20API-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Python](https://img.shields.io/badge/ML%20Engine-Python%20%7C%20FastAPI-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SQL Server](https://img.shields.io/badge/Database-MS%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)

**SmartHealth**, bireylerin klinik laboratuvar verilerini ve biyometrik parametrelerini makine öğrenmesi algoritmaları ile analiz ederek kronik hastalık risklerini öngören ve kişiselleştirilmiş sağlık tavsiyeleri sunan yapay zeka tabanlı bir **Karar Destek Sistemi (Decision Support System)** platformudur.

Bu depo (*repository*), sistemin **Flutter** ve **Material Design 3** prensipleriyle geliştirilen cross-platform (Android / iOS) mobil istemci uygulamasını barındırmaktadır.

---

## 🎯 Projenin Amacı ve Kapsamı

Kronik hastalıkların erken teşhisi, tedavi başarısını doğrudan etkileyen en kritik faktördür. **SmartHealth**, dağınık haldeki klinik ve biyometrik verileri anlamlı içgörülere dönüştürerek kullanıcıların semptomlar belirginleşmeden önce risk durumlarını takip edebilmelerini ve proaktif sağlık yönetimi yapabilmelerini hedefler.

> ⚠️ **Tıbbi Sorumluluk Reddi (Disclaimer):** Bu uygulama klinik bir tanı aracı olmayıp istatistiksel risk tahminleri üreten bir karar destek platformudur. Nihai tıbbi değerlendirme ve teşhis her koşulda uzman bir hekim tarafından yapılmalıdır[cite: 1].

---

## 📱 Mobil Uygulama Özellikleri

* **🔐 Güvenli Kimlik Doğrulama ve Oturum Yönetimi:** JWT (JSON Web Token) tabanlı giriş/kayıt akışı, otomatik token yenileme ve rol bazlı yetkilendirme (RBAC)[cite: 1].
* **📊 Kişiselleştirilmiş Sağlık Özeti:** Kullanıcının geçmiş analiz skorlarını, güncel risk durumlarını ve sistem hazırlık bilgisini sunan dinamik ana ekran[cite: 1].
* **🩺 Çok Modüllü Risk Analizi:**
  * **Tip 2 Diyabet Tahmin Modülü:** HbA1c, açlık kan şekeri, VKİ (BMI), yaş ve hipertansiyon/kalp hastalığı geçmişine dayalı risk hesaplama[cite: 1].
  * **Kardiyovasküler Risk Modülü:** Sistolik/diyastolik tansiyon, kolesterol, glikoz ve yaşam tarzı alışkanlıklarını (sigara, alkol, fiziksel aktivite) değerlendiren multivaryat analiz[cite: 1].
* **🤖 Akıllı Sağlık Asistanı ve Tavsiye Motoru:** Analiz sonuçlarına ve kullanıcı profiline göre özelleştirilmiş yaşam tarzı önerileri ve etkileşimli asistan arayüzü[cite: 1].
* **📄 PDF Analiz Raporu Oluşturma:** Tamamlanan test sonuçlarının ve yapay zeka tavsiyelerinin cihazda görüntülenmesi, yazdırılması ve dışa aktarılması[cite: 1].
* **📈 Kronolojik Sağlık Geçmişi:** Geçmiş testlerin skor bazlı listelenmesi ve zaman içindeki sağlık trendlerinin takibi[cite: 1].

---

## 🏗️ Sistem Mimarisi (Uçtan Uca Yapı)

Mobil uygulama, yerel **N-Katmanlı (N-Layer)** ve **Servis Yönelimli (SOA)** mimariye sahip hibrit bir arka uç ekosistemi ile haberleşmektedir[cite: 1]:

```text
┌─────────────────────────┐
│   Flutter Mobil App     │  ◄── (Bu Depo: Kullanıcı Arayüzü & Raporlama)
└───────────┬─────────────┘
            │ RESTful API (HTTPS / JSON + JWT Bearer)
            ▼
┌─────────────────────────┐      ┌──────────────────────────┐
│   C# .NET 8 Web API     │─────►│   Microsoft SQL Server   │
│  (Ana İş Mantığı & SOA) │      │ (İlişkisel Veri Tabanı)  │
└───────────┬─────────────┘      └──────────────────────────┘
            │ HTTP Mikro Servis Çağrısı
            ▼
┌─────────────────────────┐
│ Python FastAPI ML Motoru│  ◄── (Scikit-learn, Pandas, Random Forest, LR)
└─────────────────────────┘
<img width="319" height="520" alt="image" src="https://github.com/user-attachments/assets/a4fec756-d2d7-443c-9592-9fb638092e9c" />
<img width="295" height="524" alt="image" src="https://github.com/user-attachments/assets/898a65a2-8d1c-4fe6-b4fa-2ad1b5577d5c" />
<img width="354" height="788" alt="image" src="https://github.com/user-attachments/assets/c9dd46dc-6ed9-4a61-a6cd-08a3bc06baf3" />
<img width="363" height="765" alt="image" src="https://github.com/user-attachments/assets/5cb6f988-d250-40d6-9b0e-939918082cec" />
<img width="299" height="653" alt="image" src="https://github.com/user-attachments/assets/7b741739-2598-4114-ad3e-3d7353f0535a" />
<img width="279" height="649" alt="image" src="https://github.com/user-attachments/assets/85324b17-805e-455d-8fb8-1581487d246e" />
<img width="278" height="635" alt="image" src="https://github.com/user-attachments/assets/698753ae-61b7-4205-a72c-6e7e0ab5dafb" />
<img width="299" height="653" alt="image" src="https://github.com/user-attachments/assets/d211248d-bbcc-4955-adba-a9a36ce666f8" />
<img width="326" height="649" alt="image" src="https://github.com/user-attachments/assets/20016916-a04c-46e4-8d54-d2bcf4342e65" />








