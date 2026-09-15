import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quiz_model.dart';
import '../../progress/models/user_quiz_progress_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore;

  QuizRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<QuestionModel>> getQuizQuestions({String? level}) async {
    try {
      Query query = _firestore.collection('quizzes');
      
      if (level != null && level.isNotEmpty) {
        final levelMap = _mapLevel(level);
        query = query.where('level', isEqualTo: levelMap);

      }
      
      final snapshot = await query.get();

      final questions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return QuestionModel.fromMap(data, doc.id);
      }).toList();

      questions.sort((a, b) => a.order.compareTo(b.order));

      if (questions.length > 10) {
        return questions.take(10).toList();
      }

      return questions;
      
    } catch (e) {

      rethrow;
    }
  }

  String _mapLevel(String level) {
    switch (level) {
      case 'Fácil':
        return 'fácil';
      case 'Médio':
        return 'médio';
      case 'Difícil':
        return 'difícil';
      default:
        return 'fácil';
    }
  }

  Future<void> saveResult(UserQuizProgressModel result) async {
    try {
      await _firestore
          .collection('user_quiz_progress')
          .add(result.toMap());
    } catch (_) {
      rethrow;
    }
  }

  Future<List<UserQuizProgressModel>> getResultsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_quiz_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return UserQuizProgressModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {

      return [];
    }
  }
}
