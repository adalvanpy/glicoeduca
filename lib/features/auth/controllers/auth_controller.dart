import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AuthController({required this.repository}) {

    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {

        loadCurrentUser();
      } else {

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
          return;
        }

        user = result;
      },
      'Nome de usuário não encontrado.',
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
      user = await repository.getCurrentProfile();
      if (user == null) {
        errorMessage = 'Nenhum usuário logado.';
      }
    } catch (_) {
      errorMessage = 'Não foi possível carregar o usuário atual.';
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await repository.signOut();
    user = null;
    errorMessage = null;
    notifyListeners();

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

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

