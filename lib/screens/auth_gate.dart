import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'todo_screen.dart';

/// Shows the sign-in screen or the to-do screen depending on login state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return SignInScreen(authService: authService);
        }

        // The key makes sure a different user gets a fresh screen.
        return TodoScreen(
          key: ValueKey(user.uid),
          user: user,
          authService: authService,
        );
      },
    );
  }
}
