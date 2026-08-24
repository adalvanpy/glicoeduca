import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';  // ← ADICIONAR PARA debugPrint
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // 🔥 GERA EMAIL AUTOMÁTICO
  String _generateEmail(String username) {
    final cleanName = username.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '$cleanName@glicoeduca.com';
  }

  // 🔥 GERA SENHA AUTOMÁTICA
  String _generatePassword() {
    return 'Glico@${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}';
  }

  Future<UserModel?> getCurrentProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('❌ Nenhum usuário logado');
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('❌ Erro ao buscar perfil: $e');
      return null;
    }
  }

  // 🔥 REGISTRO
  Future<UserModel?> register({
    required String name,
    required String sex,
    String avatar = '',
  }) async {
    try {
      final email = _generateEmail(name);
      final password = _generatePassword();

      debugPrint('📧 Email gerado: $email');

      // Verifica se o nome já existe
      final existing = await _firestore
          .collection('users')
          .where('name', isEqualTo: name.trim())
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('❌ Nome já existe: $name');
        return null;
      }

      // 🔥 CRIA NO FIREBASE AUTH
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      debugPrint('✅ FirebaseAuth - Usuário criado: $userId');

      // 🔥 SALVA NO FIRESTORE
      final userData = {
        'name': name.trim(),
        'sex': sex,
        'avatar': avatar,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).set(userData);
      debugPrint('✅ Firestore - Usuário salvo: $userId');

      return UserModel(
        id: userId,
        name: name.trim(),
        sex: sex,
        avatar: avatar,
        email: email,
        password: password,
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final email = _generateEmail(name);
        final password = _generatePassword();
        try {
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          debugPrint('✅ Login automático: $email');
          final userId = _auth.currentUser!.uid;
          final doc = await _firestore.collection('users').doc(userId).get();
          if (doc.exists) {
            return UserModel.fromMap(doc.data()!, doc.id);
          }
        } catch (e) {
          debugPrint('❌ Erro no login automático: $e');
        }
      }
      debugPrint('❌ FirebaseAuth error: ${e.code}');
      return null;
    } catch (e) {
      debugPrint('❌ Erro no registro: $e');
      return null;
    }
  }

  // 🔥 LOGIN - APENAS COM O NOME!
  Future<UserModel?> signIn({required String username}) async {
    try {
      debugPrint('🔍 Buscando usuário: $username');

      // 1. BUSCA O USUÁRIO PELO NOME
      final snapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('❌ Usuário não encontrado: $username');
        return null;
      }

      final doc = snapshot.docs.first;
      final userData = doc.data();
      final email = userData['email'] as String?;
      final password = userData['password'] as String?;

      if (email == null || email.isEmpty) {
        debugPrint('❌ Usuário não tem email');
        return null;
      }

      if (password == null || password.isEmpty) {
        debugPrint('❌ Usuário não tem senha');
        return null;
      }

      debugPrint('📧 Email encontrado: $email');

      // 2. 🔥 FAZ LOGIN NO FIREBASE AUTH
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ FirebaseAuth - Login realizado: $username');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          debugPrint('✅ FirebaseAuth - Usuário recriado: $email');
        } else {
          debugPrint('❌ FirebaseAuth error: ${e.code}');
          return null;
        }
      }

      return UserModel.fromMap(userData, doc.id);

    } catch (e) {
      debugPrint('❌ Erro no signIn: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    debugPrint('✅ Usuário deslogado');
  }

  Future<void> updateUser({
    required String userId,
    String? name,
    String? sex,
    String? avatar,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name.trim();
      if (sex != null) updates['sex'] = sex;
      if (avatar != null) updates['avatar'] = avatar;

      await _firestore.collection('users').doc(userId).update(updates);
      debugPrint('✅ Usuário atualizado: $userId');

    } catch (e) {
      debugPrint('❌ Erro ao atualizar: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
        debugPrint('✅ Usuário deletado do FirebaseAuth');
      }

      await _firestore.collection('users').doc(userId).delete();
      debugPrint('✅ Usuário deletado do Firestore');

    } catch (e) {
      debugPrint('❌ Erro ao deletar: $e');
      rethrow;
    }
  }
}
