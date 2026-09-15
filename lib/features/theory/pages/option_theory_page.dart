import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../progress/repositories/user_progress_repository.dart';

class OptionTheoryPage extends StatefulWidget {
  const OptionTheoryPage({super.key});

  @override
  State<OptionTheoryPage> createState() => _OptionTheoryPageState();
}

class _OptionTheoryPageState extends State<OptionTheoryPage> {
  bool _isLoadingProgress = true;
  int _seenTipsCount = 0;
  int _totalTipsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _totalTipsCount = 0;
        _seenTipsCount = 0;
        _isLoadingProgress = false;
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

    if (!mounted) return;

    setState(() {
      _totalTipsCount = requiredTitles.length;
      _seenTipsCount = requiredTitles
          .where((title) => (progressMap[title] ?? 0.0) >= 1.0)
          .length;
      _isLoadingProgress = false;
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildSubtitle(),
                    const SizedBox(height: 18),
                    _buildProgressCard(),
                    const SizedBox(height: 24),
                    _buildOptionCard(
                      context,
                      icon: Icons.science,
                      title: 'Carboidratos',
                      description:
                          'Entenda o que são carboidratos e a sua importância para o organismo',
                      route: AppRoutes.theoryContent,
                      color: const Color(0xFF66BB6A),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.speed,
                      title: 'Índice glicêmico',
                      description:
                          'Saiba como os alimentos afetam os índices de glicose no sangue.',
                      route: AppRoutes.glycemicIndex,
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.timeline,
                      title: 'Carga glicêmica',
                      description:
                          'descubra a relação entre qunatidade e qualidade dos carboidratos',
                      route: AppRoutes.glycemicLoad,
                      color: const Color(0xFF1E90FF),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.restaurant_menu,
                      title: 'Alimentos e composições',
                      description:
                          'Conheca os alimentos, suas composições nutricionais e classificação',
                      route: AppRoutes.food,
                      color: const Color(0xFF8E44AD),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      context,
                      icon: Icons.health_and_safety,
                      title: 'Dicas de nutricionista',
                      description:
                          'Recba orientações práticas para uma alimentação saudável e equilibrada',
                      route: AppRoutes.nutritionistTips,
                      color: const Color(0xFFEF5350),
                    ),
                    const SizedBox(height: 24),
                  ],
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
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyles.logoRed.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          children: const [
            TextSpan(text: 'Glico', style: TextStyles.logoRed),
            TextSpan(text: 'Educa', style: TextStyles.logoGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Antes de praticar, que tal aprender um pouco sobre carboidratos e glicemia?',
      style: TextStyles.pageTitle,
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Escolha um dos temas abaixo para começar seus estudos:',
      style: TextStyles.description,
    );
  }

  Widget _buildProgressCard() {
    final progressValue = _totalTipsCount == 0
        ? 0.0
        : (_seenTipsCount / _totalTipsCount).clamp(0.0, 1.0);

    final isCompleted = _seenTipsCount >= _totalTipsCount && _totalTipsCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF2E9A57)
              : const Color(0xFF1E90FF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso de liberação',
                style: TextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                _isLoadingProgress
                    ? '...'
                    : '$_seenTipsCount/$_totalTipsCount',
                style: TextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _isLoadingProgress ? null : progressValue,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8EEF6),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? const Color(0xFF2E9A57) : const Color(0xFF1E90FF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoadingProgress
                ? 'Carregando progresso...'
                : (isCompleted
                    ? 'Todos os cards foram acessados. Quiz e duelo liberados.'
                    : 'Acesse todos os cards do guia para liberar o quiz e o duelo.'),
            style: TextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: const Color(0xFF374151),
              height: 1.4,
            ),
          ),
        ],
      ),
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
      onTap: () async {
        if (route != null) {
          await Navigator.pushNamed(context, route);
        } else if (theoryId != null) {
          await Navigator.pushNamed(
            context,
            AppRoutes.theory,
            arguments: theoryId,
          );
        }

        if (mounted) {
          await _loadProgress();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration(
          borderColor: color.withValues(alpha: 0.55),
          radius: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                description,
                style: TextStyles.cardBodyText,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              size: 28,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}

