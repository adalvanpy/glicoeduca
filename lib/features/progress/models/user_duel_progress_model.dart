// lib/features/progress/models/user_duel_progress_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDuelProgressModel {
  final String id;
  final String userId;
  final int wins;        // ← DEVE EXISTIR
  final int losses;      // ← DEVE EXISTIR
  final int totalGames;  // ← DEVE EXISTIR
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserDuelProgressModel({
    required this.id,
    required this.userId,
    required this.wins,
    required this.losses,
    required this.totalGames,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDuelProgressModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return UserDuelProgressModel(
      id: documentId,
      userId: map['userId'] ?? '',
      wins: (map['wins'] ?? 0).toInt(),
      losses: (map['losses'] ?? 0).toInt(),
      totalGames: (map['totalGames'] ?? 0).toInt(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'wins': wins,
      'losses': losses,
      'totalGames': totalGames,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
