import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_model.dart';
import '../services/word_storage_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<WordModel> words = [];
  List<WordModel> quizWords = [];

  WordModel? currentWord;

  List<String> options = [];

  int correctCount = 0;
  int wrongCount = 0;
  int dailyWordCount = 10;

  int solvedQuestionCount = 0;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final prefs = await SharedPreferences.getInstance();

    dailyWordCount = prefs.getInt('daily_word_count') ?? 10;

    words = await WordStorageService.getWords();

    final availableWords = words.where((word) => !word.learned).toList();

    availableWords.shuffle();

    quizWords = availableWords.take(dailyWordCount).toList();

    if (quizWords.isNotEmpty) {
      generateQuestion();
    }

    setState(() {});
  }

  String calculateNextReviewDate(int level) {
    final now = DateTime.now();

    late DateTime nextDate;

    if (level == 1) {
      nextDate = now.add(const Duration(days: 1));
    } else if (level == 2) {
      nextDate = now.add(const Duration(days: 7));
    } else if (level == 3) {
      nextDate = DateTime(now.year, now.month + 1, now.day);
    } else if (level == 4) {
      nextDate = DateTime(now.year, now.month + 3, now.day);
    } else if (level == 5) {
      nextDate = DateTime(now.year, now.month + 6, now.day);
    } else {
      nextDate = DateTime(now.year + 1, now.month, now.day);
    }

    return '${nextDate.day}.${nextDate.month}.${nextDate.year}';
  }

  void generateQuestion() {
    final random = Random();

    final availableQuizWords =
    quizWords.where((word) => !word.learned).toList();

    if (availableQuizWords.isEmpty) {
      currentWord = null;
      options.clear();

      setState(() {});
      return;
    }

    currentWord =
    availableQuizWords[random.nextInt(availableQuizWords.length)];

    options.clear();

    options.add(currentWord!.turkish);

    while (options.length < 4 && words.length > options.length) {
      final randomWord = words[random.nextInt(words.length)];

      if (!options.contains(randomWord.turkish)) {
        options.add(randomWord.turkish);
      }
    }

    options.shuffle();

    setState(() {});
  }

  Future<void> answerQuestion(String selected) async {
    if (currentWord == null) return;

    solvedQuestionCount++;

    final isCorrect = selected == currentWord!.turkish;

    final currentIndex = words.indexWhere(
          (word) =>
      word.english == currentWord!.english &&
          word.turkish == currentWord!.turkish,
    );

    if (currentIndex == -1) return;

    if (isCorrect) {
      correctCount++;

      words[currentIndex].correctCount++;
      words[currentIndex].level++;

      if (words[currentIndex].level >= 6) {
        words[currentIndex].level = 6;
        words[currentIndex].learned = true;
        words[currentIndex].nextReviewDate = 'Tamamlandı';
      } else {
        words[currentIndex].nextReviewDate =
            calculateNextReviewDate(words[currentIndex].level);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Doğru cevap'),
        ),
      );
    } else {
      wrongCount++;

      words[currentIndex].wrongCount++;
      words[currentIndex].level = 0;
      words[currentIndex].learned = false;
      words[currentIndex].nextReviewDate = 'Tekrar başa döndü';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Yanlış cevap'),
        ),
      );
    }

    await WordStorageService.saveAllWords(words);

    quizWords = words
        .where((word) => !word.learned)
        .take(dailyWordCount)
        .toList();

    generateQuestion();
  }

  double calculateProgress() {
    if (quizWords.isEmpty) return 0;

    final learnedCount =
        quizWords.where((word) => word.learned).length;

    return learnedCount / quizWords.length;
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: Text('Önce kelime ekleyin'),
        ),
      );
    }

    if (currentWord == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('6 Tekrar Quiz'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tebrikler!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bu oturumdaki tüm kelimeleri öğrendiniz.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    loadWords();
                  },
                  child: const Text('Yeni Quiz Başlat'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progress = calculateProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text('6 Tekrar Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              color: const Color(0xFFE8EAF6),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          color: Colors.indigo,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Günlük soru havuzu: $dailyWordCount kelime',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'İlerleme: %${(progress * 100).round()}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'İngilizce Kelime',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currentWord?.english ?? '',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            ...options.map(
                  (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => answerQuestion(option),
                    child: Text(option),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text('Çözülen Soru: $solvedQuestionCount'),
                    Text('Doğru: $correctCount'),
                    Text('Yanlış: $wrongCount'),
                    Text('Seviye: ${currentWord?.level ?? 0}/6'),
                    Text(
                      'Sonraki Tekrar: ${currentWord?.nextReviewDate ?? 'Belirlenmedi'}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}