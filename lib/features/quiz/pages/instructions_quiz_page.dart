import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

class InstructionsQuizPage extends StatefulWidget {
  const InstructionsQuizPage({super.key});

  @override
  State<InstructionsQuizPage> createState() => _InstructionsQuizPageState();
}

class _InstructionsQuizPageState extends State<InstructionsQuizPage> {
  String _selectedLevel = 'Fácil'; // Padrão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    _buildStartButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            AppBottomNavigation(
              currentIndex: 3,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                } else if (index == 4) {
                  Navigator.pushReplacementNamed(context, AppRoutes.profile);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: 'Glico', style: TextStyles.logoRed),
          TextSpan(text: 'Educa', style: TextStyles.logoGreen),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Quiz GlicoEduca',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instruções:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Responda 10 perguntas sobre carboidratos e glicemia de acordo com o nível selecionado. Cada pergunta possui apenas uma alternativa correta. Ao final, você poderá ver sua pontuação e classificação.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o nível:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _levelChip('Fácil', Icons.sentiment_satisfied, Colors.green),
            const SizedBox(width: 10),
            _levelChip('Médio', Icons.sentiment_neutral, Colors.orange),
            const SizedBox(width: 10),
            _levelChip('Difícil', Icons.sentiment_dissatisfied, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _levelChip(String label, IconData icon, Color color) {
    final bool isSelected = _selectedLevel == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navega para o QuizPage com o nível selecionado
          Navigator.pushNamed(
            context,
            AppRoutes.quiz,
            arguments: {'level': _selectedLevel},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Iniciar quiz',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}