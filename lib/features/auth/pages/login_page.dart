
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  late final AuthController _controller = AuthController(repository: AuthRepository());

  @override
  void dispose() {
    _usernameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await _controller.signIn(_usernameController.text);

    if (!mounted) return;

    if (_controller.errorMessage == null && _controller.user != null) {
      // 🔥 VERIFICA O JWT
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      print('🔑 JWT gerado: ${token?.substring(0, 30)}...');

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.homePage);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Erro ao fazer login'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Digite seu nome de usuário para entrar',
              style: TextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Nome de usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe seu nome de usuário';
                }
                if (value.trim().length < 3) {
                  return 'Nome deve ter pelo menos 3 caracteres';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => ElevatedButton(
                onPressed: _controller.isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_controller.isLoading ? 'Entrando...' : 'Entrar'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  const Text('Não tem uma conta? ', style: TextStyles.bodySmall),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.createUser),
                    child: const Text(
                      'Criar usuário',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthShell extends StatelessWidget {
  final Widget child;
  const _AuthShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Glico', style: TextStyles.logoRed),
                        Text('Educa', style: TextStyles.logoGreen),
                      ],
                    ),
                    const SizedBox(height: 30),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}