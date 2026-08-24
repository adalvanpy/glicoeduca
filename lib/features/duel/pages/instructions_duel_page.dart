import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../contexts/models/context_model.dart';

class InstructionsDuelPage extends StatefulWidget {
  const InstructionsDuelPage({super.key});

  @override
  State<InstructionsDuelPage> createState() =>
      _InstructionsDuelPageState();
}

class _InstructionsDuelPageState
    extends State<InstructionsDuelPage> {

  String? _selectedContextId;

  List<ContextModel> _contexts = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContextsFromFirestore();
  }

  // ============================================================
  // CARREGAR CONTEXTOS DO FIRESTORE
  // ============================================================

  Future<void> _loadContextsFromFirestore() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await FirebaseFirestore.instance
          .collection('contexts')
          .orderBy('order')
          .get();

      final contexts = snapshot.docs.map((doc) {
        return ContextModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _contexts = contexts;
        _isLoading = false;
      });

      print(
        '📋 Contextos carregados: ${_contexts.length}',
      );

      for (final context in _contexts) {
        print(
          '   - ${context.name} '
          '(ID: ${context.id})',
        );
      }
    } catch (e) {
      print(
        '❌ Erro ao carregar contextos: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // COR DOS CONTEXTOS
  // ============================================================

  Color _getContextColor(String id) {
    switch (id) {
      case 'breakfast':
        return AppTheme.breakfastColor;

      case 'morning_snack':
        return AppTheme.morningSnackColor;

      case 'lunch':
        return AppTheme.lunchColor;

      case 'pre_workout':
        return AppTheme.preWorkoutColor;

      case 'post_workout':
        return AppTheme.postWorkoutColor;

      case 'dinner':
        return AppTheme.dinnerColor;

      case 'afternoon_snack':
        return AppTheme.afternoonSnackColor;

      case 'supper':
        return AppTheme.supperColor;

      default:
        return AppTheme.contextDefaultColor;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // CONTEÚDO
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  12,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // Logo
                    _buildLogo(),

                    const SizedBox(height: 24),

                    // Título
                    _buildTitle(),

                    const SizedBox(height: 12),

                    // Instruções
                    _buildInstructions(),

                    const SizedBox(height: 24),

                    // Contextos
                    _buildContextSelector(),

                    const SizedBox(height: 32),

                    // Botão
                    _buildStartButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BOTTOM NAVIGATION
            // ==================================================

            AppBottomNavigation(
              currentIndex: 2,

              onItemSelected: (index) {

                if (index == 0) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.homePage,
                  );
                }

                else if (index == 1) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.optionTheory,
                  );
                }

                else if (index == 3) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.instructionsQuiz,
                  );
                }

                else if (index == 4) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.profile,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        children: [

          TextSpan(
            text: 'Glico',
            style: TextStyles.logoRed,
          ),

          TextSpan(
            text: 'Educa',
            style: TextStyles.logoGreen,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildTitle() {
    return const Text(
      'Duelo GlicoEduca',

      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  // ============================================================
  // INSTRUÇÕES
  // ============================================================

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(
          alpha: 0.06,
        ),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: AppTheme.primaryColor.withValues(
            alpha: 0.15,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            'Instruções:',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Escolha um contexto e clique em '
            '"Iniciar duelo". Selecione o alimento '
            'mais indicado. Depois, veja se você acertou!',

            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELEÇÃO DOS CONTEXTOS
  // ============================================================

  Widget _buildContextSelector() {

    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),

          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // NENHUM CONTEXTO
    // ----------------------------------------------------------

    if (_contexts.isEmpty) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.grey.shade50,

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: const Center(
          child: Text(
            'Nenhum contexto disponível.',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // CONTEXTOS
    // ----------------------------------------------------------

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          'Selecione o contexto',

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),

        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: _contexts.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,

            crossAxisSpacing: 12,

            mainAxisSpacing: 10,

            childAspectRatio: 2.9,
          ),

          itemBuilder: (context, index) {

            final item = _contexts[index];

            return _contextCard(
              id: item.id,

              name: item.name,

              isSelected:
                  _selectedContextId ==
                      item.id,
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // CARD DO CONTEXTO
  // ============================================================

  Widget _contextCard({
    required String id,
    required String name,
    required bool isSelected,
  }) {

    final color =
        _getContextColor(id);

    return GestureDetector(

      onTap: () {

        setState(() {
          _selectedContextId = id;
        });

        print(
          '🔍 Contexto selecionado: '
          '$name (ID: $id)',
        );
      },

      child: AnimatedContainer(

        duration:
            const Duration(milliseconds: 150),

        alignment: Alignment.center,

        decoration: BoxDecoration(

          color: color,

          borderRadius:
              BorderRadius.circular(8),

          border: isSelected
              ? Border.all(
                  color:
                      AppTheme.textColor,
                  width: 2,
                )
              : null,

          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Colors.black.withValues(
                      alpha: 0.12,
                    ),

                    blurRadius: 3,

                    offset:
                        const Offset(0, 2),
                  ),
                ]
              : null,
        ),

        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
          ),

          child: Text(
            name,

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 12,

              fontWeight:
                  FontWeight.w600,

              color:
                  AppTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTÃO INICIAR DUELO
  // ============================================================

  Widget _buildStartButton() {

    final isEnabled =
        _selectedContextId != null;

    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(

        onPressed: !isEnabled
            ? null
            : () {

                final selectedContext =
                    _contexts.firstWhere(
                  (c) =>
                      c.id ==
                      _selectedContextId,
                );

                print(
                  '🚀 Iniciando duelo: '
                  '${selectedContext.name} '
                  '(ID: ${selectedContext.id})',
                );

                Navigator.pushNamed(
                  context,
                  AppRoutes.duel,

                  arguments: {
                    'contextId':
                        selectedContext.id,

                    'contextName':
                        selectedContext.name,
                  },
                );
              },

        style:
            ElevatedButton.styleFrom(

          backgroundColor:
              AppTheme.primaryColor,

          foregroundColor:
              Colors.white,

          disabledBackgroundColor:
              Colors.grey.shade300,

          disabledForegroundColor:
              Colors.white,

          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),

          elevation: 0,
        ),

        child: const Text(
          'Iniciar duelo',

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}