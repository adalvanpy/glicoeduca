import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/avatar_model.dart';

class AvatarRepository {
  final FirebaseFirestore _firestore;

  AvatarRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<AvatarModel>> getAvatars() async {
    try {
      final snapshot = await _firestore.collection('avatar').get();
      return _toAvatarList(snapshot.docs);
    } catch (_) {
      return [];
    }
  }

  Future<List<AvatarModel>> getAvatarsBySex(String sex) async {
    try {
      final snapshot = await _firestore
          .collection('avatar')
          .where('sex', isEqualTo: sex)
          .get();

      return _toAvatarList(snapshot.docs);
    } catch (_) {
      return [];
    }
  }

  Future<AvatarModel?> getAvatarById(String avatarId) async {
    try {
      final doc = await _firestore.collection('avatar').doc(avatarId).get();

      if (!doc.exists) return null;
      return AvatarModel.fromMap(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }

  List<AvatarModel> _toAvatarList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs
        .map((doc) => AvatarModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
