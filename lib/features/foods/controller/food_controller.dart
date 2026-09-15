
import 'package:flutter/foundation.dart';
import '../models/food_model.dart';
import '../repositories/food_repository.dart';

class FoodController extends ChangeNotifier {
  final FoodRepository repository;

  FoodController({required this.repository});

  List<FoodModel> foods = [];
  FoodModel? selectedFood;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadFoods() async {
    await _loadFoods(
      fetcher: repository.getFoods,
      emptyMessage: 'Nenhum alimento disponível.',
    );
  }

  Future<void> loadFoodsFiltered({
    String? category,
    String? carbohydrateType,
    String? glycemicIndexClassification,
    String? glycemicLoadClassification,
  }) async {
    await _loadFoods(
      fetcher: () => repository.getFoodsFiltered(
        category: category,
        carbohydrateType: carbohydrateType,
        glycemicIndexClassification: glycemicIndexClassification,
        glycemicLoadClassification: glycemicLoadClassification,
      ),
      emptyMessage: 'Nenhum alimento encontrado com os filtros aplicados.',
    );
  }

  Future<void> _loadFoods({
    required Future<List<FoodModel>> Function() fetcher,
    required String emptyMessage,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      foods = await fetcher();
      if (foods.isEmpty) {
        errorMessage = emptyMessage;
      }
    } catch (_) {
      errorMessage = 'Não foi possível carregar os alimentos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    foods = [];
    selectedFood = null;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
