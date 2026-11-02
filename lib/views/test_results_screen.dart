import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smarthealthsytemmobil/Models/test_result_model.dart';
import 'package:smarthealthsytemmobil/Services/api_service.dart';
import 'package:smarthealthsytemmobil/views/pdf_preview_screen.dart';

class TestResultsScreen extends StatefulWidget {
  final String userId;

  const TestResultsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<TestResultModel>> _futureResults;

  @override
  void initState() {
    super.initState();
    _futureResults = _apiService.fetchTestResults(widget.userId);
  }

  Color _getRiskColor(double risk) {
    final checkRisk = risk <= 1.0 ? risk * 100 : risk;
    if (checkRisk > 70) return const Color(0xFFDC3545);
    if (checkRisk > 35) return const Color(0xFFFFC107);
    return const Color(0xFF198754);
  }

  String _getRiskStatusText(double risk) {
    final checkRisk = risk <= 1.0 ? risk * 100 : risk;
    if (checkRisk > 70) return "Yüksek Risk";
    if (checkRisk > 35) return "Orta Risk";
    return "Düşük Risk / Sağlıklı";
  }

  // 📄 Türkçe Karakterleri Destekleyen ve Tüm Tahlil Tiplerini Kapsayan PDF Fonksiyonu
  Future<List<int>> _generatePdfBytes(TestResultModel item) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              // cross: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "SMART HEALTH ANALİZ RAPORU",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
                pw.Divider(thickness: 2, color: PdfColors.teal),
                pw.SizedBox(height: 15),
                pw.Text(
                  "Test Türü: ${item.testTypeName}",
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.Text(
                  "Risk Durumu: ${_getRiskStatusText(item.riskPercentage)}",
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.Text(
                  "Risk Oranı: %${item.riskPercentage.toStringAsFixed(1)}",
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.Text(
                  "Sağlık Skoru: ${item.healthScore} / 100",
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 20),

                // 📋 PDF - Kardiyovasküler Tablosu
                if (item.cardiovascularTestData != null) ...[
                  pw.Text(
                    "📋 Kayıtlı Tahlil Parametreleri (Kardiyovasküler):",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table.fromTextArray(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headers: ['Parametre', 'Değer'],
                    data: [
                      [
                        'Yaş / Cinsiyet',
                        '${item.cardiovascularTestData!.age} / ${item.cardiovascularTestData!.gender == 1 ? "Kadın" : "Erkek"}',
                      ],
                      [
                        'Boy / Kilo',
                        '${item.cardiovascularTestData!.height} cm / ${item.cardiovascularTestData!.weight} kg',
                      ],
                      [
                        'Kan Basıncı (Tansiyon)',
                        '${item.cardiovascularTestData!.systolicBP} / ${item.cardiovascularTestData!.diastolicBP} mmHg',
                      ],
                      [
                        'Kolesterol / Glukoz Seviyesi',
                        'Seviye ${item.cardiovascularTestData!.cholesterol} / Seviye ${item.cardiovascularTestData!.glucose}',
                      ],
                      [
                        'Sigara / Alkol Kullanımı',
                        '${item.cardiovascularTestData!.isSmoking ? "Evet" : "Hayır"} / ${item.cardiovascularTestData!.isAlcoholConsumer ? "Evet" : "Hayır"}',
                      ],
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],

                // 📋 PDF - Diyabet Tablosu
                if (item.diabetesTestData != null) ...[
                  pw.Text(
                    "📋 Kayıtlı Tahlil Parametreleri (Diyabet):",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table.fromTextArray(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headers: ['Parametre', 'Değer'],
                    data: [
                      [
                        'Yaş / Cinsiyet',
                        '${item.diabetesTestData!.age} / ${item.diabetesTestData!.gender == "Male" ? "Erkek" : "Kadın"}',
                      ],
                      [
                        'Vücut Kitle Endeksi (BMI)',
                        item.diabetesTestData!.bmi.toStringAsFixed(1),
                      ],
                      [
                        'HbA1c Seviyesi',
                        '%${item.diabetesTestData!.hbA1cLevel}',
                      ],
                      [
                        'Kan Şekeri (Blood Glucose)',
                        '${item.diabetesTestData!.bloodGlucoseLevel} mg/dL',
                      ],
                      [
                        'Hipertansiyon / Kalp Rahatsızlığı',
                        '${item.diabetesTestData!.hypertension == 1 ? "Var" : "Yok"} / ${item.diabetesTestData!.heartDisease == 1 ? "Var" : "Yok"}',
                      ],
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],

                pw.Text(
                  "🤖 Yapay Zeka Özel Tavsiyeleri:",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    item.recommendations,
                    style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Sağlık Analiz Sonuçlarım',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<TestResultModel>>(
        future: _futureResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Henüz bir analiz sonucunuz bulunmuyor.'),
            );
          }

          final results = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              final statusColor = _getRiskColor(item.riskPercentage);

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.06),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 6,
                      height: 50,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(
                      item.testTypeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _getRiskStatusText(item.riskPercentage),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.healthScore}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            'SKOR',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 20),

                            // 🫀 Arayüz - Kardiyo Bilgileri
                            if (item.cardiovascularTestData != null) ...[
                              const Text(
                                "📋 Girilen Tahlil Değerleri:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildCardioGrid(item.cardiovascularTestData!),
                              const SizedBox(height: 16),
                            ],

                            // 🩸 Arayüz - Diyabet Bilgileri
                            if (item.diabetesTestData != null) ...[
                              const Text(
                                "📋 Girilen Tahlil Değerleri:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDiabetesGrid(item.diabetesTestData!),
                              const SizedBox(height: 16),
                            ],

                            const Text(
                              "🤖 Yapay Zeka Tavsiyesi:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.recommendations,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Rapor Görüntüleme Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final pdfBytes = await _generatePdfBytes(
                                    item,
                                  );
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfPreviewScreen(
                                          pdfBytes: pdfBytes,
                                          title: item.testTypeName,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Raporu Görüntüle ve İndir',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🫀 Yardımcı Grid Çiziciler
  Widget _buildCardioGrid(CardiovascularTestData data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        children: [
          _buildGridItem(
            "Yaş / Cinsiyet:",
            "${data.age} / ${data.gender == 1 ? 'Kadın' : 'Erkek'}",
          ),
          _buildGridItem(
            "Boy / Kilo:",
            "${data.height} cm / ${data.weight.toStringAsFixed(1)} kg",
          ),
          _buildGridItem(
            "Kan Basıncı:",
            "${data.systolicBP} / ${data.diastolicBP} mmHg",
          ),
          _buildGridItem(
            "Kolesterol / Şeker:",
            "Seviye ${data.cholesterol} / Seviye ${data.glucose}",
          ),
        ],
      ),
    );
  }

  Widget _buildDiabetesGrid(DiabetesTestData data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        children: [
          _buildGridItem(
            "Yaş / Cinsiyet:",
            "${data.age} / ${data.gender == 'Male' ? 'Erkek' : 'Kadın'}",
          ),
          _buildGridItem("Vücut Kitle (BMI):", data.bmi.toStringAsFixed(1)),
          _buildGridItem("HbA1c Değeri:", "%${data.hbA1cLevel}"),
          _buildGridItem("Açlık Şekeri:", "${data.bloodGlucoseLevel} mg/dL"),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
