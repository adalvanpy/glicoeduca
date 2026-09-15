import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../progress/repositories/user_progress_repository.dart';

class InstructionsQuizPage extends StatefulWidget {
  const InstructionsQuizPage({super.key});

  @override
  State<InstructionsQuizPage> createState() => _InstructionsQuizPageState();
}

class _InstructionsQuizPageState extends State<InstructionsQuizPage> {
  String _selectedLevel = 'Fácil'; // Padrão
  bool _canAccessQuiz = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _canAccessQuiz = false;
      });
      return;
    }

    final progressList = await ProgressRepository().getUserProgress(userId);
    final progressMap = {
      for (final item in progressList) item.theoryTitle: item.progress,
    };

    const requiredTitles = [
      'Carboidratos',
      'Índice glicêmico',
      'Carga glicêmica',
      'Alimentos',
      'Dicas de nutricionista',
    ];

    final canAccess = requiredTitles.every(
      (title) => (progressMap[title] ?? 0.0) >= 1.0,
    );

    if (!mounted) return;

    setState(() {
      _canAccessQuiz = canAccess;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildInstructions(),
                    const SizedBox(height: 24),
                    _buildLevelSelector(),
                    const SizedBox(height: 32),
                    if (!_canAccessQuiz) _buildAccessBlockedMessage(),
                    _buildStartButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            AppBottomNavigation(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Align(
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
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Quiz glicoeduca',
      style: TextStyles.pageTitle,
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppTheme.infoCardBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.infoCardBorder.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyles.cardBodyText,
          children: [
            TextSpan(
              text: 'Instruções:\n',
              style: TextStyles.highlight,
            ),
            TextSpan(
              text: 'Responda 10 perguntas sobre carboidratos e glicemia de acordo com o nível selecionado. Cada pergunta possui apenas uma alternativa correta. Ao final, você poderá ver sua pontuação e classificação.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o nível',
          style: TextStyles.cardTitle,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _levelChip('Fácil', const Color(0xFFDBF5E0), const Color(0xFF2E9A57), const Color(0xFF2E9A57))),
            const SizedBox(width: 12),
            Expanded(child: _levelChip('Médio', const Color(0xFFF6E8C9), const Color(0xFFE0A856), const Color(0xFFE0A856))),
            const SizedBox(width: 12),
            Expanded(child: _levelChip('Difícil', const Color(0xFFEFD9D9), const Color(0xFFCF4E4E), const Color(0xFFCF4E4E))),
          ],
        ),
      ],
    );
  }

  Widget _levelChip(String label, Color backgroundColor, Color borderColor, Color textColor) {
    final bool isSelected = _selectedLevel == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = label;
        });
      },
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? borderColor.withValues(alpha: 0.8) : Colors.grey.shade300,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyles.cardTitle.copyWith(
            color: isSelected ? textColor : textColor.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAccessBlockedMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E90FF), width: 1),
      ),
      child: const Text(
        'Você precisa acessar todos os cards do guia para liberar o quiz.',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final isEnabled = _canAccessQuiz;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isEnabled
            ? null
            : () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.quiz,
                  arguments: {'level': _selectedLevel},
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F8DEB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Iniciar quiz',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
