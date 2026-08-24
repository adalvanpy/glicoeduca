import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../controllers/theory_controller.dart';
import '../models/theory_model.dart';
import '../../foods/models/food_model.dart';
import '../repositories/theory_repository.dart';
import '../../progress/repositories/user_progress_repository.dart';

class TheoryPage extends StatefulWidget {
  final TheoryController? controller;
  final String? theoryId;

  const TheoryPage({
    super.key,
    this.controller,
    this.theoryId,
  });

  @override
  State<TheoryPage> createState() => _TheoryPageState();
}

class _TheoryPageState extends State<TheoryPage> {
  late final TheoryController _controller;
  late final bool _ownsController;
  String? _theoryId;
  
  // 🔥 CONTROLA SE JÁ FOI MARCADO COMO LIDO
  bool _hasMarkedAsRead = false;

  final Map<int, bool> _sectionExpandedState = {};
  final Map<String, bool> _foodExpandedState = {};

  final ProgressRepository _progressRepo = ProgressRepository();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TheoryController(repository: TheoryRepository());
    _controller.addListener(_refresh);
    _theoryId = widget.theoryId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_theoryId == null || _theoryId!.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _theoryId = args;
      }
    }
    
    if (_theoryId != null && _theoryId!.isNotEmpty) {
      _controller.loadTheoryById(_theoryId);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // 🔥 MÉTODO PARA MARCAR COMO LIDO AUTOMATICAMENTE
  Future<void> _markAsReadIfNeeded() async {
    // Se já marcou ou não tem dados, sai
    if (_hasMarkedAsRead || _theoryId == null) return;
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final theory = _controller.selectedTheory;
    
    if (userId == null || theory == null) return;

    // 🔥 VERIFICA SE ALGUM TÓPICO ESTÁ EXPANDIDO
    bool hasExpandedSection = _sectionExpandedState.values.any((expanded) => expanded);
    
    // 🔥 VERIFICA SE ALGUM ALIMENTO ESTÁ EXPANDIDO
    bool hasExpandedFood = _foodExpandedState.values.any((expanded) => expanded);
    
    // Se pelo menos um tópico ou alimento está expandido, marca como lido
    if (hasExpandedSection || hasExpandedFood) {
      _hasMarkedAsRead = true;
      
      try {
        await _progressRepo.saveProgress(
          userId: userId,
          theoryId: _theoryId!,
          theoryTitle: theory.title,
          progress: 1.0,
        );
        
        debugPrint('✅ Leitura marcada automaticamente para: ${theory.title}');
      } catch (e) {
        debugPrint('❌ Erro ao marcar leitura: $e');
      }
    }
  }

  // 🔥 CHAMADO QUANDO UM TÓPICO É EXPANDIDO
  void _onSectionExpanded(int index, bool expanded) {
    setState(() {
      _sectionExpandedState[index] = expanded;
    });
    
    // Se expandiu, tenta marcar como lido
    if (expanded) {
      _markAsReadIfNeeded();
    }
  }

  // 🔥 CHAMADO QUANDO UM ALIMENTO É EXPANDIDO
  void _onFoodExpanded(String foodId, bool expanded) {
    setState(() {
      _foodExpandedState[foodId] = expanded;
    });
    
    // Se expandiu, tenta marcar como lido
    if (expanded) {
      _markAsReadIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theory = _controller.selectedTheory;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(theory)),
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

  Widget _buildBody(TheoryModel? theory) {
    if (_controller.isLoading && theory == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (theory == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.errorMessage ?? 'Nenhum conteúdo disponível.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_theoryId != null && _theoryId!.isNotEmpty) {
                    _controller.loadTheoryById(_theoryId);
                  }
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(17, 24, 17, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 24),
          Text(theory.title, style: TextStyles.pageTitle),
          if (theory.description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(theory.description, style: TextStyles.description),
          ],
          const SizedBox(height: 16),
          _buildConceptSection(theory),
          const SizedBox(height: 16),
          _buildAccordionSections(theory),
          const SizedBox(height: 24),
          _buildFoodsSection(theory.foods),
          const SizedBox(height: 16),
          // 🔥 INDICADOR DE LEITURA (opcional)
          if (_hasMarkedAsRead) _buildReadBadge(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: 'Glico', style: TextStyles.logoRed),
          TextSpan(text: 'Educa', style: TextStyles.logoGreen),
        ],
      ),
    );
  }

  Widget _buildConceptSection(TheoryModel theory) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(theory.image),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            theory.conceito,
            style: TextStyles.bodySmall.copyWith(height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return Container(
      width: 90,
      height: 90,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: url.isEmpty
          ? const Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildAccordionSections(TheoryModel theory) {
    final sections = [
      if (theory.title2.isNotEmpty || theory.contentTitle2.isNotEmpty)
        {'title': theory.title2, 'content': theory.contentTitle2},
      if (theory.title3.isNotEmpty || theory.contentTitle3.isNotEmpty)
        {'title': theory.title3, 'content': theory.contentTitle3},
      if (theory.title4.isNotEmpty || theory.contentTitle4.isNotEmpty)
        {'title': theory.title4, 'content': theory.contentTitle4},
      if (theory.title5.isNotEmpty || theory.contentTitle5.isNotEmpty)
        {'title': theory.title5, 'content': theory.contentTitle5},
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      children: sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;

        if (!_sectionExpandedState.containsKey(index)) {
          _sectionExpandedState[index] = index == 0;
        }

        return Column(
          children: [
            _buildCustomExpansionTile(
              title: section['title'] ?? '',
              content: section['content'] ?? '',
              isExpanded: _sectionExpandedState[index] ?? false,
              onExpansionChanged: (val) => _onSectionExpanded(index, val),
            ),
            if (index < sections.length - 1) const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCustomExpansionTile({
    required String title,
    required String content,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyles.sectionTitle.copyWith(fontSize: 15),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.black54,
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyles.bodySmall.copyWith(height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodsSection(List<FoodModel> foods) {
    if (foods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alimentos ricos em carboidratos',
          style: TextStyles.sectionTitle,
        ),
        const SizedBox(height: 12),
        ...foods.map((food) {
          if (!_foodExpandedState.containsKey(food.id)) {
            _foodExpandedState[food.id] = false;
          }

          return Column(
            children: [
              _foodCard(food),
              if (foods.indexOf(food) < foods.length - 1) const SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  Widget _foodCard(FoodModel food) {
    final bool isExpanded = _foodExpandedState[food.id] ?? false;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _onFoodExpanded(food.id, !isExpanded),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: food.image.isNotEmpty
                        ? Image.network(
                            food.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.food_bank,
                              size: 20,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.food_bank,
                            size: 20,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: TextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (food.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          food.description,
                          style: TextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black45,
                  size: 20,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _badgeItem(
                  'Carb',
                  '${food.carbohydrates.toStringAsFixed(0)}g',
                  Colors.red,
                ),
                _badgeItem(
                  'Fibras',
                  '${food.fiber.toStringAsFixed(0)}g',
                  Colors.green,
                ),
                _badgeItem(
                  'IG',
                  food.glycemicIndex.toStringAsFixed(0),
                  _getGlycemicIndexColor(food.glycemicIndex),
                ),
                _badgeItem(
                  'CG',
                  food.glycemicLoad.toStringAsFixed(1),
                  _getGlycemicLoadColor(food.glycemicLoad),
                ),
                _badgeItem(
                  'Qtd',
                  '${food.grams.toStringAsFixed(0)}g',
                  Colors.grey.shade500,
                ),
              ],
            ),
            if (food.glycemicIndexClassification.isNotEmpty ||
                food.glycemicLoadClassification.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (food.glycemicIndexClassification.isNotEmpty)
                    _buildClassificationBadge(
                      'Classificação IG',
                      food.glycemicIndexClassification,
                      _getGlycemicIndexColor(food.glycemicIndex),
                    ),
                  if (food.glycemicLoadClassification.isNotEmpty)
                    _buildClassificationBadge(
                      'Classificação CG',
                      food.glycemicLoadClassification,
                      _getGlycemicLoadColor(food.glycemicLoad),
                    ),
                ],
              ),
            ],
            if (food.category.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _badgeItem(
                    'Categoria',
                    food.category,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _badgeItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 BADGE PARA MOSTRAR QUE JÁ LEU
  Widget _buildReadBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '✅ Conteúdo lido!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGlycemicIndexColor(double gi) {
    if (gi <= 55) return Colors.green;
    if (gi <= 69) return Colors.orange;
    return Colors.red;
  }

  Color _getGlycemicLoadColor(double gl) {
    if (gl <= 10) return Colors.green;
    if (gl <= 19) return Colors.orange;
    return Colors.red;
  }
}
