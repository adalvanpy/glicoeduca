import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../controllers/profile_controller.dart';
import '../repositories/profile_repository.dart';

class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  final _name = TextEditingController();
  late final ProfileController _controller = ProfileController(repository: ProfileRepository());
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';
  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.loadProfile(_userId);
  }

  void _refresh() {
    if (!mounted) return;
    if (_name.text.isEmpty && _controller.profile != null) {
      setState(() => _name.text = _controller.profile!.name);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar nome')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Como devemos chamar você?', style: TextStyles.pageTitle),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _controller.isLoading ? null : _save,
              child: Text(_controller.isLoading ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await _controller.updateName(_userId, _name.text);
    if (!mounted) return;
    if (_controller.errorMessage == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage!)),
      );
    }
  }
}
