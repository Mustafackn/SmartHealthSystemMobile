import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final List<int> pdfBytes;
  final String title;

  const PdfPreviewScreen({
    Key? key,
    required this.pdfBytes,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$title Analiz Raporu',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => Uint8List.fromList(pdfBytes),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
        pdfFileName: "SmartHealth_${title.replaceAll(' ', '_')}_Raporu.pdf",
      ),
    );
  }
}
