import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';

import '../../auth/models/user_model.dart';

import '../../progress/repositories/user_progress_repository.dart';

import '../../quiz/repositories/quiz_repository.dart';
import '../../duel/repositories/duel_repository.dart';

import '../../profile/repositories/avatar_repository.dart';
import '../../profile/models/avatar_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _user;
  AvatarModel? _userAvatar;

  bool _isLoading = true;

  final Map<String, double> _progress = {};

  int _bestQuizScore = 0;
  int _duelWins = 0;

  final ProgressRepository _progressRepo = ProgressRepository();
  final QuizRepository _quizRepo = QuizRepository();
  final DuelRepository _duelRepo = DuelRepository();
  final AvatarRepository _avatarRepo = AvatarRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ================================================================
  // CARREGAR DADOS DO USUÁRIO
  // ================================================================

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      // ============================================================
      // USUÁRIO
      // ============================================================

      _user = await _getUserData(userId);

      // ============================================================
      // AVATAR
      // ============================================================

      if (_user != null && _user!.avatar.isNotEmpty) {
        try {
          _userAvatar = await _avatarRepo.getAvatarById(
            _user!.avatar,
          );

          debugPrint(
            '🧑 Avatar ID: ${_user!.avatar}',
          );

          debugPrint(
            '🖼️ Avatar imagem: ${_userAvatar?.image}',
          );
        } catch (e) {
          debugPrint(
            '⚠️ Erro ao carregar avatar: $e',
          );

          _userAvatar = null;
        }
      } else {
        _userAvatar = null;
      }

      // ============================================================
      // PROGRESSO DAS TEORIAS
      // ============================================================

      final progressList =
          await _progressRepo.getUserProgress(userId);

      _progress.clear();

      for (var p in progressList) {
        _progress[p.theoryTitle] = p.progress;
      }

      // ============================================================
      // QUIZ
      // ============================================================

      final quizResults =
          await _quizRepo.getResultsByUser(userId);

      if (quizResults.isNotEmpty) {
        _bestQuizScore = quizResults
            .map((e) => e.hits)
            .reduce(
              (a, b) => a > b ? a : b,
            );
      } else {
        _bestQuizScore = 0;
      }

      // ============================================================
      // DUELOS
      // ============================================================

      _duelWins = await _getDuelWins(userId);
    } catch (e) {
      debugPrint(
        '❌ Erro ao carregar dados: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================================================================
  // BUSCAR VITÓRIAS DOS DUELOS
  // ================================================================

  Future<int> _getDuelWins(String userId) async {
    try {
      final duelProgress =
          await _duelRepo.getUserDuelProgress(userId);

      if (duelProgress != null) {
        return duelProgress.wins;
      }

      return 0;
    } catch (e) {
      debugPrint(
        '⚠️ Erro ao carregar vitórias dos duelos: $e',
      );

      return 0;
    }
  }

  // ================================================================
  // BUSCAR USUÁRIO
  // ================================================================

  Future<UserModel?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(
          doc.data()!,
          doc.id,
        );
      }
    } catch (e) {
      debugPrint(
        '❌ Erro ao buscar usuário: $e',
      );
    }

    return null;
  }

  // ================================================================
  // BUSCAR PROGRESSO
  // ================================================================

  double _getProgress(String theoryTitle) {
    return _progress[theoryTitle] ?? 0.0;
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
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
                          _buildHeader(),

                          const SizedBox(height: 28),

                          _buildProgressSection(),

                          const SizedBox(height: 24),

                          _buildStatsSection(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),

            // ========================================================
            // BOTTOM NAVIGATION
            // ========================================================

            AppBottomNavigation(
              currentIndex: 0,

              onItemSelected: (index) {
                if (index == 1) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.optionTheory,
                  );
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.instructionsDuel,
                  );
                } else if (index == 3) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.instructionsQuiz,
                  );
                } else if (index == 4) {
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

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    final userName = _user?.name ?? 'Usuário';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ========================================================
            // LOGO
            // ========================================================

            RichText(
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

            const Spacer(),

            // ========================================================
            // AVATAR
            // ========================================================

            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.profile,
                );
              },
              child: CircleAvatar(
                radius: 22,

                backgroundColor:
                    const Color(0xFFE3F2FD),

                backgroundImage:
                    _getUserAvatarImage(),

                child: _getUserAvatarImage() == null
                    ? const Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 26,
                      )
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ============================================================
        // SAUDAÇÃO
        // ============================================================

        Text(
          'Bem vindo, $userName!',

          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // IMAGEM DO AVATAR
  // ================================================================

  ImageProvider? _getUserAvatarImage() {
    if (_userAvatar == null) {
      return null;
    }

    final image = _userAvatar!.image;

    if (image.isEmpty) {
      return null;
    }

    if (image.startsWith('http')) {
      return NetworkImage(image);
    }

    return null;
  }

  // ================================================================
  // SEÇÃO DE PROGRESSO
  // ================================================================

  Widget _buildProgressSection() {
    final theories = [
      {
        'id': 'carbohydrates',
        'title': 'Carboidratos',
      },
      {
        'id': 'glycemic_index',
        'title': 'Índice Glicêmico',
      },
      {
        'id': 'glycemic_load',
        'title': 'Carga Glicêmica',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seus progressos',

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 14),

        ...theories.map(
          (theory) {
            final progress =
                _getProgress(theory['title']!);

            return _progressCard(
              title: theory['title']!,
              progress: progress,
            );
          },
        ),
      ],
    );
  }

  // ================================================================
  // CARD DE PROGRESSO
  // ================================================================

  Widget _progressCard({
    required String title,
    required double progress,
  }) {
    final percentage =
        (progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(10),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),

            blurRadius: 6,

            offset: const Offset(0, 2),
          ),
        ],

        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '$percentage%',

            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color:
                  _getProgressColor(progress),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // COR DO PROGRESSO
  // ================================================================

  Color _getProgressColor(double progress) {
    if (progress >= 0.7) {
      return AppTheme.successColor;
    }

    if (progress >= 0.4) {
      return Colors.orange;
    }

    return Colors.red;
  }

  // ================================================================
  // ESTATÍSTICAS
  // ================================================================

  Widget _buildStatsSection() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          Expanded(
            child: _statCard(
              title: 'Melhor pontuação quiz',
              value: '$_bestQuizScore%',
              icon: Icons.quiz,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _statCard(
              title: 'Acertos em duelos',
              value: '$_duelWins',
              icon: Icons.emoji_events,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CARD DE ESTATÍSTICA
  // ================================================================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.06,
        ),

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: color.withValues(
            alpha: 0.15,
          ),

          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 22,
            color: color,
          ),

          const SizedBox(height: 6),

          Text(
            value,

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,

            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}