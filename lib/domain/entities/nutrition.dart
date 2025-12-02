class Nutrition {
  final String energy;
  final String fat;
  final String protein;
  final String carbs;
  final String sugar;
  final String salt;

  Nutrition({
    required this.energy,
    required this.fat,
    required this.protein,
    required this.carbs,
    required this.sugar,
    required this.salt,
  });
}

class ScanResult {
  final String id;
  final String imagePath; // Local path to cropped image
  final DateTime timestamp;
  final Nutrition nutrition;

  ScanResult({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.nutrition,
  });
}
