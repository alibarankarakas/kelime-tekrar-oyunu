import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';

class WordStorageService {
  static const String key = 'words';

  static Future<List<WordModel>> getWords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data
        .map((item) => WordModel.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> addWord(WordModel word) async {
    final prefs = await SharedPreferences.getInstance();
    final words = prefs.getStringList(key) ?? [];

    words.add(jsonEncode(word.toJson()));

    await prefs.setStringList(key, words);
  }

  static Future<void> saveAllWords(List<WordModel> words) async {
    final prefs = await SharedPreferences.getInstance();

    final data = words.map((word) => jsonEncode(word.toJson())).toList();

    await prefs.setStringList(key, data);
  }

  static Future<void> updateWord(int index, WordModel updatedWord) async {
    final words = await getWords();

    if (index >= 0 && index < words.length) {
      words[index] = updatedWord;
      await saveAllWords(words);
    }
  }

  static Future<void> deleteWord(int index) async {
    final words = await getWords();

    if (index >= 0 && index < words.length) {
      words.removeAt(index);
      await saveAllWords(words);
    }
  }

  static Future<void> resetAllProgress() async {
    final words = await getWords();

    for (final word in words) {
      word.level = 0;
      word.correctCount = 0;
      word.wrongCount = 0;
      word.learned = false;
      word.nextReviewDate = null;
    }

    await saveAllWords(words);
  }

  static Future<void> addSampleWords() async {
    final words = await getWords();

    final sampleWords = [
      WordModel(
        english: 'Brain',
        turkish: 'Beyin',
        samples: [
          'The brain controls the body.',
          'Learning improves the brain.',
        ],
        imageUrl: 'https://example.com/brain.jpg',
      ),
      WordModel(
        english: 'Night',
        turkish: 'Gece',
        samples: [
          'The stars shine at night.',
          'I study English at night.',
        ],
        imageUrl: 'https://example.com/night.jpg',
      ),
      WordModel(
        english: 'Tiger',
        turkish: 'Kaplan',
        samples: [
          'The tiger runs fast.',
          'A tiger lives in the forest.',
        ],
        imageUrl: 'https://example.com/tiger.jpg',
      ),
      WordModel(
        english: 'Robin',
        turkish: 'Kızılgerdan kuşu',
        samples: [
          'A robin sings in the tree.',
          'The robin helped the child.',
        ],
        imageUrl: 'https://example.com/robin.jpg',
      ),
      WordModel(
        english: 'Noble',
        turkish: 'Soylu',
        samples: [
          'He made a noble decision.',
          'The noble hero saved the village.',
        ],
        imageUrl: 'https://example.com/noble.jpg',
      ),
      WordModel(
        english: 'Apple',
        turkish: 'Elma',
        samples: [
          'I eat an apple every day.',
          'The apple is red.',
        ],
        imageUrl: 'https://example.com/apple.jpg',
      ),
      WordModel(
        english: 'Book',
        turkish: 'Kitap',
        samples: [
          'This book is useful.',
          'I read a book in the evening.',
        ],
        imageUrl: 'https://example.com/book.jpg',
      ),
      WordModel(
        english: 'Water',
        turkish: 'Su',
        samples: [
          'Water is important for life.',
          'Please drink water.',
        ],
        imageUrl: 'https://example.com/water.jpg',
      ),
      WordModel(
        english: 'House',
        turkish: 'Ev',
        samples: [
          'My house is near the school.',
          'This house has a garden.',
        ],
        imageUrl: 'https://example.com/house.jpg',
      ),
      WordModel(
        english: 'Friend',
        turkish: 'Arkadaş',
        samples: [
          'My friend helps me.',
          'A good friend is valuable.',
        ],
        imageUrl: 'https://example.com/friend.jpg',
      ),
    ];

    for (final sample in sampleWords) {
      final exists = words.any(
            (word) =>
        word.english.toLowerCase() == sample.english.toLowerCase() &&
            word.turkish.toLowerCase() == sample.turkish.toLowerCase(),
      );

      if (!exists) {
        words.add(sample);
      }
    }

    await saveAllWords(words);
  }
}