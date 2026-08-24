// duel_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

import '../controllers/duel_controller.dart';
import '../../foods/models/food_model.dart';
import '../../nutritionist_tips/models/nutritionist_tips_model.dart';

class DuelPage extends StatefulWidget {
  final DuelController controller;

  const DuelPage({
    super.key,
    required this.controller,
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
    // Carrega os contextos
    await widget.controller.loadContexts();

    if (widget.controller.contexts.isNotEmpty) {
      // 🔥 PEGA OS ARGUMENTOS DA ROTA
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      // 🔥 DEBUG - MOSTRA O QUE CHEGOU
      debugPrint('📦 Argumentos recebidos no DuelPage: $args');
      
      final contextId = args?['contextId'] as String?;
      final contextName = args?['contextName'] as String?;

      String? finalContextId;
      String? finalContextName;

      // 🔥 PRIORIZA O ID RECEBIDO
      if (contextId != null && contextId.isNotEmpty) {
        finalContextId = contextId;
        finalContextName = contextName ?? 'Contexto';
        debugPrint('✅ Usando contexto recebido: $finalContextName (ID: $finalContextId)');
      } else {
        // 🔥 FALLBACK: PRIMEIRO CONTEXTO
        finalContextId = widget.controller.contexts.first.id;
        finalContextName = widget.controller.contexts.first.name;
        debugPrint('⚠️ Nenhum ID recebido, usando primeiro contexto: $finalContextName (ID: $finalContextId)');
      }

      // 🔥 CARREGA O DUELO COM O ID CORRETO
      await widget.controller.loadDuel(finalContextId, contextName: finalContextName);
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
                    if (index == 1) {
                      Navigator.pushReplacementNamed(context, AppRoutes.optionTheory);
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, AppRoutes.instructionsQuiz);
                    } else if (index == 0) {
                      Navigator.pushReplacementNamed(context, AppRoutes.homePage);
                    } else if (index == 4) {
                      Navigator.pushReplacementNamed(context, AppRoutes.profile);
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
          'Escolha um contexto e selecione o alimento mais indicado. Depois, veja se você acertou!',
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
              ? controller.currentDuel?.foodAId == controller.currentDuel?.correctAnswerId
              : null,
          typeLabel: controller.itemATypeLabel,
          isFood: controller.isItemAFood,
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
              ? controller.currentDuel?.foodBId == controller.currentDuel?.correctAnswerId
              : null,
          typeLabel: controller.itemBTypeLabel,
          isFood: controller.isItemBFood,
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
    required String typeLabel,
    required bool isFood,
  }) {
    final controller = widget.controller;
    final bool showResult = controller.showResult;
    final bool isWinner = isCorrect == true;
    
    Color borderColor = Colors.transparent;
    double borderWidth = 0;
    
    if (showResult) {
      if (isWinner) {
        borderColor = AppTheme.successColor;
        borderWidth = 4;
      }
    } else if (isSelected) {
      borderColor = AppTheme.primaryColor;
      borderWidth = 4;
    }

    // 🔥 COR E ÍCONE BASEADO NO TIPO 🔥
    final Color typeColor = isFood ? Colors.blue : Colors.green;
    final IconData typeIcon = isFood ? Icons.restaurant : Icons.health_and_safety;

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
                          child: Icon(typeIcon, size: 40, color: typeColor),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(typeIcon, size: 40, color: typeColor),
                      ),
              ),
              if (showResult && isWinner)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
              // 🔥 BADGE DO TIPO 🔥
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, size: 10, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
          // 🔥 REMOVIDO IG E CG 🔥
        ],
      ),
    );
  }

  Widget _buildResult(DuelController controller) {
    final isCorrect = controller.isCorrect == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCorrect ? 'Você acertou!' : 'Você não acertou desta vez.', 
          style: isCorrect 
              ? TextStyles.success.copyWith(fontSize: 16, fontWeight: FontWeight.bold) 
              : const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.errorColor),
        ),
        const SizedBox(height: 6),
        Text(
          'A ${_correctItemName(controller)} é a opção mais indicada.', 
          style: isCorrect 
              ? TextStyles.success 
              : const TextStyle(fontSize: 14, color: AppTheme.errorColor),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isCorrect ? AppTheme.successColor : AppTheme.errorColor), 
          ),
          child: Text(
            // 🔥 USA A DESCRIPTION DO ITEM CORRETO 🔥
            controller.description, 
            style: isCorrect 
                ? TextStyles.explanation.copyWith(height: 1.3) 
                : const TextStyle(fontSize: 12, height: 1.3, color: AppTheme.errorColor),
          ),
        ),
      ],
    );
  }

  String _correctItemName(DuelController controller) {
    if (controller.currentDuel == null) return '';
    final correctId = controller.currentDuel!.correctAnswerId;
    
    if (controller.currentDuel?.foodAId == correctId) {
      return controller.itemAName;
    } else if (controller.currentDuel?.foodBId == correctId) {
      return controller.itemBName;
    }
    return '';
  }

  Widget _buildActionButton(DuelController controller) {
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
        onPressed: controller.isLoading 
            ? null 
            : (controller.showResult 
                ? () => _newDuel()
                : (controller.selectedItemId == null ? null : _showResultAndSave)),
        child: Text(
          controller.showResult ? 'Novo duelo' : 'Ver resultado',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _newDuel() async {
    await widget.controller.newDuel();
  }

  Future<void> _showResultAndSave() async {
    widget.controller.showDuelResult();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await widget.controller.saveResult(userId);
      } catch (_) {
      }
    }
  }
}
