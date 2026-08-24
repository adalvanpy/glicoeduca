import 'package:flutter/foundation.dart';

import '../models/quiz_model.dart';
import '../../progress/models/user_quiz_progress_model.dart';
import '../repositories/quiz_repository.dart';

class QuizController extends ChangeNotifier {
  final QuizRepository repository;

  QuizController({required this.repository});

  List<QuestionModel> quizzes = [];
  int currentIndex = 0;
  int hits = 0;
  String? selectedAnswer;
  bool isLoading = false;
  bool isFinished = false;
  String? errorMessage;
  String? currentLevel;

  QuestionModel? get currentQuestion => quizzes.isEmpty ? null : quizzes[currentIndex];
  double get progress => quizzes.isEmpty ? 0 : (currentIndex + 1) / quizzes.length;

  Future<void> loadQuiz({String? level}) async {
    isLoading = true; 
    errorMessage = null; 
    currentLevel = level;
    notifyListeners();
    
    try { 
      quizzes = await repository.getQuizQuestions(level: level); 
      print('📊 Perguntas encontradas: ${quizzes.length} para o nível: $level');
      reset(); 
      if (quizzes.isEmpty) {
        errorMessage = 'Nenhuma pergunta disponível para o nível $level.';
      }
    } catch (e) { 
      print('❌ Erro: $e');
      errorMessage = 'Não foi possível carregar o quiz.'; 
    } finally { 
      isLoading = false; 
      notifyListeners(); 
    }
  }

  void selectAnswer(String answer) { 
    if (!isFinished) { 
      selectedAnswer = answer; 
      notifyListeners(); 
    } 
  }

  bool get selectedAnswerIsCorrect {
    final question = currentQuestion;
    if (question == null || selectedAnswer == null) return false;
    final options = [question.optionA, question.optionB, question.optionC, question.optionD];
    final index = options.indexOf(selectedAnswer!);
    final letter = index >= 0 ? String.fromCharCode(65 + index) : selectedAnswer;
    return selectedAnswer == question.correctAnswer || letter == question.correctAnswer;
  }

  Future<void> next({String? userId}) async {
    if (selectedAnswer == null || currentQuestion == null) return;
    if (selectedAnswerIsCorrect) hits++;
    
    print('🔍 Hits: $hits, Index: $currentIndex, Total: ${quizzes.length}');
    
    if (currentIndex < quizzes.length - 1) { 
      currentIndex++; 
      selectedAnswer = null; 
      notifyListeners(); 
      return; 
    }
    
    print('🏁 Quiz finalizado! Salvando resultado...');
    isFinished = true; 
    notifyListeners();
    
    if (userId != null && userId.isNotEmpty) {
      // 🔥 SALVA NA COLEÇÃO 'user_quiz_progress'
      await repository.saveResult(UserQuizProgressModel(
        id: '',
        userId: userId,
        hits: hits,
        total: quizzes.length,
        level: currentLevel ?? 'Fácil',
        createdAt: DateTime.now(),
      ));
      print('✅ Resultado salvo com sucesso!');
    } else {
      print('⚠️ Usuário não logado, resultado não salvo!');
    }
  }

  void reset() { 
    currentIndex = 0; 
    hits = 0; 
    selectedAnswer = null; 
    isFinished = false; 
  }
}