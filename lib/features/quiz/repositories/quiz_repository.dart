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
        print('🔍 Filtrando perguntas por nível: $levelMap');
      }
      
      final snapshot = await query.get();
      print('📄 Total de perguntas encontradas: ${snapshot.docs.length}');

      final questions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return QuestionModel.fromMap(data, doc.id);
      }).toList();

      // 🔥 ORDENA NO CÓDIGO (já que o índice pode não estar pronto)
      questions.sort((a, b) => a.order.compareTo(b.order));

      if (questions.length > 10) {
        return questions.take(10).toList();
      }

      return questions;
      
    } catch (e) {
      print('❌ Erro ao carregar perguntas: $e');
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

  // 🔥 CORRIGIDO: SALVA NA COLEÇÃO 'user_quiz_progress'
  Future<void> saveResult(UserQuizProgressModel result) async {
    try {
      print('💾 Salvando resultado na coleção user_quiz_progress...');
      print('   userId: ${result.userId}');
      print('   hits: ${result.hits}');
      print('   level: ${result.level}');
      print('   total: ${result.total}');
      
      final docRef = await _firestore
          .collection('user_quiz_progress')  // ← NOME CORRETO DA COLEÇÃO
          .add(result.toMap());
      
      print('✅ Resultado salvo com ID: ${docRef.id}');
    } catch (e) {
      print('❌ Erro ao salvar resultado: $e');
      rethrow;
    }
  }

  // 🔥 BUSCA OS RESULTADOS DO USUÁRIO
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
      print('❌ Erro ao buscar resultados: $e');
      return [];
    }
  }
}