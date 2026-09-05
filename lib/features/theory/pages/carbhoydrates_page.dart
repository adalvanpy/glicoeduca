import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

class TheoryPage extends StatefulWidget {
  const TheoryPage({super.key});

  @override
  State<TheoryPage> createState() => _TheoryPageState();
}

class _TheoryPageState extends State<TheoryPage> {
  bool _isClassificacaoExpanded = true;
  bool _isTiposExpanded = true;
  bool _isCaloriasExpanded = true;
  bool _isConsumoExpanded = true;
  bool _isDigestaoExpanded = true;
  bool _isGlicoseExpanded = true;

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
                    const Text('Carboidratos', style: TextStyles.pageTitle),
                    const SizedBox(height: 4),
                    const Text(
                      'Entenda os carboidratos',
                      style: TextStyles.description,
                    ),
                    const SizedBox(height: 16),
                    _buildIntroCard(),
                    const SizedBox(height: 16),
                    _buildClassificacaoSection(),
                    const SizedBox(height: 16),
                    _buildTiposSection(),
                    const SizedBox(height: 16),
                    _buildCaloriasSection(),
                    const SizedBox(height: 16),
                    _buildConsumoSection(),
                    const SizedBox(height: 16),
                    _buildDigestaoSection(),
                    const SizedBox(height: 16),
                    _buildGlicoseSection(),
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
      child: const Text(
        'Os carboidratos são nutrientes que fornecem energia para o organismo. Estão presentes em alimentos como arroz, pão, massas, frutas, feijão e batata.',
        style: TextStyles.bodySmall,
      ),
    );
  }

  Widget _buildClassificacaoSection() {
    return _buildExpandableContainer(
      title: 'Classificação',
      isExpanded: _isClassificacaoExpanded,
      onToggle: () => setState(() => _isClassificacaoExpanded = !_isClassificacaoExpanded),
      children: [
        const Text(
          'Os carboidratos podem ser classificados em:',
          style: TextStyles.bodySmall,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Simples',
          subtitle: 'Possuem estruturas menores, como glicose, frutose e sacarose.',
          borderColor: AppTheme.morningSnackColor,
          bgColor: AppTheme.morningSnackColor.withOpacity(0.4),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          title: 'Complexos',
          subtitle: 'Possuem estruturas maiores, como amido e fibras.',
          borderColor: AppTheme.cardSelectedColor,
          bgColor: AppTheme.cardSelectedColor,
        ),
      ],
    );
  }

  Widget _buildTiposSection() {
    return _buildExpandableContainer(
      title: 'Tipos',
      isExpanded: _isTiposExpanded,
      onToggle: () => setState(() => _isTiposExpanded = !_isTiposExpanded),
      children: [
        const Text(
          'Na alimentação, os principais tipos são açúcar, amido e fibras:',
          style: TextStyles.bodySmall,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Açúcar',
          subtitle: 'Estão presentes, por exemplo, em frutas, leite e doces.',
          borderColor: AppTheme.morningSnackColor,
          bgColor: AppTheme.morningSnackColor.withOpacity(0.4),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          title: 'Amido',
          subtitle: 'São encontrados em alimentos como arroz, aveia, batata e feijão.',
          borderColor: AppTheme.morningSnackColor,
          bgColor: AppTheme.morningSnackColor.withOpacity(0.4),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          title: 'Fibras',
          subtitle: 'Estão presentes principalmente em frutas, verduras, legumes, cereais integrais e leguminosas.',
          borderColor: AppTheme.cardSelectedColor,
          bgColor: AppTheme.cardSelectedColor,
        ),
      ],
    );
  }

  Widget _buildCaloriasSection() {
    return _buildExpandableContainer(
      title: 'Carboidratos e calorias',
      isExpanded: _isCaloriasExpanded,
      onToggle: () => setState(() => _isCaloriasExpanded = !_isCaloriasExpanded),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.lunchColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.cardBorderColor),
          ),
          child: const Text(
            'Cada 1g de carboidratos fornece aproximadamente 4kcal de energia.',
            textAlign: TextAlign.center,
            style: TextStyles.sectionTitle,
          ),
        ),
      ],
    );
  }

  Widget _buildConsumoSection() {
    return _buildExpandableContainer(
      title: 'Consumo consciente',
      isExpanded: _isConsumoExpanded,
      onToggle: () => setState(() => _isConsumoExpanded = !_isConsumoExpanded),
      children: [
        _buildInfoCard(
          title: '',
          subtitle:
              'O consumo consciente de carboidratos envolve observar não apenas a quantidade consumida, mas também a qualidade dos alimentos escolhidos. Priorizar frutas, verduras, legumes, feijão e cereais integrais pode contribuir para uma alimentação mais equilibrada. Já o consumo frequente de alimentos ricos em açúcares e ultraprocessados pode favorecer alterações na glicemia e aumentar o risco de problemas de saúde. Fazer escolhas conscientes ajuda a manter uma alimentação mais saudável e equilibrada.',
          borderColor: AppTheme.cardSelectedColor,
          bgColor: AppTheme.cardSelectedColor,
        ),
      ],
    );
  }

  Widget _buildDigestaoSection() {
    return _buildExpandableContainer(
      title: 'Digestão dos carboidratos',
      isExpanded: _isDigestaoExpanded,
      onToggle: () => setState(() => _isDigestaoExpanded = !_isDigestaoExpanded),
      children: [
        _buildInfoCard(
          title: '',
          subtitle:
              'A digestão dos carboidratos começa na boca e continua no sistema digestório. Durante esse processo, eles são transformados em moléculas menores, como a glicose, que pode ser observada pelo organismo.',
          borderColor: AppTheme.cardSelectedColor,
          bgColor: AppTheme.cardSelectedColor,
        ),
      ],
    );
  }

  Widget _buildGlicoseSection() {
    return _buildExpandableContainer(
      title: 'Da glicose à glicemia',
      isExpanded: _isGlicoseExpanded,
      onToggle: () => setState(() => _isGlicoseExpanded = !_isGlicoseExpanded),
      children: [
        _buildInfoCard(
          title: '',
          subtitle:
              'Após ser absorvida no intestino, a glicose entre na corrente sanguínea. A quantidade e a velocidade com que ela chega ao sangue influenciam a glicemia. Por isso, alguns alimentos podem provocar respostas glicêmicas diferentes.',
          borderColor: AppTheme.cardSelectedColor,
          bgColor: AppTheme.cardSelectedColor,
        ),
      ],
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

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: TextStyles.sectionTitle),
            const SizedBox(height: 4),
          ],
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
