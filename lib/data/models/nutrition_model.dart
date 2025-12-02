import '../../domain/entities/nutrition.dart';

class NutritionModel extends Nutrition {
  NutritionModel({
    required String energy,
    required String fat,
    required String protein,
    required String carbs,
    required String sugar,
    required String salt,
  }) : super(
          energy: energy,
          fat: fat,
          protein: protein,
          carbs: carbs,
          sugar: sugar,
          salt: salt,
        );

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      energy: json['energy'] ?? '0',
      fat: json['fat'] ?? '0',
      protein: json['protein'] ?? '0',
      carbs: json['carbs'] ?? '0',
      sugar: json['sugar'] ?? '0',
      salt: json['salt'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energy': energy,
      'fat': fat,
      'protein': protein,
      'carbs': carbs,
      'sugar': sugar,
      'salt': salt,
    };
  }
}

class ScanResultModel extends ScanResult {
  ScanResultModel({
    required String id,
    required String name,
    required String imagePath,
    required DateTime timestamp,
    required NutritionModel nutrition,
  }) : super(
          id: id,
          name: name,
          imagePath: imagePath,
          timestamp: timestamp,
          nutrition: nutrition,
        );

  factory ScanResultModel.fromMap(Map<String, dynamic> map) {
    return ScanResultModel(
      id: map['id'],
      name: map['name'] ?? 'Scan ${map['timestamp']}', // Default name if null
      imagePath: map['imagePath'],
      timestamp: DateTime.parse(map['timestamp']),
      nutrition: NutritionModel(
        energy: map['energy'],
        fat: map['fat'],
        protein: map['protein'],
        carbs: map['carbs'],
        sugar: map['sugar'],
        salt: map['salt'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'energy': nutrition.energy,
      'fat': nutrition.fat,
      'protein': nutrition.protein,
      'carbs': nutrition.carbs,
      'sugar': nutrition.sugar,
      'salt': nutrition.salt,
    };
  }
}
