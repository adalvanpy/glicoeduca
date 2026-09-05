import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

class OptionTheoryPage extends StatefulWidget {
  const OptionTheoryPage({super.key});

  @override
  State<OptionTheoryPage> createState() => _OptionTheoryPageState();
}

class _OptionTheoryPageState extends State<OptionTheoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 30),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildSubtitle(),
                    const SizedBox(height: 32),
                    _buildOptionCard(
                      context,
                      icon: Icons.science,
                      title: 'Carboidratos',
                      description: 'Entenda o que são carboidratos e sua importância para o organismo',
                      route: AppRoutes.theoryContent,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.speed,
                      title: 'Índice Glicêmico',
                      description: 'Saiba como os alimentos afetam os níveis de glicose no sangue',
                      route: AppRoutes.glycemicIndex,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.timeline,
                      title: 'Carga Glicêmica',
                      description: 'Descubra a relação entre quantidade e qualidade dos carboidratos',
                      route: AppRoutes.glycemicLoad,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.restaurant_menu,
                      title: 'Alimentos e Composições',
                      description: 'Conheça os alimentos, suas composições nutricionais e classificações',
                      route: AppRoutes.food,
                      color: const Color(0xFF9C27B0),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.health_and_safety,
                      title: 'Dicas do Nutricionista',
                      description: 'Receba orientações práticas para uma alimentação saudável e equilibrada',
                      route: AppRoutes.nutritionistTips,
                      color: const Color(0xFFE91E63),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            AppBottomNavigation(
              currentIndex: 1,
              onItemSelected: (index) {
                if (index == 2) {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                } else if (index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsQuiz);
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
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: 'Glico', style: TextStyles.logoRed),
          TextSpan(text: 'Educa', style: TextStyles.logoGreen),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Antes de praticar, que tal aprender um pouco sobre carboidratos e glicemia?',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
        height: 1.2,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Escolha um dos temas abaixo para começar seus estudos:',
      style: TextStyles.description,
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    String? theoryId,
    String? route,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else if (theoryId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.theory,
            arguments: theoryId,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}