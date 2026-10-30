import 'package:flutter/material.dart';

import '../utils/validators.dart';

// CHANGE (NEW FILE): a small pop-up that asks for the email address
// so we can send a "reset your password" link.
// It follows the same style as edit_todo_dialog.dart.

/// Opens the pop-up. Returns the email the user typed,
/// or null if the user pressed Cancel.
Future<String?> showForgotPasswordDialog(
  BuildContext context,
  String initialEmail,
) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ForgotPasswordDialog(initialEmail: initialEmail),
  );
}

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  /// Whatever the user already typed on the sign-in screen (saves typing).
  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialEmail);

  void _send() {
    // Check the email is valid first. If not, the error shows in the field.
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email and we will send you a link to reset '
              'your password.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: Validators.email,
              onFieldSubmitted: (_) => _send(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _send, child: const Text('Send link')),
      ],
    );
  }
}
