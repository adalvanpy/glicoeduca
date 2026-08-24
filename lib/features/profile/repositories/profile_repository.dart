import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel?> getProfile(String userId) async {
    _validateUserId(userId);

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }

  Future<void> updateName(
    String userId,
    String name,
  ) async {
    _validateUserId(userId);

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError('O nome não pode estar vazio.');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .update({
      'name': normalizedName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAvatar(
    String userId,
    String avatar,
  ) async {
    _validateUserId(userId);

    final normalizedAvatar = avatar.trim();
    if (normalizedAvatar.isEmpty) {
      throw ArgumentError('O avatar não pode estar vazio.');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .update({
      'avatar': normalizedAvatar,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('O identificador do usuário não pode estar vazio.');
    }
  }
}
