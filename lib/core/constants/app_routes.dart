import 'package:flutter/material.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

import '../../features/theory/pages/theory_page.dart';
import '../../features/options/pages/option_theory_page.dart';

import '../../features/duel/controllers/duel_controller.dart';
import '../../features/duel/pages/duel_page.dart';
import '../../features/duel/pages/instructions_duel_page.dart';
import '../../features/duel/repositories/duel_repository.dart';

import '../../features/quiz/pages/quiz_page.dart';
import '../../features/quiz/pages/quiz_result_page.dart';
import '../../features/quiz/pages/instructions_quiz_page.dart';

import '../../features/foods/pages/food_page.dart';  // ← IMPORT CORRETO
import '../../features/nutritionist_tips/pages/nutritionist_tips_page.dart';

import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_name_page.dart';
import '../../features/profile/pages/edit_avatar_page.dart';
import '../../features/auth/pages/home_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String createUser = '/create-user';

  static const String theory = '/theory';
  static const String theoryContent = '/theory-content';

  static const String duel = '/duel';
  static const String instructionsDuel = '/instructions-duel';
  static const String instructionsQuiz = '/instructions-quiz';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';

  static const String food = '/food';  // ← ROTA ADICIONADA
  static const String nutritionistTips = '/nutritionist-tips';  // ← ROTA ADICIONADA

  static const String profile = '/profile';
  static const String editName = '/edit-name';
  static const String editAvatar = '/edit-avatar';
  static const String optionTheory = '/option-theory';
  static const String homePage = 'home-page';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case createUser:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case optionTheory:
        return MaterialPageRoute(builder: (_) => const OptionTheoryPage());

      case theory:
        final theoryId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => TheoryPage(theoryId: theoryId),
        );

      case theoryContent:
        return MaterialPageRoute(builder: (_) => const TheoryPage());

      case duel:
        return MaterialPageRoute(
          builder: (_) => DuelPage(
            controller: DuelController(
              repository: DuelRepository(),
            ),
          ),
        );

      case instructionsDuel:
        return MaterialPageRoute(builder: (_) => const InstructionsDuelPage());

      case homePage:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case instructionsQuiz:
        return MaterialPageRoute(builder: (_) => const InstructionsQuizPage());

      case quiz:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QuizPage(
            level: args?['level'] ?? 'Fácil',
          ),
        );

      case quizResult:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => QuizResultPage(
            hits: args?['hits'] ?? 0,
            total: args?['total'] ?? 0,
            level: args?['level'] ?? 'Fácil',
          ),
        );

      case food:
        return MaterialPageRoute(builder: (_) => const FoodPage());

      case nutritionistTips:
        return MaterialPageRoute(builder: (_) => const NutritionistTipsPage());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case editName:
        return MaterialPageRoute(builder: (_) => const EditNamePage());

      case editAvatar:
        return MaterialPageRoute(builder: (_) => const EditAvatarPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Rota não encontrada'),
            ),
          ),
        );
    }
  }
}
