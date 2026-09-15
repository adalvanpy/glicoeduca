import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../contexts/models/context_model.dart';
import '../../progress/repositories/user_progress_repository.dart';

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
  bool _canAccessDuel = false;

  @override
  void initState() {
    super.initState();
    _loadContextsFromFirestore();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _canAccessDuel = false;
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

    final canAccess = requiredTitles.every(
      (title) => (progressMap[title] ?? 0.0) >= 1.0,
    );

    if (!mounted) return;

    setState(() {
      _canAccessDuel = canAccess;
    });
  }


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
        return ContextModel.fromMap(doc.data(), doc.id);
      }).toList();

      if (!mounted) return;

      setState(() {
        _contexts = contexts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildInstructions(),
                    const SizedBox(height: 24),
                    _buildContextSelector(),
                    const SizedBox(height: 32),
                    if (!_canAccessDuel) _buildAccessBlockedMessage(),
                    _buildStartButton(),
                    const SizedBox(height: 20),
                  ],
                ),
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
        ),
      ),
    );
  }


  Widget _buildLogo() {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
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
      ),
    );
  }


  Widget _buildTitle() {
    return const Text(
      'Duelo glicoeduca',
      style: TextStyles.pageTitle,
    );
  }


  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.infoCardBorder.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(
            'Instruções:',
            style: TextStyles.cardTitle,
          ),

          const SizedBox(height: 8),

          Text(
            'Escolha um contexto e clique em '
            '"Iniciar duelo"',
            style: TextStyles.description.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContextSelector() {


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
            style: TextStyles.description,
          ),
        ),
      );
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione o contexto',
          style: TextStyles.cardTitle,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _contexts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            final item = _contexts[index];
            return _contextCard(
              id: item.id,
              name: item.name,
              isSelected: _selectedContextId == item.id,
            );
          },
        ),
      ],
    );
  }


  Widget _contextCard({
    required String id,
    required String name,
    required bool isSelected,
  }) {
    final borderColor = AppTheme.getContextBorderColor(id);
    final backgroundColor = AppTheme.getContextBackgroundColor(id);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContextId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? backgroundColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyles.cardBodyText.copyWith(
            color: AppTheme.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }


  Widget _buildAccessBlockedMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E90FF), width: 1),
      ),
      child: const Text(
        'Você precisa acessar todos os cards do guia para liberar o duelo.',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final isEnabled = _selectedContextId != null && _canAccessDuel;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isEnabled
            ? null
            : () {
                final selectedContext = _contexts.firstWhere(
                  (c) => c.id == _selectedContextId,
                );

                Navigator.pushNamed(
                  context,
                  AppRoutes.duel,
                  arguments: {
                    'contextId': selectedContext.id,
                    'contextName': selectedContext.name,
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Iniciar duelo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
