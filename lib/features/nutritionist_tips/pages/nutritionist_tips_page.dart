import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../progress/repositories/user_progress_repository.dart';
import '../controller/nutritionist_tips_controller.dart';
import '../models/nutritionist_tips_model.dart';
import '../repositories/nutritionist_tips_repository.dart';
import '../services/nutritionist_tips_access_service.dart';

class NutritionistTipsPage extends StatefulWidget {
  const NutritionistTipsPage({super.key});

  @override
  State<NutritionistTipsPage> createState() => _NutritionistTipsPageState();
}

class _NutritionistTipsPageState extends State<NutritionistTipsPage> {
  late final NutritionistTipsController _controller;
  bool _isLoading = true;
  bool _hasSavedProgress = false;
  String _selectedContextId = 'breakfast'; // Começa com o primeiro expandido

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildContent(),
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
                  case 1:
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.optionTheory,
                    );
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

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = NutritionistTipsController(
      repository: NutritionistTipsRepository(),
    );
    _controller.addListener(_refresh);
    _loadData();
    _saveProgressIfNeeded();
  }

  Widget _buildAccordionSection({
    required String contextId,
    required List<NutritionistTipsModel> tips,
  }) {
    final contextName = _getContextName(contextId);
    final isExpanded = _selectedContextId == contextId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.complexCardBorder, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: Key('${contextId}_$isExpanded'),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _selectedContextId = expanded ? contextId : '';
            });
          },
          title: Text(
            contextName,
            style: TextStyles.cardBodyText.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.black54,
            size: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            if (tips.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Nenhuma dica para este contexto.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              )
            else
              ...tips.map((tip) => _tipCard(tip)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_controller.tips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Nenhuma dica disponível.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final List<String> orderedContexts = [
      'breakfast',
      'mid_morning',
      'lunch',
      'pre_workout',
      'post_workout',
      'afternoon_snack',
      'dinner',
      'supper',
    ];

    final Map<String, List<NutritionistTipsModel>> groupedTips = {};
    for (var tip in _controller.tips) {
      final contextId = tip.contextId.isEmpty ? 'outros' : tip.contextId;
      if (!groupedTips.containsKey(contextId)) {
        groupedTips[contextId] = [];
      }
      groupedTips[contextId]!.add(tip);
    }

    final contextsToDisplay = <String>[];
    for (var ctx in orderedContexts) {
      if (groupedTips.containsKey(ctx)) {
        contextsToDisplay.add(ctx);
      }
    }

    for (final ctx in groupedTips.keys) {
      if (!contextsToDisplay.contains(ctx)) {
        contextsToDisplay.add(ctx);
      }
    }

    return Column(
      children: contextsToDisplay.map((contextId) {
        final tips = groupedTips[contextId] ?? [];
        return _buildAccordionSection(contextId: contextId, tips: tips);
      }).toList(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Alimentos indicados pela nutricionista para os contextos',
            style: TextStyles.pageTitle,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  String _getContextName(String contextId) {
    final contextNames = {
      'breakfast': 'Café da manhã',
      'mid_morning': 'Lanche da manhã',
      'morning_snack': 'Lanche da manhã',
      'lunch': 'Almoço',
      'afternoon_snack': 'Lanche da tarde',
      'evening_snack': 'Ceia',
      'pre_workout': 'Pré atividade física',
      'post_workout': 'Pós atividade física',
      'dinner': 'Jantar',
      'supper': 'Ceia',
    };
    return contextNames[contextId] ?? contextId;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadTips();
    await _updateAccessState();
    setState(() => _isLoading = false);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _saveProgressIfNeeded() async {
    if (_hasSavedProgress) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) return;

    _hasSavedProgress = true;

    await ProgressRepository().saveProgress(
      userId: userId,
      theoryTitle: 'Dicas de nutricionista',
      progress: 1.0,
    );
  }

  Widget _tipCard(NutritionistTipsModel tip) {
    return InkWell(
      onTap: () async {
        await NutritionistTipsAccessService.markTipAsViewed(tip.id);
        await _updateAccessState();

        if (!mounted) return;

        await Navigator.pushNamed(
          context,
          AppRoutes.nutritionistTipsDetails,
          arguments: tip,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.complexCardBackground.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFEAF7EC),
              ),
              child: tip.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        tip.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.restaurant,
                          size: 22,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      size: 22,
                      color: AppTheme.primaryColor,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tip.dish,
                style: TextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAccessState() async {
    final tipIds = _controller.tips.map((tip) => tip.id).toList();
    await NutritionistTipsAccessService.canAccessGames(
      allTipIds: tipIds,
    );
  }
}
