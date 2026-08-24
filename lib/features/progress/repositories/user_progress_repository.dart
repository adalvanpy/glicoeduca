import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore;

  ProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<UserProgressModel>> getUserProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return UserProgressModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProgress({
    required String userId,
    required String theoryId,
    required String theoryTitle,
    required double progress,
  }) async {
    try {
      final existing = await _firestore
          .collection('user_progress')
          .where('userId', isEqualTo: userId)
          .where('theoryId', isEqualTo: theoryId)
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final currentProgress = doc.data()['progress'] ?? 0.0;
        
        if (progress > currentProgress) {
          await _firestore
              .collection('user_progress')
              .doc(doc.id)
              .update({
            'progress': progress,
            'lastAccess': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await _firestore.collection('user_progress').add({
          'userId': userId,
          'theoryId': theoryId,
          'theoryTitle': theoryTitle,
          'progress': progress,
          'lastAccess': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Erro ao salvar progresso: $e');
    }
  }
}