import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/avatar_model.dart';

class AvatarRepository {
  final FirebaseFirestore _firestore;

  AvatarRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Busca todos os avatares
  Future<List<AvatarModel>> getAvatars() async {
    try {
      final snapshot = await _firestore
          .collection('avatar')
          .get();

      return snapshot.docs.map((doc) {
        return AvatarModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar avatares: $e');
      return [];
    }
  }

  // Busca avatares por sexo
  Future<List<AvatarModel>> getAvatarsBySex(String sex) async {
    try {
      final snapshot = await _firestore
          .collection('avatar')
          .where('sex', isEqualTo: sex)
          .get();

      return snapshot.docs.map((doc) {
        return AvatarModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar avatares por sexo: $e');
      return [];
    }
  }

  // Busca um avatar específico por ID
  Future<AvatarModel?> getAvatarById(String avatarId) async {
    try {
      final doc = await _firestore
          .collection('avatar')
          .doc(avatarId)
          .get();

      if (!doc.exists) return null;
      return AvatarModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('❌ Erro ao buscar avatar: $e');
      return null;
    }
  }
}