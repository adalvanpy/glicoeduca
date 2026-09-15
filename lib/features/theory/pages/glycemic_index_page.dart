import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../foods/models/food_model.dart';
import '../../foods/repositories/food_repository.dart';
import '../../progress/repositories/user_progress_repository.dart';

class GlycemicIndexPage extends StatefulWidget {
  const GlycemicIndexPage({super.key});

  @override
  State<GlycemicIndexPage> createState() => _GlycemicIndexPageState();
}

class _GlycemicIndexPageState extends State<GlycemicIndexPage> {
  bool _isClassificacaoExpanded = true;
  bool _isImpactoExpanded = false;
  bool _hasSavedProgress = false;
  final FoodRepository _foodRepository = FoodRepository();

  List<FoodModel> _lowIgFoods = [];
  List<FoodModel> _moderateIgFoods = [];
  List<FoodModel> _highIgFoods = [];

  @override
  void initState() {
    super.initState();
    _loadFoodsByClassification();
  }

  Future<void> _loadFoodsByClassification() async {
    final lowFoods = await _foodRepository.getFoodsByGlycemicIndexClassification('Baixo');
    final moderateFoods = await _foodRepository.getFoodsByGlycemicIndexClassification('Moderado');
    final highFoods = await _foodRepository.getFoodsByGlycemicIndexClassification('Alto');

    if (!mounted) return;

    setState(() {
      _lowIgFoods = lowFoods;
      _moderateIgFoods = moderateFoods;
      _highIgFoods = highFoods;
    });
  }

  Future<void> _saveProgressIfNeeded() async {
    if (_hasSavedProgress) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return;

    _hasSavedProgress = true;

    await ProgressRepository().saveProgress(
      userId: userId,
      theoryTitle: 'Índice glicêmico',
      progress: 1.0,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                      const Text('Índice glicêmico', style: TextStyles.pageTitle),
                      const SizedBox(height: 6),
                      const Text(
                        'Entenda o índice glicêmico',
                        style: TextStyles.description,
                      ),
                      const SizedBox(height: 20),
                      _buildIntroCard(),
                      const SizedBox(height: 16),
                      _buildClassificacaoSection(),
                      const SizedBox(height: 16),
                      _buildImpactoSection(),
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
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.instructionsDuel,
                    );
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.instructionsQuiz,
                    );
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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
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
          color: AppTheme.infoCardBorder,
          width: 1.0,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyles.cardBodyText,
          children: [
            const TextSpan(
              text:
                  'O Índice Glicêmico (IG) mostra ',
            ),
            TextSpan(
              text: 'quão rápido',
              style: TextStyles.cardBodyText.copyWith(
                color: const Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text:
                  ' um alimento faz a glicose subir no sangue. Alimentos com IG alto elevam a glicemia mais rapidamente. Já os com IG baixo fazem a subida acontecer de forma mais gradual.',
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
      onToggle: () => setState(
          () => _isClassificacaoExpanded = !_isClassificacaoExpanded),
      children: [
        _buildClassificationRow(
          title: 'Baixo IG (< 55)',
          subtitle: 'Elevam a glicemia mais lentamente.',
          color: const Color(0xFF66BB6A),
          foods: _lowIgFoods,
        ),
        const SizedBox(height: 12),
        _buildClassificationRow(
          title: 'Médio IG (55 a 69)',
          subtitle: 'Produzem uma elevação moderada da glicemia.',
          color: const Color(0xFFFF9800),
          foods: _moderateIgFoods,
        ),
        const SizedBox(height: 12),
        _buildClassificationRow(
          title: 'Alto IG (≥ 70)',
          subtitle: 'Elevam a glicemia rapidamente.',
          color: const Color(0xFFEF5350),
          foods: _highIgFoods,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.complexCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.complexCardBorder,
              width: 1.0,
            ),
          ),
          child: const Text(
            'Quando a alimentação tem muitos alimentos de IG alto, a glicemia pode subir rápido e depois cair de forma mais intensa. Já alimentos com IG mais baixo costumam dar uma resposta mais estável e podem ajudar a manter a sensação de saciedade por mais tempo.',
            textAlign: TextAlign.start,
            style: TextStyles.cardBodyText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.complexCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.complexCardBorder,
              width: 1.0,
            ),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyles.cardBodyText,
              children: [
                const TextSpan(
                  text: 'Dica da nutricionista: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'O segredo está na combinação dos alimentos e na quantidade ingerida. Quando você junta carboidratos com fibras, proteínas e gorduras boas, a digestão fica mais lenta e o índice glicêmico tende a cair, deixando a resposta da glicose mais estável.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationRow({
    required String title,
    required String subtitle,
    required Color color,
    required List<FoodModel> foods,
  }) {
    final firstFoods = foods.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyles.cardBodyText,
                    ),
                    if (firstFoods.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        firstFoods.map((food) => food.name).join(' • '),
                        style: TextStyles.cardBodyText.copyWith(
                          fontSize: 11,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.food);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ver mais alimentos',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E90FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorderColor, width: 1.0),
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
}
