
import 'package:flutter/foundation.dart';
import '../models/nutritionist_tips_model.dart';
import '../repositories/nutritionist_tips_repository.dart';

class NutritionistTipsController extends ChangeNotifier {
  final NutritionistTipsRepository repository;

  NutritionistTipsController({required this.repository});

  List<NutritionistTipsModel> tips = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTips() async {
    await _loadTips(
      fetcher: repository.getTips,
      emptyMessage: 'Nenhuma dica disponível.',
    );
  }

  Future<void> loadTipsByContext(String contextId) async {
    if (contextId.trim().isEmpty) {
      errorMessage = 'ID do contexto inválido.';
      notifyListeners();
      return;
    }

    await _loadTips(
      fetcher: () => repository.getTipsByContext(contextId),
      emptyMessage: 'Nenhuma dica disponível para este contexto.',
    );
  }

  Future<void> _loadTips({
    required Future<List<NutritionistTipsModel>> Function() fetcher,
    required String emptyMessage,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      tips = await fetcher();
      if (tips.isEmpty) {
        errorMessage = emptyMessage;
      }
    } catch (_) {
      errorMessage = 'Não foi possível carregar as dicas.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    tips = [];
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
