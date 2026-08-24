import 'package:flutter/foundation.dart';

import '../../auth/models/user_model.dart';
import '../repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileController({required this.repository});

  UserModel? profile;
  bool isLoading = false;
  String? errorMessage;

  bool get hasProfile => profile != null;

  Future<void> loadProfile(String userId) async {
    isLoading = true;
    profile = null;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.getProfile(userId);

      if (profile == null) {
        errorMessage = 'Perfil não encontrado.';
      }
    } catch (_) {
      errorMessage = 'Não foi possível carregar o perfil.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String userId, String name) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      errorMessage = 'Informe um nome válido.';
      notifyListeners();
      return;
    }

    await _update(
      action: () => repository.updateName(userId, normalizedName),
      userId: userId,
    );
  }

  Future<void> updateAvatar(String userId, String avatar) async {
    final normalizedAvatar = avatar.trim();
    if (normalizedAvatar.isEmpty) {
      errorMessage = 'Selecione um avatar válido.';
      notifyListeners();
      return;
    }

    await _update(
      action: () => repository.updateAvatar(userId, normalizedAvatar),
      userId: userId,
    );
  }

  Future<void> _update({
    required Future<void> Function() action,
    required String userId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      await _reloadAfterUpdate(userId);
    } catch (_) {
      errorMessage = 'Não foi possível atualizar o perfil.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reloadAfterUpdate(String userId) async {
    final updatedProfile = await repository.getProfile(userId);
    if (updatedProfile != null) {
      profile = updatedProfile;
    }
  }
}
