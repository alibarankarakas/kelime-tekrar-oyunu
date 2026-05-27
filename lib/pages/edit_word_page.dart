import 'package:flutter/material.dart';

import '../models/word_model.dart';
import '../services/word_storage_service.dart';

class EditWordPage extends StatefulWidget {
  final WordModel word;
  final int index;

  const EditWordPage({
    super.key,
    required this.word,
    required this.index,
  });

  @override
  State<EditWordPage> createState() => _EditWordPageState();
}

class _EditWordPageState extends State<EditWordPage> {
  final englishController = TextEditingController();
  final turkishController = TextEditingController();

  final sentence1Controller = TextEditingController();
  final sentence2Controller = TextEditingController();
  final sentence3Controller = TextEditingController();

  final imageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    englishController.text = widget.word.english;
    turkishController.text = widget.word.turkish;
    imageController.text = widget.word.imageUrl;

    if (widget.word.samples.isNotEmpty) {
      sentence1Controller.text = widget.word.samples[0];
    }

    if (widget.word.samples.length > 1) {
      sentence2Controller.text = widget.word.samples[1];
    }

    if (widget.word.samples.length > 2) {
      sentence3Controller.text = widget.word.samples[2];
    }
  }

  Future<void> updateWord() async {
    if (englishController.text.isEmpty || turkishController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İngilizce ve Türkçe kelime zorunludur'),
        ),
      );
      return;
    }

    final updatedWord = WordModel(
      english: englishController.text.trim(),
      turkish: turkishController.text.trim(),
      samples: [
        sentence1Controller.text.trim(),
        sentence2Controller.text.trim(),
        sentence3Controller.text.trim(),
      ].where((sentence) => sentence.isNotEmpty).toList(),
      imageUrl: imageController.text.trim(),
      level: widget.word.level,
      correctCount: widget.word.correctCount,
      wrongCount: widget.word.wrongCount,
      learned: widget.word.learned,
      nextReviewDate: widget.word.nextReviewDate,
    );

    await WordStorageService.updateWord(widget.index, updatedWord);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kelime güncellendi'),
      ),
    );

    Navigator.pop(context, true);
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    englishController.dispose();
    turkishController.dispose();
    sentence1Controller.dispose();
    sentence2Controller.dispose();
    sentence3Controller.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            inputField(
              controller: englishController,
              label: 'İngilizce Kelime',
              icon: Icons.language,
            ),
            inputField(
              controller: turkishController,
              label: 'Türkçe Karşılığı',
              icon: Icons.translate,
            ),
            inputField(
              controller: sentence1Controller,
              label: 'Örnek Cümle 1',
              icon: Icons.text_fields,
              maxLines: 2,
            ),
            inputField(
              controller: sentence2Controller,
              label: 'Örnek Cümle 2',
              icon: Icons.text_fields,
              maxLines: 2,
            ),
            inputField(
              controller: sentence3Controller,
              label: 'Örnek Cümle 3',
              icon: Icons.text_fields,
              maxLines: 2,
            ),
            inputField(
              controller: imageController,
              label: 'Resim Linki / Resim Yolu',
              icon: Icons.image,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: updateWord,
                icon: const Icon(Icons.save),
                label: const Text('Değişiklikleri Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}