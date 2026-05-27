import 'package:flutter/material.dart';

import '../models/word_model.dart';
import '../services/word_storage_service.dart';
import 'edit_word_page.dart';

class WordListPage extends StatefulWidget {
  const WordListPage({super.key});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  List<WordModel> words = [];
  List<WordModel> filteredWords = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final loadedWords = await WordStorageService.getWords();

    setState(() {
      words = loadedWords;
      filteredWords = loadedWords;
    });
  }

  void searchWord(String value) {
    final query = value.toLowerCase();

    final results = words.where((word) {
      return word.english.toLowerCase().contains(query) ||
          word.turkish.toLowerCase().contains(query);
    }).toList();

    setState(() {
      filteredWords = results;
    });
  }

  int getRealIndex(WordModel word) {
    return words.indexWhere(
          (item) => item.english == word.english && item.turkish == word.turkish,
    );
  }

  Future<void> deleteWord(int index) async {
    final realIndex = getRealIndex(filteredWords[index]);

    await WordStorageService.deleteWord(realIndex);
    await loadWords();
  }

  Future<void> editWord(int index) async {
    final word = filteredWords[index];
    final realIndex = getRealIndex(word);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditWordPage(
          word: word,
          index: realIndex,
        ),
      ),
    );

    if (result == true) {
      await loadWords();
    }
  }

  Color levelColor(int level) {
    if (level >= 6) {
      return Colors.green;
    } else if (level >= 4) {
      return Colors.orange;
    } else {
      return Colors.indigo;
    }
  }

  Widget infoRow({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Listesi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: searchController,
              onChanged: searchWord,
              decoration: const InputDecoration(
                labelText: 'Kelime Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredWords.isEmpty
                ? const Center(
              child: Text('Kelime bulunamadı'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredWords.length,
              itemBuilder: (context, index) {
                final word = filteredWords[index];

                return Card(
                  elevation: 3,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: levelColor(word.level),
                      child: Text(
                        '${word.level}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      word.english,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(word.turkish),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            infoRow(
                              icon: Icons.check_circle,
                              text: 'Doğru Sayısı: ${word.correctCount}',
                              color: Colors.green,
                            ),
                            infoRow(
                              icon: Icons.cancel,
                              text: 'Yanlış Sayısı: ${word.wrongCount}',
                              color: Colors.red,
                            ),
                            infoRow(
                              icon: Icons.stacked_bar_chart,
                              text: 'Seviye: ${word.level}/6',
                            ),
                            infoRow(
                              icon: Icons.schedule,
                              text:
                              'Sonraki Tekrar: ${word.nextReviewDate ?? 'Belirlenmedi'}',
                            ),
                            infoRow(
                              icon: word.learned
                                  ? Icons.school
                                  : Icons.pending,
                              text: word.learned
                                  ? 'Öğrenildi'
                                  : 'Öğrenme aşamasında',
                              color: word.learned
                                  ? Colors.green
                                  : Colors.orange,
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Örnek Cümleler',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            if (word.samples.isEmpty)
                              const Text('Örnek cümle yok'),

                            ...word.samples.map(
                                  (sample) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(sample)),
                                  ],
                                ),
                              ),
                            ),

                            if (word.imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Resim Bilgisi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(word.imageUrl),
                            ],

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => editWord(index),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Düzenle'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => deleteWord(index),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text('Sil'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}