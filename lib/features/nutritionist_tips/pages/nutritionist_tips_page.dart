// lib/features/nutritionist_tips/pages/nutritionist_tips_page.dart
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../controller/nutritionist_tips_controller.dart';
import '../models/nutritionist_tips_model.dart';
import '../repositories/nutritionist_tips_repository.dart';

class NutritionistTipsPage extends StatefulWidget {
  const NutritionistTipsPage({super.key});

  @override
  State<NutritionistTipsPage> createState() => _NutritionistTipsPageState();
}

class _NutritionistTipsPageState extends State<NutritionistTipsPage> {
  late final NutritionistTipsController _controller;
  bool _isLoading = true;
  String _selectedContextId = 'breakfast'; // Começa com o primeiro expandido

  @override
  void initState() {
    super.initState();
    _controller = NutritionistTipsController(
      repository: NutritionistTipsRepository(),
    );
    _controller.addListener(_refresh);
    _loadData();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _controller.loadTips();
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Glico', style: TextStyles.logoRed),
                  TextSpan(text: 'Educa', style: TextStyles.logoGreen),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Alimentos indicados pela nutricionista para os contextos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
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

    // Lista fixa na ordem ideal dos contextos para manter o padrão exato da imagem
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

    // Agrupa as dicas por contexto
    final Map<String, List<NutritionistTipsModel>> groupedTips = {};
    for (var tip in _controller.tips) {
      final contextId = tip.contextId.isEmpty ? 'outros' : tip.contextId;
      if (!groupedTips.containsKey(contextId)) {
        groupedTips[contextId] = [];
      }
      groupedTips[contextId]!.add(tip);
    }

    // Garante que todos os contextos conhecidos apareçam na UI (mesmo vazios ou preenchidos)
    final contextsToDisplay = <String>[];
    for (var ctx in orderedContexts) {
      if (groupedTips.containsKey(ctx)) {
        contextsToDisplay.add(ctx);
      }
    }
    // Adiciona eventuais extras que não estejam na lista ordenada
    groupedTips.keys.forEach((ctx) {
      if (!contextsToDisplay.contains(ctx)) {
        contextsToDisplay.add(ctx);
      }
    });

    return Column(
      children: contextsToDisplay.map((contextId) {
        final tips = groupedTips[contextId] ?? [];
        return _buildAccordionSection(contextId: contextId, tips: tips);
      }).toList(),
    );
  }

  String _getContextName(String contextId) {
    final contextNames = {
      'breakfast': 'Café da manhã',
      'mid_morning': 'Lanche da manhã',
      'lunch': 'Almoço',
      'afternoon_snack': 'Lanche da tarde',
      'pre_workout': 'Pré atividade física',
      'post_workout': 'Pós atividade física',
      'dinner': 'Jantar',
      'supper': 'Ceia',
    };
    return contextNames[contextId] ?? contextId;
  }

  Widget _buildAccordionSection({
    required String contextId,
    required List<NutritionistTipsModel> tips,
  }) {
    final contextName = _getContextName(contextId);
    final isExpanded = _selectedContextId == contextId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.black54,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
    );
  }

  Widget _tipCard(NutritionistTipsModel tip) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: tip.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      tip.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant,
                        size: 24,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.restaurant,
                    size: 24,
                    color: AppTheme.primaryColor,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.dish,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}