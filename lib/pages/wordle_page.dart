import 'dart:math';
import 'package:flutter/material.dart';

import '../models/word_model.dart';
import '../services/word_storage_service.dart';

class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  List<WordModel> words = [];
  WordModel? selectedWord;

  final guessController = TextEditingController();

  List<String> guesses = [];
  int maxTry = 6;
  bool gameFinished = false;
  bool isWin = false;

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    final loadedWords = await WordStorageService.getWords();

    final availableWords = loadedWords
        .where((word) => word.english.trim().length >= 3)
        .toList();

    if (availableWords.isNotEmpty) {
      selectedWord = availableWords[Random().nextInt(availableWords.length)];
    }

    setState(() {
      words = availableWords;
    });
  }

  void checkGuess() {
    if (selectedWord == null || gameFinished) return;

    final guess = guessController.text.trim().toLowerCase();
    final answer = selectedWord!.english.trim().toLowerCase();

    if (guess.length != answer.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${answer.length} harfli kelime girmelisiniz'),
        ),
      );
      return;
    }

    setState(() {
      guesses.add(guess);
      guessController.clear();

      if (guess == answer) {
        gameFinished = true;
        isWin = true;
      } else if (guesses.length >= maxTry) {
        gameFinished = true;
        isWin = false;
      }
    });
  }

  void restartGame() {
    if (words.isEmpty) return;

    setState(() {
      selectedWord = words[Random().nextInt(words.length)];
      guesses.clear();
      guessController.clear();
      gameFinished = false;
      isWin = false;
    });
  }

  Color getBoxColor(String guess, int index) {
    final answer = selectedWord!.english.trim().toLowerCase();

    if (guess[index] == answer[index]) {
      return Colors.green;
    } else if (answer.contains(guess[index])) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  Widget buildGuessRow(String guess) {
    final answerLength = selectedWord!.english.trim().length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(answerLength, (index) {
        return Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: getBoxColor(guess, index),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            guess[index].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedWord == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wordle Bulmaca'),
        ),
        body: const Center(
          child: Text('Wordle için önce en az 3 harfli kelime ekleyin'),
        ),
      );
    }

    final answerLength = selectedWord!.english.trim().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Bulmaca'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.grid_on),
                title: Text('$answerLength harfli İngilizce kelimeyi tahmin et'),
                subtitle: Text('İpucu: ${selectedWord!.turkish}'),
              ),
            ),

            const SizedBox(height: 20),

            ...guesses.map(buildGuessRow),

            const SizedBox(height: 20),

            if (!gameFinished)
              TextField(
                controller: guessController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Tahmin',
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 15),

            if (!gameFinished)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: checkGuess,
                  child: const Text('Tahmin Et'),
                ),
              ),

            if (gameFinished)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        isWin ? 'Tebrikler, bildiniz!' : 'Hakkınız bitti!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Doğru kelime: ${selectedWord!.english}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: restartGame,
                        child: const Text('Yeni Oyun'),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            const Text(
              'Yeşil: doğru harf doğru yerde\nTuruncu: harf var ama yeri yanlış\nGri: harf yok',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}