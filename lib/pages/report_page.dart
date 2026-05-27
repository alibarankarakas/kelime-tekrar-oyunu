import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/word_model.dart';
import '../services/word_storage_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<WordModel> words = [];

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final loadedWords = await WordStorageService.getWords();

    setState(() {
      words = loadedWords;
    });
  }

  Future<void> createPdfReport() async {
    final pdf = pw.Document();

    final totalWords = words.length;
    final learnedWords = words.where((word) => word.learned).length;
    final unlearnedWords = totalWords - learnedWords;

    final successRate = totalWords == 0
        ? 0
        : ((learnedWords / totalWords) * 100).round();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Kelime Ezberleme Analiz Raporu'),
          ),
          pw.Text('Toplam Kelime: $totalWords'),
          pw.Text('Ogrenilen Kelime: $learnedWords'),
          pw.Text('Ogrenilmeyen Kelime: $unlearnedWords'),
          pw.Text('Basari Orani: %$successRate'),
          pw.SizedBox(height: 20),
          pw.Text(
            'Kelime Detaylari',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: [
              'Ingilizce',
              'Turkce',
              'Seviye',
              'Dogru',
              'Yanlis',
              'Durum',
              'Sonraki Tekrar',
            ],
            data: words.map((word) {
              return [
                word.english,
                word.turkish,
                '${word.level}/6',
                word.correctCount.toString(),
                word.wrongCount.toString(),
                word.learned ? 'Ogrenildi' : 'Devam Ediyor',
                word.nextReviewDate ?? 'Belirlenmedi',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalWords = words.length;
    final learnedWords = words.where((word) => word.learned).length;
    final unlearnedWords = totalWords - learnedWords;

    final successRate = totalWords == 0
        ? 0
        : ((learnedWords / totalWords) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Raporu'),
        actions: [
          IconButton(
            onPressed: words.isEmpty ? null : createPdfReport,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF / Yazdır',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: totalWords == 0
            ? const Center(
          child: Text('Rapor için önce kelime eklemelisiniz'),
        )
            : ListView(
          children: [
            const Icon(
              Icons.bar_chart,
              size: 80,
              color: Colors.indigo,
            ),
            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Toplam Kelime'),
                trailing: Text(
                  totalWords.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading:
                const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Öğrenilen Kelime'),
                trailing: Text(
                  learnedWords.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Öğrenilmeyen Kelime'),
                trailing: Text(
                  unlearnedWords.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Başarı Oranı'),
                trailing: Text(
                  '%$successRate',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: createPdfReport,
                icon: const Icon(Icons.print),
                label: const Text('PDF Oluştur / Yazdır'),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Kelime Seviye Durumu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...words.map(
                  (word) => Card(
                child: ListTile(
                  title: Text('${word.english} - ${word.turkish}'),
                  subtitle: Text(
                    'Seviye: ${word.level}/6 | Doğru: ${word.correctCount} | Yanlış: ${word.wrongCount}',
                  ),
                  trailing: word.learned
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.hourglass_bottom),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}