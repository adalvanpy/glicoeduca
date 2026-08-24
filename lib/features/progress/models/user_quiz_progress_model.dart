// user_quiz_progress_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuizProgressModel {
  final String id;
  final String userId;
  final int hits;
  final int total;
  final String level;
  final DateTime createdAt;

  UserQuizProgressModel({
    required this.id,
    required this.userId,
    required this.hits,
    required this.total,
    required this.level,
    required this.createdAt,
  });

  factory UserQuizProgressModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return UserQuizProgressModel(
      id: documentId,
      userId: map['userId'] ?? '',
      hits: (map['hits'] ?? 0).toInt(),
      total: (map['total'] ?? 0).toInt(),
      level: map['level'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'hits': hits,
      'total': total,
      'level': level,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
