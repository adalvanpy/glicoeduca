import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 ESPERA O FIREBASE AUTH RESTAURAR A SESSÃO
  await Future.delayed(const Duration(seconds: 1));

  // 🔥 VERIFICA SE HÁ USUÁRIO LOGADO
  final user = FirebaseAuth.instance.currentUser;
  print('🔍 MAIN - Usuário logado: ${user?.uid}');
  print('🔍 MAIN - Email: ${user?.email}');
  
  if (user != null) {
    print('✅ MAIN - Usuário está logado!');
  } else {
    print('❌ MAIN - Nenhum usuário logado!');
  }

  runApp(const GlicoEducaApp());
}

class GlicoEducaApp extends StatelessWidget {
  const GlicoEducaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlicoEduca',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

