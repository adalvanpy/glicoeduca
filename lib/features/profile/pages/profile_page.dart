import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../auth/repositories/auth_repository.dart';
import '../controllers/profile_controller.dart';
import '../repositories/profile_repository.dart';
import '../repositories/avatar_repository.dart';
import '../models/avatar_model.dart';

class ProfilePage extends StatefulWidget {
  final ProfileController? controller;
  const ProfilePage({super.key, this.controller});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;
  late final bool _ownsController;
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  AvatarModel? _userAvatar;
  bool _isLoadingAvatar = true;

  final AvatarRepository _avatarRepo = AvatarRepository();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ProfileController(repository: ProfileRepository());
    _controller.addListener(_refresh);
    if (_userId.isNotEmpty) {
      _controller.loadProfile(_userId);
    }
  }

  void _refresh() { 
    if (mounted) {
      setState(() {});
      _loadUserAvatar();
    }
  }

  Future<void> _loadUserAvatar() async {
    final avatarId = _controller.profile?.avatar;
    if (avatarId == null || avatarId.isEmpty) {
      setState(() => _isLoadingAvatar = false);
      return;
    }

    setState(() => _isLoadingAvatar = true);
    try {
      _userAvatar = await _avatarRepo.getAvatarById(avatarId);
      debugPrint('📋 Avatar carregado: ${_userAvatar?.image}');
    } catch (e) {
      debugPrint('❌ Erro ao carregar avatar: $e');
    } finally {
      setState(() => _isLoadingAvatar = false);
    }
  }

  @override
  void dispose() { 
    _controller.removeListener(_refresh); 
    if (_ownsController) _controller.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    final profile = _controller.profile;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _controller.isLoading && profile == null 
                ? const Center(child: CircularProgressIndicator()) 
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 12), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, 
                      children: [
                        const Row(
                          children: [
                            Text('Glico', style: TextStyles.logoRed), 
                            Text('Educa', style: TextStyles.logoGreen),
                          ],
                        ), 
                        const SizedBox(height: 38),
                        // 🔥 AVATAR IGUAL À PRÉ-VISUALIZAÇÃO - SEM AMPLIAÇÃO
                        Center(
                          child: ClipOval(
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: _userAvatar?.image != null && _userAvatar!.image.isNotEmpty
                                  ? Image.network(
                                      _userAvatar!.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), 
                        Center(
                          child: Text(
                            profile?.name.isNotEmpty == true ? profile!.name : 'Seu perfil', 
                            style: TextStyles.pageTitle,
                          ),
                        ), 
                        const SizedBox(height: 4), 
                        const Center(
                          child: Text('Aluno GlicoEduca', style: TextStyles.description),
                        ), 
                        const SizedBox(height: 28),
                        _item(context, Icons.edit_outlined, 'Editar nome', AppRoutes.editName), 
                        _item(context, Icons.face_outlined, 'Alterar avatar', AppRoutes.editAvatar),  
                        _item(context, Icons.logout, 'Sair', null, onTap: _logout),
                        if (_controller.errorMessage != null) 
                          Padding(
                            padding: const EdgeInsets.only(top: 12), 
                            child: Text(
                              _controller.errorMessage!, 
                              textAlign: TextAlign.center, 
                              style: const TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                      ],
                    ),
                  ),
            ), 
            AppBottomNavigation(
              currentIndex: 4, 
              onItemSelected: (index) { 
                if (index == 1){
                  Navigator.pushReplacementNamed(context, AppRoutes.theory);
                } else if(index == 0) {
                  Navigator.pushReplacementNamed(context, AppRoutes.homePage); 
                } else if(index == 2){
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsDuel); 
                } else if(index == 3){
                  Navigator.pushReplacementNamed(context, AppRoutes.instructionsQuiz); 
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String? route, {VoidCallback? onTap}) => 
    Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor), 
        title: Text(title, style: TextStyles.bodyMedium), 
        trailing: const Icon(Icons.chevron_right), 
        onTap: onTap ?? (route == null ? null : () => Navigator.pushNamed(context, route)),
      ),
    );

  Future<void> _logout() async { 
    await AuthRepository().signOut(); 
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false); 
  }
}
