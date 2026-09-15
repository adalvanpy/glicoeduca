
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

import '../controllers/duel_controller.dart';

class DuelPage extends StatefulWidget {
  final DuelController controller;
  final String? initialContextId;
  final String? initialContextName;

  const DuelPage({
    super.key,
    required this.controller,
    this.initialContextId,
    this.initialContextName,
  });

  @override
  State<DuelPage> createState() => _DuelPageState();
}

class _DuelPageState extends State<DuelPage> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await widget.controller.loadContexts();

    if (widget.controller.contexts.isNotEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final routeContextId = args?['contextId'] as String?;
      final routeContextName = args?['contextName'] as String?;

      final selectedContextId =
          (routeContextId != null && routeContextId.isNotEmpty)
              ? routeContextId
              : (widget.initialContextId != null && widget.initialContextId!.isNotEmpty
                  ? widget.initialContextId!
                  : widget.controller.contexts.first.id);

      final selectedContextName =
          (routeContextName != null && routeContextName.isNotEmpty)
              ? routeContextName
              : (widget.initialContextName != null && widget.initialContextName!.isNotEmpty
                  ? widget.initialContextName!
                  : widget.controller.contexts.first.name);

      await widget.controller.loadDuel(
        selectedContextId,
        contextName: selectedContextName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 10),
                    child: _buildContent(widget.controller),
                  ),
                ),
                AppBottomNavigation(
                  currentIndex: 2,
                  onItemSelected: (index) {
                    switch (index) {
                      case 0:
                        Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                        break;
                      case 1:
                        Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(DuelController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.errorMessage != null && controller.currentDuel == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(controller.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogo(),
        const SizedBox(height: 24),
        const Text('Duelo entre alimentos', style: TextStyles.pageTitle),
        const SizedBox(height: 7),
        const Text(
          'Selecione o alimento mais indicado de acordo com o contexto escolhido e veja se você acertou!',
          style: TextStyles.description,
        ),
        const SizedBox(height: 20),
        _buildContextInfo(controller),
        const SizedBox(height: 24),
        if (controller.itemA != null && controller.itemB != null)
          _buildDuelItems(controller),
        const SizedBox(height: 20),
        if (!controller.showResult && controller.itemA != null && controller.itemB != null)
          const Center(
            child: Text('Qual opção é mais indicada?', style: TextStyles.question, textAlign: TextAlign.center),
          ),
        if (controller.showResult) _buildResult(controller),
        const SizedBox(height: 25),
        _buildActionButton(controller),
      ],
    );
  }

  Widget _buildLogo() {
    return Align(
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
    );
  }

  Widget _buildContextInfo(DuelController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.restaurant,
            color: Colors.black54,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            controller.currentContextName ?? 'Contexto não selecionado',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuelItems(DuelController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDuelItem(
          name: controller.itemAName,
          image: controller.itemAImage,
          id: controller.currentDuel?.foodAId ?? '',
          isSelected: controller.selectedItemId == controller.currentDuel?.foodAId,
          isCorrect: controller.showResult 
              ? controller.currentDuel?.foodAId == controller.currentDuel?.correctFoodId
              : null,
        )),
        const SizedBox(width: 8),
        const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Text('VS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildDuelItem(
          name: controller.itemBName,
          image: controller.itemBImage,
          id: controller.currentDuel?.foodBId ?? '',
          isSelected: controller.selectedItemId == controller.currentDuel?.foodBId,
          isCorrect: controller.showResult 
              ? controller.currentDuel?.foodBId == controller.currentDuel?.correctFoodId
              : null,
        )),
      ],
    );
  }

  Widget _buildDuelItem({
    required String name,
    required String image,
    required String id,
    required bool isSelected,
    required bool? isCorrect,
  }) {
    final controller = widget.controller;
    final showResult = controller.showResult;
    final isWinner = isCorrect == true;

    final borderColor = showResult
        ? (isWinner ? AppTheme.successColor : Colors.transparent)
        : (isSelected ? AppTheme.primaryColor : Colors.transparent);

    final borderWidth = borderColor == Colors.transparent ? 0.0 : 4.0;

    return GestureDetector(
      onTap: showResult ? null : () => controller.selectItem(id),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 118,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                clipBehavior: Clip.antiAlias,
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              if (showResult && isWinner)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyles.foodName.copyWith(
              color: showResult && isWinner ? AppTheme.successColor : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(DuelController controller) {
    final isCorrect = controller.isCorrect == true;
    final resultTextStyle = isCorrect
        ? TextStyles.success.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
        : const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.errorColor,
          );

    final explanationTextStyle = isCorrect
        ? TextStyles.success
        : const TextStyle(fontSize: 14, color: AppTheme.errorColor);

    final cardTextStyle = isCorrect
        ? TextStyles.explanation.copyWith(height: 1.3)
        : const TextStyle(fontSize: 12, height: 1.3, color: AppTheme.errorColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCorrect ? 'Você acertou!' : 'Você não acertou desta vez.',
          style: resultTextStyle,
        ),
        const SizedBox(height: 6),
        Text(
          'A ${_correctItemName(controller)} é a opção mais indicada.',
          style: explanationTextStyle,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
          child: Text(
            controller.description,
            style: cardTextStyle,
          ),
        ),
      ],
    );
  }

  String _correctItemName(DuelController controller) {
    if (controller.currentDuel == null) return '';
    final correctId = controller.currentDuel!.correctFoodId;
    
    if (controller.currentDuel?.foodAId == correctId) {
      return controller.itemAName;
    } else if (controller.currentDuel?.foodBId == correctId) {
      return controller.itemBName;
    }
    return '';
  }

  Widget _buildActionButton(DuelController controller) {
    if (controller.showResult) {
      if (controller.isDuelLimitReached) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Duelos atingidos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                      },
                      child: const Text(
                        'Escolher novo contexto',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await widget.controller.restartCurrentContext();
                      },
                      child: const Text(
                        'Refazer duelo',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.isLoading ? null : _newDuel,
                child: const Text(
                  'Novo duelo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel);
                },
                child: const Text(
                  'Escolher outro contexto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: controller.isLoading ? null : _handleAction(controller),
        child: const Text(
          'Ver resultado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void Function()? _handleAction(DuelController controller) {
    if (controller.showResult) {
      return () => _newDuel();
    }

    if (controller.selectedItemId == null) {
      return null;
    }

    return _showResultAndSave;
  }

  Future<void> _newDuel() async {
    await widget.controller.newDuel();
  }

  Future<void> _showResultAndSave() async {
    widget.controller.showDuelResult();
    widget.controller.registerCompletedDuel();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await widget.controller.saveResult(userId);
    } catch (_) {}
  }
}

