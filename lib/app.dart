import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';
import 'services/auth_service.dart';

/// The root of the app: sets the theme and decides the first screen.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const AuthGate(authService: AuthService()),
    );
  }
}
