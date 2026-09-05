import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

class GlycemicIndexPage extends StatefulWidget {
  const GlycemicIndexPage({super.key});

  @override
  State<GlycemicIndexPage> createState() => _GlycemicIndexPageState();
}

class _GlycemicIndexPageState extends State<GlycemicIndexPage> {
  bool _isClassificacaoExpanded = true;
  bool _isImpactoExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 20),
                    const Text('Índice glicêmico', style: TextStyles.pageTitle),
                    const SizedBox(height: 4),
                    const Text(
                      'Entenda o índice glicêmico',
                      style: TextStyles.description,
                    ),
                    const SizedBox(height: 16),
                    _buildIntroCard(),
                    const SizedBox(height: 16),
                    _buildClassificacaoSection(),
                    const SizedBox(height: 16),
                    _buildImpactoSection(),
                  ],
                ),
              ),
            ),
            AppBottomNavigation(
              currentIndex: 1,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
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

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lunchColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyles.bodySmall,
          children: [
            TextSpan(
              text: 'O Índice Glicêmico (IG) é uma medida que indica a velocidade com que os ',
            ),
            TextSpan(
              text: 'carboidratos',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' de um alimento elevam a glicose no sangue após o consumo. Alimentos com IG alto tendem a elevar a glicemia mais rapidamente, enquanto alimentos com IG baixo promovem uma elevação mais gradual.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificacaoSection() {
    return _buildExpandableContainer(
      title: 'Classificação',
      isExpanded: _isClassificacaoExpanded,
      onToggle: () => setState(() => _isClassificacaoExpanded = !_isClassificacaoExpanded),
      children: [
        _buildIgCategoryCard(
          title: 'Baixo IG (< 55)',
          subtitle: 'Elevam a glicemia mais lentamente.',
        ),
        const SizedBox(height: 12),
        _buildIgCategoryCard(
          title: 'Médio IG (55 a 69)',
          subtitle: 'Produzem uma elevação moderada da glicemia.',
        ),
        const SizedBox(height: 12),
        _buildIgCategoryCard(
          title: 'Alto IG (≥ 70)',
          subtitle: 'Elevam a glicemia rapidamente.',
        ),
      ],
    );
  }

  Widget _buildImpactoSection() {
    return _buildExpandableContainer(
      title: 'Impacto na saúde',
      isExpanded: _isImpactoExpanded,
      onToggle: () => setState(() => _isImpactoExpanded = !_isImpactoExpanded),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardSelectedColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3), width: 1.5),
          ),
          child: const Text(
            'O consumo frequente de alimentos com alto IG pode favorecer picos rápidos de glicose no sangue. Já alimentos com baixo IG geralmente promovem maior saciedade e uma resposta glicêmica mais gradual.',
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildIgCategoryCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.morningSnackColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.morningSnackColor, width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall,
          ),
          const SizedBox(height: 10),
          const Text('Alimentos', style: TextStyles.foodName),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFoodSquarePlaceholder(),
              const SizedBox(width: 12),
              _buildFoodSquarePlaceholder(),
              const SizedBox(width: 12),
              _buildFoodSquarePlaceholder(),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Ver mais alimentos',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSquarePlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.contextDefaultColor,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildExpandableContainer({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyles.sectionTitle),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}