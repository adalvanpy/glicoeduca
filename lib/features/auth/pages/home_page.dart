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
      _user = await _getUserData(userId);

      if (_user != null && _user!.avatar.isNotEmpty) {
        try {
          _userAvatar = await _avatarRepo.getAvatarById(_user!.avatar);
        } catch (_) {
          _userAvatar = null;
        }
      } else {
        _userAvatar = null;
      }

      final progressList = await _progressRepo.getUserProgress(userId);

      _progress.clear();

      for (var p in progressList) {
        _progress[p.theoryTitle] = p.progress;
      }

      final quizResults = await _quizRepo.getResultsByUser(userId);

      if (quizResults.isNotEmpty) {
        _bestQuizScore = quizResults.map((e) => e.hits).reduce((a, b) => a > b ? a : b);
      } else {
        _bestQuizScore = 0;
      }

      _duelWins = await _getDuelWins(userId);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Future<int> _getDuelWins(String userId) async {
    try {
      final duelProgress = await _duelRepo.getUserDuelProgress(userId);

      if (duelProgress != null) {
        return duelProgress.wins;
      }

      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<UserModel?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (_) {
    }

    return null;
  }


  double _getProgress(String theoryTitle) {
    return _progress[theoryTitle] ?? 0.0;
  }


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


            AppBottomNavigation(
              currentIndex: 0,
              onItemSelected: (index) {
                switch (index) {
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
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.profile,
                    );
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    final userName = _user?.name ?? 'Usuário';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
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
              ),
            ),
            SizedBox(
              width: 38,
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.profile,
                    );
                  },
                  child: CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFFE4E4E4),
                    backgroundImage: _getUserAvatarImage(),
                    child: _getUserAvatarImage() == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF9E9E9E),
                            size: 26,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Bem vindo, $userName!',
          style: TextStyles.pageTitle.copyWith(
            fontSize: 24,
          ),
        ),
      ],
    );
  }


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


  Widget _buildProgressSection() {
    final theories = [
      {'id': 'carbohydrates', 'title': 'Carboidratos'},
      {'id': 'glycemic_index', 'title': 'Índice glicêmico'},
      {'id': 'glycemic_load', 'title': 'Carga glicêmica'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seus progressos',
          style: TextStyles.cardTitle,
        ),
        const SizedBox(height: 12),
        ...theories.map((theory) {
          final progress = _getProgress(theory['title']!);
          return _progressCard(
            title: theory['title']!,
            progress: progress,
          );
        }),
      ],
    );
  }


  Widget _progressCard({
    required String title,
    required double progress,
  }) {
    final percentage = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppTheme.cardDecoration(
        borderColor: AppTheme.infoCardBorder.withValues(alpha: 0.5),
        radius: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyles.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _getProgressColor(progress),
            ),
          ),
        ],
      ),
    );
  }


  Color _getProgressColor(double progress) {
    if (progress >= 0.7) {
      return AppTheme.successColor;
    }

    if (progress >= 0.4) {
      return Colors.orange;
    }

    return Colors.red;
  }


  Widget _buildStatsSection() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _statCard(
              title: 'Melhor pontuação quiz',
              value: '$_bestQuizScore%',
              color: AppTheme.successColor,
              icon: Icons.emoji_events_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              title: 'Acertos em duelos',
              value: '$_duelWins',
              color: AppTheme.successColor,
              icon: Icons.sports_score_rounded,
            ),
          ),
        ],
      ),
    );
  }


  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.infoCardBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
