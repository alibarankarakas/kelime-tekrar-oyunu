class WordModel {
  final String english;
  final String turkish;
  final List<String> samples;
  final String imageUrl;

  int level;
  int correctCount;
  int wrongCount;
  bool learned;
  String? nextReviewDate;

  WordModel({
    required this.english,
    required this.turkish,
    required this.samples,
    required this.imageUrl,
    this.level = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.learned = false,
    this.nextReviewDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'english': english,
      'turkish': turkish,
      'samples': samples,
      'imageUrl': imageUrl,
      'level': level,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'learned': learned,
      'nextReviewDate': nextReviewDate,
    };
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      english: json['english'] ?? '',
      turkish: json['turkish'] ?? '',
      samples: List<String>.from(json['samples'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      level: json['level'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      learned: json['learned'] ?? false,
      nextReviewDate: json['nextReviewDate'],
    );
  }
}