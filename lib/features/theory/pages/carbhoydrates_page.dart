import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../progress/repositories/user_progress_repository.dart';

class TheoryPage extends StatefulWidget {
  const TheoryPage({super.key});

  @override
  State<TheoryPage> createState() => _TheoryPageState();
}

class _TheoryPageState extends State<TheoryPage> {
  bool _isClassificacaoExpanded = true;
  bool _isTiposExpanded = false;
  bool _isCaloriasExpanded = false;
  bool _isConsumoExpanded = false;
  bool _isDigestaoExpanded = false;
  bool _isGlicoseExpanded = false;
  bool _hasSavedProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _handleScroll(notification);
                  return false;
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 20),
                      const Text('Carboidratos', style: TextStyles.pageTitle),
                      const SizedBox(height: 6),
                      const Text(
                        'Entenda os carboidratos',
                        style: TextStyles.description,
                      ),
                      const SizedBox(height: 20),
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
            ),
            AppBottomNavigation(
              currentIndex: 1,
              onItemSelected: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, AppRoutes.instructionsQuiz);
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

  Widget _buildCaloriasSection() {
    return _buildExpandableContainer(
      title: 'Carboidratos e calorias',
      isExpanded: _isCaloriasExpanded,
      onToggle: () =>
          setState(() => _isCaloriasExpanded = !_isCaloriasExpanded),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.infoCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.infoCardBorder,
              width: 1.0,
            ),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: AppTheme.textColor,
              ),
              children: [
                TextSpan(text: 'Cada 1 grama de carboidrato fornece cerca de '),
                TextSpan(
                  text: '4 calorias',
                  style: TextStyle(color: AppTheme.warningColor),
                ),
                TextSpan(text: ' de energia. Isso mostra que a quantidade ingerida também importa, além da qualidade dos alimentos.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificacaoSection() {
    return _buildExpandableContainer(
      title: 'Classificação',
      isExpanded: _isClassificacaoExpanded,
      onToggle: () => setState(
          () => _isClassificacaoExpanded = !_isClassificacaoExpanded),
      children: [
        const Text(
          'Os carboidratos podem ser divididos em duas grandes categorias:',
          style: TextStyles.cardBodyText,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Simples',
          subtitle:
              'São digeridos mais rapidamente e podem elevar a glicose mais depressa. Eles aparecem em doces, refrigerantes, sobremesas e alimentos ultraprocessados.',
          borderColor: AppTheme.simpleCardBorder,
          bgColor: AppTheme.simpleCardBackground,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Complexos',
          subtitle: 'São digeridos mais lentamente e costumam deixar a glicemia mais estável. Estão em frutas, legumes, grãos integrais e leguminosas.',
          borderColor: AppTheme.complexCardBorder,
          bgColor: AppTheme.complexCardBackground,
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
              'Para uma alimentação equilibrada, vale priorizar fontes de carboidratos de melhor qualidade, como frutas, legumes, verduras, grãos integrais e leguminosas. Também é importante observar a quantidade consumida e reduzir o excesso de alimentos muito doces e ultraprocessados. Essa escolha ajuda a manter a glicemia mais estável e favorece a saúde geral.',
          borderColor: AppTheme.complexCardBorder,
          bgColor: AppTheme.complexCardBackground,
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
              'A digestão dos carboidratos começa na boca e continua ao longo do trato digestório. Nesse processo, eles são quebrados em moléculas menores, como a glicose, que pode ser absorvida pelo corpo e usada como energia.',
          borderColor: AppTheme.complexCardBorder,
          bgColor: AppTheme.complexCardBackground,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.infoCardBorder.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyles.cardTitle,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.secondaryTextColor,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
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
              'Depois de absorvida, a glicose entra na corrente sanguínea e passa a ser usada como energia. A quantidade e a velocidade com que isso acontece influenciam a glicemia. Por isso, alimentos diferentes podem provocar respostas diferentes no organismo.',
          borderColor: AppTheme.complexCardBorder,
          bgColor: AppTheme.complexCardBackground,
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            subtitle,
            textAlign: title.isNotEmpty ? TextAlign.center : TextAlign.start,
            style: TextStyles.cardBodyText,
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.infoCardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.infoCardBorder.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Os carboidratos são a principal fonte de energia do corpo. Eles estão presentes em alimentos como arroz, pão, massas, frutas, feijão, leite, batata e doces. A qualidade e a quantidade desses alimentos fazem diferença para a saúde e para a glicemia.',
            style: TextStyles.cardBodyText,
          ),
          const SizedBox(height: 12),
          Text(
            'Fonte: Organização Mundial da Saúde (OMS) e Sociedade Brasileira de Diabetes (SBD).',
            style: TextStyles.cardBodyText.copyWith(
              fontSize: 15,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return const SizedBox.shrink();
  }

  Widget _buildTiposSection() {
    return _buildExpandableContainer(
      title: 'Tipos',
      isExpanded: _isTiposExpanded,
      onToggle: () => setState(() => _isTiposExpanded = !_isTiposExpanded),
      children: [
        const Text(
          'Os principais tipos de carboidratos são açúcar, amido e fibras. Cada um atua de forma diferente no organismo.',
          style: TextStyles.cardBodyText,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Açúcar',
          subtitle: 'Está presente em frutas, leite e doces. É uma fonte rápida de energia, mas o excesso pode elevar a glicemia mais rapidamente.',
          borderColor: AppTheme.sugarCardBorder.withValues(alpha: 1.0),
          bgColor: AppTheme.sugarCardBackground,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Amido',
          subtitle: 'Está em arroz, pão, massa, batata, milho, aveia e feijão. É uma fonte de energia mais duradoura quando consumida com moderação e qualidade.',
          borderColor: AppTheme.starchCardBorder,
          bgColor: AppTheme.starchCardBackground,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Fibras',
          subtitle: 'Estão em frutas, verduras, legumes, cereais integrais e leguminosas. A fibra ajuda na digestão, melhora a saciedade e pode ajudar a reduzir grandes picos de glicose.',
          borderColor: AppTheme.complexCardBorder,
          bgColor: AppTheme.complexCardBackground,
        ),
      ],
    );
  }

  void _handleScroll(ScrollNotification notification) {
    if (!mounted) return;

    final metrics = notification.metrics;
    final progress = metrics.maxScrollExtent <= 0
        ? 1.0
        : (metrics.pixels / metrics.maxScrollExtent).clamp(0.0, 1.0);

    if (progress >= 0.9) {
      _saveProgressIfNeeded();
    }
  }

  Future<void> _saveProgressIfNeeded() async {
    if (_hasSavedProgress) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return;

    _hasSavedProgress = true;

    await ProgressRepository().saveProgress(
      userId: userId,
      theoryTitle: 'Carboidratos',
      progress: 1.0,
    );
  }
}

