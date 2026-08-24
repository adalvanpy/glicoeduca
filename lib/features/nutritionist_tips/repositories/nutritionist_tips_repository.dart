// lib/features/nutritionist_tips/repositories/nutritionist_tips_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/nutritionist_tips_model.dart';

class NutritionistTipsRepository {
  final FirebaseFirestore _firestore;

  NutritionistTipsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 🔥 BUSCA TODAS AS DICAS
  Future<List<NutritionistTipsModel>> getTips() async {
    try {
      final snapshot = await _firestore
          .collection('nutritionist_tips')
          .get();

      debugPrint('📋 Dicas encontradas: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return NutritionistTipsModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar dicas: $e');
      return [];
    }
  }

  // 🔥 BUSCA DICAS POR CONTEXTO
  Future<List<NutritionistTipsModel>> getTipsByContext(String contextId) async {
    try {
      final snapshot = await _firestore
          .collection('nutritionist_tips')
          .where('contextId', isEqualTo: contextId)
          .get();

      debugPrint('📋 Dicas do contexto $contextId: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return NutritionistTipsModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar dicas por contexto: $e');
      return [];
    }
  }
}