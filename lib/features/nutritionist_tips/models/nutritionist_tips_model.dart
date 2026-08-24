class NutritionistTipsModel {
  final String id;
  final String contextId;
  final String description;
  final String dish;
  final String image;

  NutritionistTipsModel({
    required this.id,
    required this.contextId,
    required this.description,
    required this.dish,
    required this.image,
  });

  factory NutritionistTipsModel.fromMap(Map<String, dynamic> map,
    String documentId,
  ) {
    return NutritionistTipsModel(
      id: documentId,
      contextId: map['contextId'] ?? '',
      description: map['description'] ?? '',
      dish: map['dish'] ?? '',
      image: map['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contextId': contextId,
      'description': description,
      'dish': dish,
      'image': image,
    };
  }



}