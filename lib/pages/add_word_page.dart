import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_storage_service.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final englishController = TextEditingController();
  final turkishController = TextEditingController();

  final sentence1Controller = TextEditingController();
  final sentence2Controller = TextEditingController();
  final sentence3Controller = TextEditingController();

  final imageController = TextEditingController();

  Future<void> saveWord() async {
    if (englishController.text.isEmpty ||
        turkishController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'İngilizce ve Türkçe kelime zorunludur',
          ),
        ),
      );
      return;
    }

    final word = WordModel(
      english: englishController.text.trim(),
      turkish: turkishController.text.trim(),
      samples: [
        sentence1Controller.text.trim(),
        sentence2Controller.text.trim(),
        sentence3Controller.text.trim(),
      ].where((sentence) => sentence.isNotEmpty).toList(),
      imageUrl: imageController.text.trim(),
    );

    await WordStorageService.addWord(word);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kelime başarıyla kaydedildi'),
      ),
    );

    englishController.clear();
    turkishController.clear();

    sentence1Controller.clear();
    sentence2Controller.clear();
    sentence3Controller.clear();

    imageController.clear();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Ekle'),
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
                onPressed: saveWord,
                icon: const Icon(Icons.save),
                label: const Text('Kelimeyi Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}