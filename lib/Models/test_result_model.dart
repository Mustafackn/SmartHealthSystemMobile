class TestResultModel {
  final int id;
  final String userId;
  final int testTypeId;
  final String testTypeName; // testType.testName içerisinden maplenecek
  final double riskPercentage;
  final int healthScore;
  final String recommendations;
  final DateTime createdDate;
  final bool isActive;

  // Alt detay tabloları (Null gelebilirler)
  final CardiovascularTestData? cardiovascularTestData;
  final DiabetesTestData? diabetesTestData;
  final CancerTestData? cancerTestData;

  TestResultModel({
    required this.id,
    required this.userId,
    required this.testTypeId,
    required this.testTypeName,
    required this.riskPercentage,
    required this.healthScore,
    required this.recommendations,
    required this.createdDate,
    required this.isActive,
    this.cardiovascularTestData,
    this.diabetesTestData,
    this.cancerTestData,
  });

  factory TestResultModel.fromJson(Map<String, dynamic> json) {
    // 🧠 Risk yüzdesindeki uç değerleri (örn: 22780) normalize ediyoruz
    double rawRisk = (json['riskPercentage'] as num?)?.toDouble() ?? 0.0;
    if (rawRisk > 100) {
      rawRisk = rawRisk / 1000;
    }
    if (rawRisk > 100) rawRisk = 100.0;

    // testType nesnesinin içindeki testName alanını güvenle çekiyoruz
    String extractedTypeName = 'Bilinmeyen Analiz';
    if (json['testType'] != null && json['testType']['testName'] != null) {
      extractedTypeName = json['testType']['testName'];
    }

    return TestResultModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      testTypeId: json['testTypeId'] ?? 0,
      testTypeName: extractedTypeName,
      riskPercentage: rawRisk,
      healthScore: json['healthScore'] ?? 0,
      recommendations: json['recommendations'] ?? '',
      isActive: json['isActive'] ?? true,
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : DateTime.now(),

      // Alt verileri Json objelerine göre parse etme
      cardiovascularTestData: json['cardiovascularTestData'] != null
          ? CardiovascularTestData.fromJson(json['cardiovascularTestData'])
          : null,
      diabetesTestData: json['diabetesTestData'] != null
          ? DiabetesTestData.fromJson(json['diabetesTestData'])
          : null,
      cancerTestData: json['cancerTestData'] != null
          ? CancerTestData.fromJson(json['cancerTestData'])
          : null,
    );
  }
}

// 🫀 Kardiyovasküler Tablo Detay Modeli
class CardiovascularTestData {
  final int id;
  final int testResultId;
  final int age;
  final int gender;
  final int height;
  final double weight;
  final int systolicBP;
  final int diastolicBP;
  final int cholesterol;
  final int glucose;
  final bool isSmoking;
  final bool isAlcoholConsumer;
  final bool isActive;

  CardiovascularTestData({
    required this.id,
    required this.testResultId,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.systolicBP,
    required this.diastolicBP,
    required this.cholesterol,
    required this.glucose,
    required this.isSmoking,
    required this.isAlcoholConsumer,
    required this.isActive,
  });

  factory CardiovascularTestData.fromJson(Map<String, dynamic> json) {
    return CardiovascularTestData(
      id: json['id'] ?? 0,
      testResultId: json['testResultId'] ?? 0,
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 1,
      height: json['height'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      systolicBP: json['systolicBP'] ?? 0,
      diastolicBP: json['diastolicBP'] ?? 0,
      cholesterol: json['cholesterol'] ?? 1,
      glucose: json['glucose'] ?? 1,
      isSmoking: json['isSmoking'] ?? false,
      isAlcoholConsumer: json['isAlcoholConsumer'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}

// 🩸 Diyabet Tablo Detay Modeli
class DiabetesTestData {
  final int id;
  final int testResultId;
  final String gender;
  final int age;
  final int hypertension;
  final int heartDisease;
  final String smokingHistory;
  final double bmi;
  final double hbA1cLevel;
  final double bloodGlucoseLevel;
  final bool isActive;

  DiabetesTestData({
    required this.id,
    required this.testResultId,
    required this.gender,
    required this.age,
    required this.hypertension,
    required this.heartDisease,
    required this.smokingHistory,
    required this.bmi,
    required this.hbA1cLevel,
    required this.bloodGlucoseLevel,
    required this.isActive,
  });

  factory DiabetesTestData.fromJson(Map<String, dynamic> json) {
    return DiabetesTestData(
      id: json['id'] ?? 0,
      testResultId: json['testResultId'] ?? 0,
      gender: json['gender'] ?? 'Male',
      age: json['age'] ?? 0,
      hypertension: json['hypertension'] ?? 0,
      heartDisease: json['heartDisease'] ?? 0,
      smokingHistory: json['smokingHistory'] ?? '',
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      hbA1cLevel: (json['hbA1cLevel'] as num?)?.toDouble() ?? 0.0,
      bloodGlucoseLevel: (json['bloodGlucoseLevel'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }
}

// 🎗️ Kanser Tablo Detay Modeli (Gelecekte genişletmek istersen hazır)
class CancerTestData {
  final int id;
  final int testResultId;

  CancerTestData({required this.id, required this.testResultId});

  factory CancerTestData.fromJson(Map<String, dynamic> json) {
    return CancerTestData(
      id: json['id'] ?? 0,
      testResultId: json['testResultId'] ?? 0,
    );
  }
}
