import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../controllers/quiz_controller.dart';
import '../repositories/quiz_repository.dart';

class QuizPage extends StatefulWidget {
  final QuizController? controller;
  final String? level;

  const QuizPage({
    super.key,
    this.controller,
    this.level = 'Fácil',
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? QuizController(repository: QuizRepository());
    _controller.addListener(_refresh);
    
    if (_controller.quizzes.isEmpty) {
      _controller.loadQuiz(level: widget.level);
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _controller.currentQuestion;
    final hasQuestion = question != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasQuestion
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(22, 26, 22, 12),
                          child: _content(question!),
                        )
                      : _message(),
            ),
            _bottom(),
          ],
        ),
      ),
    );
  }

  Widget _message() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_controller.errorMessage ?? 'Nenhuma pergunta disponível.'),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _controller.loadQuiz(level: widget.level),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(dynamic question) {
    final isAnswered = _controller.selectedAnswer != null;
    final isCorrect = _controller.selectedAnswerIsCorrect;
    final correctAnswer = question.correctAnswer;
    final isLastQuestion = _controller.currentIndex == _controller.quizzes.length - 1;
    final buttonColor = _controller.selectedAnswer != null
        ? AppTheme.primaryColor
        : Colors.grey.shade300;

    final options = [
      question.optionA,
      question.optionB,
      question.optionC,
      question.optionD,
    ].where((answer) => answer.toString().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Glico', style: TextStyles.logoRed),
                TextSpan(text: 'Educa', style: TextStyles.logoGreen),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text('Quiz', style: TextStyles.pageTitle),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pergunta ${_controller.currentIndex + 1} de ${_controller.quizzes.length}',
              style: TextStyles.description,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getLevelColor(widget.level ?? 'Fácil'),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.level ?? 'Fácil',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _controller.progress,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.primaryColor,
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 28),
        Text(
          question.question,
          style: TextStyles.question,
        ),
        const SizedBox(height: 18),

        ...options.map((answer) => _answerOption(
          answer: answer.toString(),
          isSelected: _controller.selectedAnswer == answer,
          isAnswered: isAnswered,
          isCorrect: isCorrect,
          correctAnswer: correctAnswer,
        )),

        if (isAnswered) ...[
          const SizedBox(height: 16),
          _feedbackCard(isCorrect, question.explanation),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _controller.selectedAnswer == null ? null : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isLastQuestion ? 'Ver resultado' : 'Próxima',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _answerOption({
    required String answer,
    required bool isSelected,
    required bool isAnswered,
    required bool isCorrect,
    required String correctAnswer,
  }) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    IconData icon = Icons.radio_button_off;
    Color iconColor = Colors.grey;

    if (isAnswered) {
      final isCorrectAnswer = answer == correctAnswer;
      final isWrongSelected = isSelected && !isCorrect;

      if (isCorrectAnswer) {

        borderColor = AppTheme.successColor;
        bgColor = const Color(0xFFE8F5E9);
        icon = Icons.check_circle;
        iconColor = AppTheme.successColor;
      } else if (isWrongSelected) {

        borderColor = Colors.red;
        bgColor = const Color(0xFFFFEBEE);
        icon = Icons.cancel;
        iconColor = Colors.red;
      } else if (isSelected) {

        borderColor = AppTheme.successColor;
        bgColor = const Color(0xFFE8F5E9);
        icon = Icons.check_circle;
        iconColor = AppTheme.successColor;
      } else {

        borderColor = Colors.grey.shade300;
        bgColor = Colors.white;
        icon = Icons.radio_button_off;
        iconColor = Colors.grey;
      }
    } else {

      if (isSelected) {
        borderColor = AppTheme.primaryColor;
        bgColor = const Color(0xFFE3F2FD);
        icon = Icons.radio_button_checked;
        iconColor = AppTheme.primaryColor;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!isAnswered) {
          _controller.selectAnswer(answer);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: isAnswered ? 2 : (isSelected ? 2 : 1),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                answer,
                style: TextStyles.bodyMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),

            if (isAnswered && answer == correctAnswer)
              const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 20,
              ),
            if (isAnswered && isSelected && !isCorrect)
              const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _feedbackCard(bool isCorrect, String explanation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect 
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect 
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'Correto!' : 'Incorreto!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCorrect ? AppTheme.successColor : Colors.red,
            ),
          ),
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Fácil':
        return Colors.green;
      case 'Médio':
        return Colors.orange;
      case 'Difícil':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }

  Future<void> _next() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    await _controller.next(userId: userId);

    if (!mounted || !_controller.isFinished) {
      return;
    }
    
    Navigator.pushNamed(
      context,
      AppRoutes.quizResult,
      arguments: {
        'hits': _controller.hits,
        'total': _controller.quizzes.length,
        'level': widget.level,
      },
    );
  }

  Widget _bottom() {
    return AppBottomNavigation(
      currentIndex: 3,
      onItemSelected: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRoutes.homePage);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
            break;
        }
      },
    );
  }
}
