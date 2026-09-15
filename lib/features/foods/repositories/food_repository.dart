
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class FoodRepository {
  final FirebaseFirestore _firestore;

  FoodRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Map<String, dynamic> _documentData(DocumentSnapshot<Object?> doc) {
    final data = doc.data();
    if (data == null) {
      return <String, dynamic>{};
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    return Map<String, dynamic>.from(data as Map);
  }

  List<FoodModel> _mapFoods(QuerySnapshot<Object?> snapshot) {
    return snapshot.docs
        .map((doc) => FoodModel.fromMap(_documentData(doc), doc.id))
        .toList();
  }

  Future<List<FoodModel>> _safeQueryList(
    Future<QuerySnapshot<Object?>> Function() queryBuilder,
  ) async {
    try {
      final snapshot = await queryBuilder();
      return _mapFoods(snapshot);
    } catch (_) {
      return [];
    }
  }

  Future<List<FoodModel>> getFoods() async {
    return _safeQueryList(() => _firestore.collection('foods').get());
  }

  Future<FoodModel?> getFoodById(String foodId) async {
    if (foodId.trim().isEmpty) {
      return null;
    }

    try {
      final doc = await _firestore.collection('foods').doc(foodId).get();

      if (!doc.exists) {
        return null;
      }

      return FoodModel.fromMap(_documentData(doc), doc.id);
    } catch (_) {
      return null;
    }
  }

  Future<List<FoodModel>> getFoodsByCategory(String category) async {
    return _safeQueryList(
      () => _firestore
          .collection('foods')
          .where('category', isEqualTo: category)
          .get(),
    );
  }

  Future<List<FoodModel>> getFoodsByGlycemicIndexClassification(
      String classification) async {
    return _safeQueryList(
      () => _firestore
          .collection('foods')
          .where('glycemicIndexClassification', isEqualTo: classification)
          .get(),
    );
  }

  Future<List<FoodModel>> getFoodsByGlycemicLoadClassification(
      String classification) async {
    return _safeQueryList(
      () => _firestore
          .collection('foods')
          .where('glycemicLoadClassification', isEqualTo: classification)
          .get(),
    );
  }

  String _normalizeFilterValue(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  Future<List<FoodModel>> getFoodsFiltered({
    String? category,
    String? carbohydrateType,
    String? glycemicIndexClassification,
    String? glycemicLoadClassification,
  }) async {
    final foods = await getFoods();

    final normalizedCategory = _normalizeFilterValue(category);
    final normalizedCarbohydrateType = _normalizeFilterValue(carbohydrateType);
    final normalizedGlycemicIndexClassification =
        _normalizeFilterValue(glycemicIndexClassification);
    final normalizedGlycemicLoadClassification =
        _normalizeFilterValue(glycemicLoadClassification);

    return foods.where((food) {
      if (normalizedCategory.isNotEmpty &&
          _normalizeFilterValue(food.category) != normalizedCategory) {
        return false;
      }

      if (normalizedCarbohydrateType.isNotEmpty &&
          _normalizeFilterValue(food.carbohydrateType) !=
              normalizedCarbohydrateType) {
        return false;
      }

      if (normalizedGlycemicIndexClassification.isNotEmpty) {
        final igValue = _normalizeFilterValue(food.glycemicIndexClassification);
        if (igValue.isEmpty || igValue != normalizedGlycemicIndexClassification) {
          return false;
        }
      }

      if (normalizedGlycemicLoadClassification.isNotEmpty) {
        final cgValue = _normalizeFilterValue(food.glycemicLoadClassification);
        if (cgValue.isEmpty || cgValue != normalizedGlycemicLoadClassification) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<List<FoodModel>> getFoodsOrderedByGlycemicIndex() async {
    return _safeQueryList(
      () => _firestore.collection('foods').orderBy('glycemicIndex').get(),
    );
  }

  Future<List<FoodModel>> getFoodsOrderedByGlycemicLoad() async {
    return _safeQueryList(
      () => _firestore.collection('foods').orderBy('glycemicLoad').get(),
    );
  }
}
