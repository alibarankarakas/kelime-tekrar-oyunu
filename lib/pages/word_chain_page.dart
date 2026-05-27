import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_model.dart';
import '../services/word_storage_service.dart';

class WordChainPage extends StatefulWidget {
  const WordChainPage({super.key});

  @override
  State<WordChainPage> createState() => _WordChainPageState();
}

class _WordChainPageState extends State<WordChainPage> {
  List<WordModel> words = [];
  List<WordModel> selectedWords = [];

  String story = '';
  String turkishSummary = '';
  String savedStory = '';

  @override
  void initState() {
    super.initState();
    loadWords();
    loadSavedStory();
  }

  Future<void> loadWords() async {
    final loadedWords = await WordStorageService.getWords();

    setState(() {
      words = loadedWords;
    });
  }

  Future<void> loadSavedStory() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      savedStory = prefs.getString('saved_word_chain_story') ?? '';
    });
  }

  Future<void> saveStory() async {
    if (story.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce hikaye oluşturun')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_word_chain_story', story);

    setState(() {
      savedStory = story;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hikaye kaydedildi')),
    );
  }

  void generateStory() {
    if (words.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hikaye oluşturmak için en az 3 kelime ekleyin'),
        ),
      );
      return;
    }

    final random = Random();
    final shuffled = [...words]..shuffle(random);

    selectedWords = shuffled.take(5).toList();

    final chainText = selectedWords.map((word) => word.english).join(' → ');
    final englishWords = selectedWords.map((word) => word.english).toList();
    final turkishWords = selectedWords.map((word) => word.turkish).join(', ');

    story =
    'Word Chain: $chainText\n\n'
        'Once upon a time, a student wanted to learn new English words. '
        'The first word was "${englishWords[0]}". This word reminded the student of "${englishWords[1]}". '
        'Then the student connected it with "${englishWords[2]}". '
        'After that, "${englishWords.length > 3 ? englishWords[3] : englishWords[0]}" became part of the story. '
        'Finally, the word "${englishWords.length > 4 ? englishWords[4] : englishWords[1]}" completed the chain. '
        'By connecting the words in a meaningful story, the student remembered them more easily.';

    turkishSummary =
    'Bu hikayede $turkishWords kelimeleri bir zincir şeklinde kullanıldı. '
        'Amaç, kelimeleri ezberlemek yerine hikaye içinde ilişkilendirerek daha kalıcı öğrenmektir.';

    setState(() {});
  }

  Widget wordCard(WordModel word) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link, color: Colors.indigo),
        title: Text(word.english),
        subtitle: Text(word.turkish),
      ),
    );
  }

  Widget storyCard({
    required String title,
    required String text,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Chain / Hikaye'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: words.isEmpty
            ? const Center(
          child: Text('Önce kelime ekleyin'),
        )
            : ListView(
          children: [
            const Icon(
              Icons.auto_stories,
              size: 80,
              color: Colors.indigo,
            ),
            const SizedBox(height: 15),
            const Text(
              'Kayıtlı kelimelerden kelime zinciri oluşturur ve bu zincire göre hikaye üretir.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: generateStory,
                icon: const Icon(Icons.create),
                label: const Text('Hikaye Oluştur'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: saveStory,
                icon: const Icon(Icons.save),
                label: const Text('Hikayeyi Kaydet'),
              ),
            ),

            const SizedBox(height: 20),

            if (selectedWords.isNotEmpty) ...[
              const Text(
                'Seçilen Kelimeler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ...selectedWords.map(wordCard),

              const SizedBox(height: 20),

              storyCard(
                title: 'İngilizce Hikaye',
                text: story,
                icon: Icons.menu_book,
              ),

              storyCard(
                title: 'Türkçe Özet',
                text: turkishSummary,
                icon: Icons.translate,
              ),

              storyCard(
                title: 'Görsel Açıklaması',
                text:
                'Bu bölüm LLM görsel modülü yerine gömülü açıklama olarak hazırlandı. '
                    'Hikayeye uygun görsel: kelimeleri öğrenen bir öğrencinin, kelime zinciriyle ilerlediği eğitsel bir sahne.',
                icon: Icons.image,
              ),
            ],

            if (savedStory.isNotEmpty) ...[
              const SizedBox(height: 20),
              storyCard(
                title: 'Kaydedilen Son Hikaye',
                text: savedStory,
                icon: Icons.bookmark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}