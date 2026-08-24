import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

class QuizResultPage extends StatelessWidget {
  final int hits;
  final int total;
  final String level;

  const QuizResultPage({
    super.key,
    this.hits = 0,
    this.total = 0,
    this.level = 'Fácil',
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 USA OS PARÂMETROS DIRETAMENTE
    final percentage = total == 0 ? 0 : ((hits / total) * 100).round();

    print('📊 QuizResultPage - Hits: $hits, Total: $total, Level: $level');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Text('Glico', style: TextStyles.logoRed),
                        Text('Educa', style: TextStyles.logoGreen),
                      ],
                    ),
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.emoji_events_outlined,
                      size: 72,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Parabéns!',
                        style: TextStyles.pageTitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Você acertou $hits de $total questões.',
                        style: TextStyles.description,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLevelColor(level),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Nível: $level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _stat('Acertos', '$hits', AppTheme.successColor),
                    _stat('Aproveitamento', '$percentage%', AppTheme.primaryColor),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.instructionsQuiz,
                      ),
                      child: const Text('Voltar ao quiz'),
                    ),
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

  Widget _stat(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyles.bodyMedium),
          Text(
            value,
            style: TextStyles.sectionTitle.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
