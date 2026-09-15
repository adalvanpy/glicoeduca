class FoodModel {
  final String id;
  final String name;
  final String image;
  final String category;
  final String description;
  final double kcal;
  final double carbohydrates;
  final String carbohydrateType;
  final double fiber;
  final double glycemicIndex;
  final String glycemicIndexClassification;
  final double glycemicLoad;
  final String glycemicLoadClassification;
  final double grams;

  FoodModel({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.description,
    required this.kcal,
    required this.carbohydrates,
    required this.carbohydrateType,
    required this.fiber,
    required this.glycemicIndex,
    required this.glycemicIndexClassification,
    required this.glycemicLoad,
    required this.glycemicLoadClassification,
    required this.grams,
  });

  factory FoodModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return FoodModel(
      id: documentId,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      kcal: (map['kcal'] ?? map['calories'] ?? 0).toDouble(),
      carbohydrates: (map['carbohydrates'] ?? 0).toDouble(),
      carbohydrateType: map['carbohydrate_type'] ?? '',
      fiber: (map['fiber'] ?? 0).toDouble(),
      glycemicIndex: (map['glycemicIndex'] ?? 0).toDouble(),
      glycemicIndexClassification: map['glycemicIndexClassification'] ?? '',
      glycemicLoad: (map['glycemicLoad'] ?? 0).toDouble(),
      glycemicLoadClassification: map['glycemicLoadClassification'] ?? '',
      grams: (map['grams'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'category': category,
      'carbohydrate_type': carbohydrateType,
      'description': description,
      'kcal': kcal,
      'carbohydrates': carbohydrates,
      'fiber': fiber,
      'glycemicIndex': glycemicIndex,
      'glycemicIndexClassification': glycemicIndexClassification,
      'glycemicLoad': glycemicLoad,
      'glycemicLoadClassification': glycemicLoadClassification,
      'grams': grams,
    };
  }
}

