class DuelModel {
  final String id;
  final String contextId;
  final String foodAId;
  final String foodBId;
  final String correctAnswerId;

  DuelModel({
    required this.id,
    required this.contextId,
    required this.foodAId,
    required this.foodBId,
    required this.correctAnswerId,
  });

  factory DuelModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return DuelModel(
      id: documentId,
      contextId: map['contextId'] ?? '',
      foodAId: map['foodAId'] ?? '',
      foodBId: map['foodBId'] ?? '',
      correctAnswerId: map['correctAnswerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contextId': contextId,
      'foodAId': foodAId,
      'foodBId': foodBId,
      'correctAnswerId': correctAnswerId,
    };
  }
}
