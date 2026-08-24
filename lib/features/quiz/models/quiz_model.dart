class QuestionModel {
  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String explanation;
  final int order;
  final String level;

  QuestionModel({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.explanation,
    required this.order,
    required this.level,
  });

  factory QuestionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return QuestionModel(
      id: documentId,
      question: map['question'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      optionC: map['optionC'] ?? '',
      optionD: map['optionD'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      explanation: map['explanation'] ?? '',
      order: map['order'] ?? 0,
      level: map['level'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'order': order,
      'level': level,
    };
  }

}
