// lib/features/foods/repositories/food_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/food_model.dart';

class FoodRepository {
  final FirebaseFirestore _firestore;

  FoodRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 🔥 BUSCA TODOS OS ALIMENTOS
  Future<List<FoodModel>> getFoods() async {
    try {
      final snapshot = await _firestore.collection('foods').get();

      debugPrint('📋 Alimentos encontrados: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos: $e');
      return [];
    }
  }

  // 🔥 BUSCA ALIMENTO POR ID
  Future<FoodModel?> getFoodById(String foodId) async {
    if (foodId.trim().isEmpty) {
      debugPrint('⚠️ getFoodById: ID vazio!');
      return null;
    }

    try {
      final doc = await _firestore.collection('foods').doc(foodId).get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('⚠️ Alimento não encontrado: $foodId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      return FoodModel.fromMap(data, doc.id);
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimento $foodId: $e');
      return null;
    }
  }

  // 🔥 BUSCA ALIMENTOS POR CATEGORIA
  Future<List<FoodModel>> getFoodsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .where('category', isEqualTo: category)
          .get();

      debugPrint('📋 Alimentos da categoria $category: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos por categoria: $e');
      return [];
    }
  }

  // 🔥 BUSCA ALIMENTOS POR CLASSIFICAÇÃO DO ÍNDICE GLICÊMICO
  Future<List<FoodModel>> getFoodsByGlycemicIndexClassification(
      String classification) async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .where('glycemicIndexClassification', isEqualTo: classification)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos por classificação IG: $e');
      return [];
    }
  }

  // 🔥 BUSCA ALIMENTOS POR CLASSIFICAÇÃO DA CARGA GLICÊMICA
  Future<List<FoodModel>> getFoodsByGlycemicLoadClassification(
      String classification) async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .where('glycemicLoadClassification', isEqualTo: classification)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos por classificação CG: $e');
      return [];
    }
  }

  // 🔥 BUSCA ALIMENTOS COM FILTRO MÚLTIPLO
  Future<List<FoodModel>> getFoodsFiltered({
    String? category,
    String? glycemicIndexClassification,
    String? glycemicLoadClassification,
  }) async {
    try {
      Query query = _firestore.collection('foods');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (glycemicIndexClassification != null &&
          glycemicIndexClassification.isNotEmpty) {
        query = query.where('glycemicIndexClassification',
            isEqualTo: glycemicIndexClassification);
      }

      if (glycemicLoadClassification != null &&
          glycemicLoadClassification.isNotEmpty) {
        query = query.where('glycemicLoadClassification',
            isEqualTo: glycemicLoadClassification);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos filtrados: $e');
      return [];
    }
  }

  // 🔥 ORDENA ALIMENTOS POR ÍNDICE GLICÊMICO (CRESCENTE)
  Future<List<FoodModel>> getFoodsOrderedByGlycemicIndex() async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .orderBy('glycemicIndex')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos ordenados por IG: $e');
      return [];
    }
  }

  // 🔥 ORDENA ALIMENTOS POR CARGA GLICÊMICA (CRESCENTE)
  Future<List<FoodModel>> getFoodsOrderedByGlycemicLoad() async {
    try {
      final snapshot = await _firestore
          .collection('foods')
          .orderBy('glycemicLoad')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return FoodModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar alimentos ordenados por CG: $e');
      return [];
    }
  }
}