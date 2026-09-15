import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../controllers/profile_controller.dart';
import '../repositories/profile_repository.dart';
import '../repositories/avatar_repository.dart';
import '../models/avatar_model.dart';

class EditAvatarPage extends StatefulWidget {
  const EditAvatarPage({super.key});

  @override
  State<EditAvatarPage> createState() => _EditAvatarPageState();
}

class _EditAvatarPageState extends State<EditAvatarPage> {
  String? _selectedAvatarId;

  List<AvatarModel> _avatars = [];

  bool _isLoadingAvatars = true;

  String _userSex = '';

  late final ProfileController _controller = ProfileController(
    repository: ProfileRepository(),
  );

  final AvatarRepository _avatarRepo = AvatarRepository();

  String get _userId =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();

    _controller.addListener(_refresh);

    _initialize();
  }

  Future<void> _initialize() async {
    if (_userId.isEmpty) return;

    try {
      await _controller.loadProfile(_userId);

      if (!mounted) return;

      _applyProfileState();
      await _loadAvatars();
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoadingAvatars = false);
    }
  }

  void _applyProfileState() {
    setState(() {
      _userSex = _controller.profile?.sex ?? '';
      _selectedAvatarId = _controller.profile?.avatar;
    });
  }

  void _refresh() {
    if (!mounted) return;

    _applyProfileState();
  }

  Future<void> _loadAvatars() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAvatars = true;
    });

    try {
      List<AvatarModel> avatars;

      if (_userSex.isNotEmpty) {
        avatars = await _avatarRepo.getAvatarsBySex(_userSex);
      } else {
        avatars = await _avatarRepo.getAvatars();
      }

      if (!mounted) return;

      setState(() {
        _avatars = avatars;
        _isLoadingAvatars = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _avatars = [];
        _isLoadingAvatars = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu avatar'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'Pré-visualização',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,

                      backgroundImage:
                          _getAvatarImage(_selectedAvatarId),

                      child: _selectedAvatarId == null ||
                              _getAvatarImage(_selectedAvatarId) == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Selecione um avatar para seu perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _isLoadingAvatars
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _avatars.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum avatar disponível para seu sexo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : GridView.builder(
                          itemCount: _avatars.length,

                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                          ),

                          itemBuilder: (_, index) {
                            final avatar = _avatars[index];

                            final isSelected =
                                _selectedAvatarId == avatar.id;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAvatarId = avatar.id;
                                });
                              },

                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),

                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),

                                child: CircleAvatar(
                                  radius: 40,

                                  backgroundColor: isSelected
                                      ? const Color(0xFFE3F2FD)
                                      : Colors.grey.shade100,

                                  child: ClipOval(
                                    child: avatar.image.startsWith('http')
                                        ? Image.network(
                                            avatar.image,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,

                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }

                                                  return const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  );
                                                },

                                            errorBuilder:
                                                (_, __, ___) {
                                              return const Icon(
                                                Icons.person,
                                                size: 38,
                                                color: Colors.grey,
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 38,
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _controller.isLoading ||
                            _selectedAvatarId == null
                        ? null
                        : _save,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: Text(
                  _controller.isLoading
                      ? 'Salvando...'
                      : 'Salvar avatar',

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage(String? avatarId) {

    if (_avatars.isEmpty) {
      return null;
    }

    if (avatarId == null || avatarId.isEmpty) {
      return null;
    }

    final index = _avatars.indexWhere(
      (avatar) => avatar.id == avatarId,
    );

    if (index == -1) {
      return null;
    }

    final avatar = _avatars[index];

    if (avatar.image.startsWith('http')) {
      return NetworkImage(avatar.image);
    }

    return null;
  }

  Future<void> _save() async {
    if (_selectedAvatarId == null || _userId.isEmpty) {
      return;
    }

    try {
      await _controller.updateAvatar(_userId, _selectedAvatarId!);

      if (!mounted) return;

      if (_controller.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _controller.loadProfile(_userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar avatar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
