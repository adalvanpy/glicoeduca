// lib/features/nutritionist_tips/controller/nutritionist_tips_controller.dart
import 'package:flutter/foundation.dart';
import '../models/nutritionist_tips_model.dart';
import '../repositories/nutritionist_tips_repository.dart';

class NutritionistTipsController extends ChangeNotifier {
  final NutritionistTipsRepository repository;

  NutritionistTipsController({required this.repository});

  List<NutritionistTipsModel> tips = [];
  bool isLoading = false;
  String? errorMessage;

  // 🔥 CARREGA TODAS AS DICAS
  Future<void> loadTips() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tips = await repository.getTips();
      if (tips.isEmpty) {
        errorMessage = 'Nenhuma dica disponível.';
      }
      debugPrint('✅ Dicas carregadas: ${tips.length}');
    } catch (e) {
      errorMessage = 'Não foi possível carregar as dicas.';
      debugPrint('❌ Erro ao carregar dicas: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARREGA DICAS POR CONTEXTO
  Future<void> loadTipsByContext(String contextId) async {
    if (contextId.trim().isEmpty) {
      errorMessage = 'ID do contexto inválido.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tips = await repository.getTipsByContext(contextId);
      if (tips.isEmpty) {
        errorMessage = 'Nenhuma dica disponível para este contexto.';
      }
      debugPrint('✅ Dicas do contexto $contextId: ${tips.length}');
    } catch (e) {
      errorMessage = 'Não foi possível carregar as dicas.';
      debugPrint('❌ Erro ao carregar dicas por contexto: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 RESETA O CONTROLLER
  void reset() {
    tips = [];
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}