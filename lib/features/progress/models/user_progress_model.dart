import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressModel {
  final String id;
  final String userId;
  final String theoryId;     
  final String theoryTitle;   
  final double progress;     
  final DateTime lastAccess;

  UserProgressModel({
    required this.id,
    required this.userId,
    required this.theoryId,
    required this.theoryTitle,
    required this.progress,
    required this.lastAccess,
  });

  factory UserProgressModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return UserProgressModel(
      id: documentId,
      userId: map['userId'] ?? '',
      theoryId: map['theoryId'] ?? '',
      theoryTitle: map['theoryTitle'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(),
      lastAccess: (map['lastAccess'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'theoryId': theoryId,
      'theoryTitle': theoryTitle,
      'progress': progress,
      'lastAccess': lastAccess,
    };
  }
}