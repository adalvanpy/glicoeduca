// duel_repository.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/duel_model.dart';
import '../../contexts/models/context_model.dart';
import '../../foods/models/food_model.dart';
import '../../nutritionist_tips/models/nutritionist_tips_model.dart';
import '../../progress/models/user_duel_progress_model.dart';

class DuelRepository {
  final CollectionReference _duelCollection = 
      FirebaseFirestore.instance.collection('duels');
  final CollectionReference _contextCollection = 
      FirebaseFirestore.instance.collection('contexts');
  final CollectionReference _foodCollection = 
      FirebaseFirestore.instance.collection('foods');
  final CollectionReference _nutritionistTipsCollection = 
      FirebaseFirestore.instance.collection('nutritionist_tips');
  final CollectionReference _progressCollection = 
      FirebaseFirestore.instance.collection('user_duel_progress');

  // Buscar todos os contextos
  Future<List<ContextModel>> getContexts() async {
    try {
      QuerySnapshot snapshot = await _contextCollection.get();

      return snapshot.docs.map((doc) {
        return ContextModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar contextos: $e');
    }
  }

  // Buscar duelos por contexto (apenas os IDs)
  Future<List<DuelModel>> getDuelsByContext(String contextId) async {
    try {
      QuerySnapshot snapshot = await _duelCollection
          .where('contextId', isEqualTo: contextId)
          .get();

      return snapshot.docs.map((doc) {
        return DuelModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar duelos: $e');
    }
  }

  // Buscar Food por ID
  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      DocumentSnapshot doc = await _foodCollection.doc(foodId).get();

      if (doc.exists) {
        return FoodModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar alimento: $e');
    }
  }

  // Buscar NutritionistTip por ID
  Future<NutritionistTipsModel?> getNutritionistTipById(String tipId) async {
    try {
      DocumentSnapshot doc = await _nutritionistTipsCollection.doc(tipId).get();

      if (doc.exists) {
        return NutritionistTipsModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dica: $e');
    }
  }

  // Buscar item por ID (tenta Food e depois NutritionistTip)
  Future<({dynamic item, String type})?> getItemById(String id) async {
    try {
      // Tentar buscar como Food
      DocumentSnapshot foodDoc = await _foodCollection.doc(id).get();
      if (foodDoc.exists) {
        final food = FoodModel.fromMap(
          foodDoc.data() as Map<String, dynamic>,
          foodDoc.id,
        );
        return (item: food, type: 'food');
      }

      // Tentar buscar como NutritionistTip
      DocumentSnapshot tipDoc = await _nutritionistTipsCollection.doc(id).get();
      if (tipDoc.exists) {
        final tip = NutritionistTipsModel.fromMap(
          tipDoc.data() as Map<String, dynamic>,
          tipDoc.id,
        );
        return (item: tip, type: 'nutritionist_tip');
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro ao buscar item: $e');
      return null;
    }
  }

  // Buscar progresso do usuário
  Future<UserDuelProgressModel?> getUserDuelProgress(String userId) async {
    try {
      QuerySnapshot snapshot = await _progressCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return UserDuelProgressModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar progresso: $e');
    }
  }

  // Salvar progresso do duelo
  Future<void> saveUserDuelProgress({
    required String userId,
    required bool isWinner,
  }) async {
    try {
      final existingProgress = await getUserDuelProgress(userId);

      if (existingProgress != null) {
        await _progressCollection.doc(existingProgress.id).update({
          'wins': FieldValue.increment(isWinner ? 1 : 0),
          'losses': FieldValue.increment(isWinner ? 0 : 1),
          'totalGames': FieldValue.increment(1),
          'updatedAt': DateTime.now(),
        });
      } else {
        await _progressCollection.add({
          'userId': userId,
          'wins': isWinner ? 1 : 0,
          'losses': isWinner ? 0 : 1,
          'totalGames': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao salvar progresso: $e');
    }
  }

  // Stream em tempo real - duelos por contexto
  Stream<List<DuelModel>> streamDuelsByContext(String contextId) {
    return _duelCollection
        .where('contextId', isEqualTo: contextId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DuelModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Stream em tempo real - progresso do usuário
  Stream<UserDuelProgressModel?> streamUserProgress(String userId) {
    return _progressCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return UserDuelProgressModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    });
  }
}