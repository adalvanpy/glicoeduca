class DuelModel {
  final String id;
  final String contextId;
  final String foodAId;
  final String foodBId;
  final String correctFoodId;
  final String correctAnswerLabel;
  final int order;

  String get correctAnswerId => correctFoodId;

  DuelModel({
    required this.id,
    required this.contextId,
    required this.foodAId,
    required this.foodBId,
    required this.correctFoodId,
    this.correctAnswerLabel = '',
    this.order = 0,
  });

  factory DuelModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final fallbackCorrectFoodId = [
      map['correctFoodId'],
      map['correctAnswerId'],
      map['correctAnswerItemId'],
      map['answerId'],
      map['winnerId'],
    ].firstWhere(
      (value) => value is String && value.trim().isNotEmpty,
      orElse: () => '',
    );

    final fallbackCorrectAnswerLabel = [
      map['correctAnswer'],
      map['correctAnswerText'],
      map['correctAnswerLabel'],
      map['answerText'],
      map['correctOption'],
      map['winnerName'],
    ].firstWhere(
      (value) => value is String && value.trim().isNotEmpty,
      orElse: () => '',
    );

    final rawOrder = map['order'];
    final parsedOrder = rawOrder is int
        ? rawOrder
        : (rawOrder is num ? rawOrder.toInt() : 0);

    return DuelModel(
      id: documentId,
      contextId: map['contextId'] ?? '',
      foodAId: map['foodAId'] ?? '',
      foodBId: map['foodBId'] ?? '',
      correctFoodId: fallbackCorrectFoodId is String ? fallbackCorrectFoodId : '',
      correctAnswerLabel: fallbackCorrectAnswerLabel is String ? fallbackCorrectAnswerLabel : '',
      order: parsedOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contextId': contextId,
      'foodAId': foodAId,
      'foodBId': foodBId,
      'correctFoodId': correctFoodId,
      'correctAnswerLabel': correctAnswerLabel,
      'order': order,
    };
  }
}

