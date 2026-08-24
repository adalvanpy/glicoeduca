// lib/features/foods/controller/food_controller.dart
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
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      foods = await repository.getFoods();
      if (foods.isEmpty) {
        errorMessage = 'Nenhum alimento disponível.';
      }
    } catch (e) {
      errorMessage = 'Não foi possível carregar os alimentos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFoodsFiltered({
    String? category,
    String? glycemicIndexClassification,
    String? glycemicLoadClassification,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      foods = await repository.getFoodsFiltered(
        category: category,
        glycemicIndexClassification: glycemicIndexClassification,
        glycemicLoadClassification: glycemicLoadClassification,
      );
      if (foods.isEmpty) {
        errorMessage = 'Nenhum alimento encontrado com os filtros aplicados.';
      }
    } catch (e) {
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