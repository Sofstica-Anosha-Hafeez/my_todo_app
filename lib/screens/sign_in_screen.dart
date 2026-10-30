import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart'; // CHANGE: our new validation rules.
import '../widgets/forgot_password_dialog.dart'; // CHANGE: reset pop-up.

/// Email + password screen. Can switch between "Sign in" and "Create account".
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false; // false = sign in, true = create account
  bool _isLoading = false;
  // CHANGE: true = password is hidden (dots), false = password is visible.
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isRegistering) {
        await widget.authService.register(email, password);
      } else {
        await widget.authService.signIn(email, password);
      }
      // On success AuthGate automatically swaps to the to-do screen.
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// CHANGE (NEW): Forgot password flow.
  /// 1) open the pop-up and ask for the email
  /// 2) ask Firebase to send the reset link
  /// 3) tell the user what happened with a small message (SnackBar)
  Future<void> _forgotPassword() async {
    final email = await showForgotPasswordDialog(
      context,
      _emailController.text.trim(), // pre-fill what they already typed
    );
    // User pressed Cancel (or tapped outside the pop-up).
    if (email == null) return;

    setState(() => _isLoading = true);

    String message;
    try {
      await widget.authService.sendPasswordReset(email);
      message = 'If an account exists for $email, a reset link has been '
          'sent. Please check your inbox (and spam folder).';
    } on AuthException catch (e) {
      message = e.message;
    }

    // After an `await`, the screen might be gone. Always check `mounted`.
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            // Keeps the form a nice width on big screens.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      _isRegistering ? 'Create account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      // CHANGE: uses the shared, stricter email rule.
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      // CHANGE: hide or show the text based on the variable.
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        // CHANGE: hint about the rules, only when registering.
                        helperText: _isRegistering
                            ? '8+ characters with uppercase, lowercase, '
                                'number and special character'
                            : null,
                        helperMaxLines: 2,
                        // CHANGE: the eye button on the right side.
                        suffixIcon: IconButton(
                          // Eye with a slash = "password is hidden",
                          // open eye = "password is visible".
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          // Flip true <-> false and redraw the screen.
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      onFieldSubmitted: (_) => _submit(),
                      // CHANGE: strong rules when creating an account,
                      // only "not empty" when signing in.
                      validator: _isRegistering
                          ? Validators.newPassword
                          : Validators.loginPassword,
                    ),
                    // CHANGE (NEW): "Forgot password?" link, shown only on
                    // the sign-in screen (not needed when registering).
                    if (!_isRegistering)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegistering ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _isRegistering = !_isRegistering;
                                _errorMessage = null;
                              }),
                      child: Text(
                        _isRegistering
                            ? 'I already have an account'
                            : 'Create a new account',
                      ),
                    ),
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