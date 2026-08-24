import 'package:flutter/foundation.dart';
import '../models/theory_model.dart';
import '../../foods/models/food_model.dart';
import '../repositories/theory_repository.dart';

class TheoryController extends ChangeNotifier {
  final TheoryRepository repository;
  TheoryModel? selectedTheory;
  bool isLoading = false;
  String? errorMessage;

  TheoryController({required this.repository});

  Future<void> loadTheoryById(String? theoryId) async {
    if (theoryId == null || theoryId.isEmpty) {
      errorMessage = 'ID do conteúdo não encontrado';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedTheory = await repository.getTheoryById(theoryId);

      if (selectedTheory == null) {
        errorMessage = 'Conteúdo não encontrado';
      }
    } catch (e) {
      errorMessage = 'Não foi possível carregar o conteúdo.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedTheory = null;
    errorMessage = null;
  }
}
