import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AuthController({required this.repository}) {
    // 🔥 ESCUTA MUDANÇAS NO ESTADO DE AUTENTICAÇÃO DO FIREBASE
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        print('🔍 AuthController - Usuário Firebase detectado: ${firebaseUser.uid}');
        // Recarrega o perfil do usuário
        loadCurrentUser();
      } else {
        print('🔍 AuthController - Usuário Firebase deslogado');
        user = null;
        notifyListeners();
      }
    });
  }

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => user != null;

  Future<void> signIn(String username) async {
    await _run(
      () async {
        final result = await repository.signIn(username: username);
        if (result == null) {
          errorMessage = 'Usuário não encontrado.';
        } else {
          user = result;
          // 🔥 VERIFICA SE O FIREBASE AUTH TAMBÉM ESTÁ LOGADO
          final firebaseUser = FirebaseAuth.instance.currentUser;
          print('✅ signIn - Firebase user: ${firebaseUser?.uid}');
        }
      },
      'Nome de usuário não encontrado.'
    );
  }

  Future<void> register(String name, String sex, {String avatar = ''}) async {
    await _run(
      () async => user = await repository.register(
        name: name, 
        sex: sex, 
        avatar: avatar
      ),
      'Não foi possível criar seu usuário.'
    );
  }

  Future<void> loadCurrentUser() async {
    try {
      print('🔍 loadCurrentUser - Carregando perfil...');
      user = await repository.getCurrentProfile();
      if (user == null) {
        errorMessage = 'Nenhum usuário logado.';
        print('❌ loadCurrentUser - Nenhum usuário logado');
      } else {
        print('✅ loadCurrentUser - Usuário carregado: ${user!.name} (${user!.id})');
      }
    } catch (e) {
      errorMessage = 'Não foi possível carregar o usuário atual.';
      print('❌ Erro ao carregar usuário: $e');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await repository.signOut();
    user = null;
    errorMessage = null;
    notifyListeners();
    print('✅ Usuário deslogado');
  }

  Future<void> updateUser({
    String? name,
    String? sex,
    String? avatar,
  }) async {
    if (user == null) {
      errorMessage = 'Nenhum usuário logado.';
      notifyListeners();
      return;
    }
    
    await _run(
      () async {
        await repository.updateUser(
          userId: user!.id,
          name: name,
          sex: sex,
          avatar: avatar,
        );
        // Atualiza o usuário local
        user = await repository.getCurrentProfile();
      },
      'Não foi possível atualizar o usuário.'
    );
  }

  Future<void> deleteUser() async {
    if (user == null) {
      errorMessage = 'Nenhum usuário logado.';
      notifyListeners();
      return;
    }
    
    await _run(
      () async {
        await repository.deleteUser(user!.id);
        user = null;
      },
      'Não foi possível deletar o usuário.'
    );
  }

  Future<void> _run(Future<void> Function() action, String fallbackMessage) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      await action();
    } catch (e) {
      errorMessage = fallbackMessage;
      print('❌ Erro: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
