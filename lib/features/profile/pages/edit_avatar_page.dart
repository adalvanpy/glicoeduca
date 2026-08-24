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

  /// Inicializa a página na ordem correta:
  ///
  /// 1. Carrega o perfil
  /// 2. Obtém o sexo
  /// 3. Obtém o avatar atual
  /// 4. Carrega os avatares filtrados
  Future<void> _initialize() async {
    if (_userId.isEmpty) {
      debugPrint('❌ Usuário não autenticado.');
      return;
    }

    try {
      await _controller.loadProfile(_userId);

      if (!mounted) return;

      setState(() {
        _userSex = _controller.profile?.sex ?? '';
        _selectedAvatarId = _controller.profile?.avatar;
      });

      await _loadAvatars();
    } catch (e) {
      debugPrint('❌ Erro ao inicializar página de avatar: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingAvatars = false;
      });
    }
  }

  /// Atualiza os dados da tela quando o controller muda.
  void _refresh() {
    if (!mounted) return;

    setState(() {
      _userSex = _controller.profile?.sex ?? '';
      _selectedAvatarId = _controller.profile?.avatar;
    });
  }

  /// Carrega os avatares.
  ///
  /// Se o usuário tiver sexo definido, busca somente
  /// os avatares correspondentes.
  Future<void> _loadAvatars() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAvatars = true;
    });

    try {
      List<AvatarModel> avatars;

      if (_userSex.isNotEmpty) {
        avatars = await _avatarRepo.getAvatarsBySex(_userSex);

        debugPrint(
          '👤 Sexo do usuário: $_userSex',
        );

        debugPrint(
          '🧑 Avatares encontrados para $_userSex: ${avatars.length}',
        );
      } else {
        avatars = await _avatarRepo.getAvatars();

        debugPrint(
          '⚠️ Sexo do usuário não definido. Carregando todos os avatares.',
        );

        debugPrint(
          '🧑 Total de avatares: ${avatars.length}',
        );
      }

      if (!mounted) return;

      setState(() {
        _avatars = avatars;
        _isLoadingAvatars = false;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar avatares: $e');

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
            // ============================================================
            // PRÉ-VISUALIZAÇÃO
            // ============================================================
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

            // ============================================================
            // TEXTO
            // ============================================================
            Text(
              _userSex.isNotEmpty
                  ? 'Selecione um avatar para seu perfil ($_userSex)'
                  : 'Selecione um avatar para seu perfil',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            // ============================================================
            // INDICADOR DE FILTRO
            // ============================================================
            if (_userSex.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Filtrando avatares para: $_userSex',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ============================================================
            // GRID DE AVATARES
            // ============================================================
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

            // ============================================================
            // BOTÃO SALVAR
            // ============================================================
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

  // ==============================================================
  // OBTÉM A IMAGEM DO AVATAR SELECIONADO
  // ==============================================================
  ImageProvider? _getAvatarImage(String? avatarId) {
    // Proteção contra lista vazia.
    if (_avatars.isEmpty) {
      return null;
    }

    // Proteção contra ID nulo.
    if (avatarId == null || avatarId.isEmpty) {
      return null;
    }

    final index = _avatars.indexWhere(
      (avatar) => avatar.id == avatarId,
    );

    // Avatar não encontrado.
    if (index == -1) {
      return null;
    }

    final avatar = _avatars[index];

    // Verifica se existe URL válida.
    if (avatar.image.startsWith('http')) {
      return NetworkImage(avatar.image);
    }

    return null;
  }

  // ==============================================================
  // SALVAR AVATAR
  // ==============================================================
  Future<void> _save() async {
    if (_selectedAvatarId == null) {
      return;
    }

    if (_userId.isEmpty) {
      return;
    }

    try {
      await _controller.updateAvatar(
        _userId,
        _selectedAvatarId!,
      );

      if (!mounted) return;

      if (_controller.errorMessage == null) {
        await _controller.loadProfile(_userId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Avatar atualizado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.errorMessage!,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        '❌ Erro ao salvar avatar: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar avatar: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}