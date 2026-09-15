import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../foods/models/food_model.dart';
import '../../foods/repositories/food_repository.dart';
import '../../progress/repositories/user_progress_repository.dart';

class GlycemicLoadPage extends StatefulWidget {
  const GlycemicLoadPage({super.key});

  @override
  State<GlycemicLoadPage> createState() => _GlycemicLoadPageState();
}

class _GlycemicLoadPageState extends State<GlycemicLoadPage> {
  bool _isClassificacaoExpanded = true;
  bool _isImpactoExpanded = false;
  bool _hasSavedProgress = false;
  final FoodRepository _foodRepository = FoodRepository();

  List<FoodModel> _lowLoadFoods = [];
  List<FoodModel> _moderateLoadFoods = [];
  List<FoodModel> _highLoadFoods = [];

  @override
  void initState() {
    super.initState();
    _loadFoodsByClassification();
  }

  Future<void> _loadFoodsByClassification() async {
    final lowFoods = await _foodRepository.getFoodsByGlycemicLoadClassification('Baixa');
    final moderateFoods = await _foodRepository.getFoodsByGlycemicLoadClassification('Moderada');
    final highFoods = await _foodRepository.getFoodsByGlycemicLoadClassification('Alta');

    if (!mounted) return;

    setState(() {
      _lowLoadFoods = lowFoods;
      _moderateLoadFoods = moderateFoods;
      _highLoadFoods = highFoods;
    });
  }

  Future<void> _saveProgressIfNeeded() async {
    if (_hasSavedProgress) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return;

    _hasSavedProgress = true;

    await ProgressRepository().saveProgress(
      userId: userId,
      theoryTitle: 'Carga glicêmica',
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
                      const Text('Carga glicêmica', style: TextStyles.pageTitle),
                      const SizedBox(height: 6),
                      const Text(
                        'Entenda a carga glicêmica',
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
                  'A Carga Glicêmica (CG) leva em conta ',
            ),
            TextSpan(
              text: 'dois fatores',
              style: TextStyles.cardBodyText.copyWith(
                color: const Color(0xFF1E90FF),
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(
              text:
                  ': a velocidade com que o alimento eleva a glicose e a quantidade de carboidratos que está na porção consumida. Por isso, ela mostra o impacto real de um alimento na glicemia.',
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
          title: 'Baixa CG (< 10)',
          subtitle: 'Menor impacto na glicemia.',
          color: const Color(0xFF66BB6A),
          foods: _lowLoadFoods,
        ),
        const SizedBox(height: 12),
        _buildClassificationRow(
          title: 'Média CG (11 a 19)',
          subtitle: 'Impacto moderado na glicemia.',
          color: const Color(0xFFFF9800),
          foods: _moderateLoadFoods,
        ),
        const SizedBox(height: 12),
        _buildClassificationRow(
          title: 'Alta CG (≥ 20)',
          subtitle: 'Maior impacto na glicemia.',
          color: const Color(0xFFEF5350),
          foods: _highLoadFoods,
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
            'Quando um alimento tem alta carga glicêmica, ele pode entregar mais glicose ao sangue em uma única refeição. Já alimentos com carga menor costumam causar uma resposta mais estável e equilibrada, principalmente quando a porção é mais moderada.',
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
                      'O segredo está na combinação dos alimentos e na quantidade ingerida. Ao equilibrar carboidratos com fibras, proteínas e gorduras boas, você reduz a carga glicêmica e o impacto da glicose no sangue.',
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
