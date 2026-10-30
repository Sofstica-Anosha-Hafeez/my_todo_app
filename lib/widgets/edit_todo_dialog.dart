import 'package:flutter/material.dart';

/// Opens a small pop-up to rename a task.
/// Returns the new text, or null if the user cancelled.
Future<String?> showEditTodoDialog(BuildContext context, String currentTitle) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditTodoDialog(initialTitle: currentTitle),
  );
}

class _EditTodoDialog extends StatefulWidget {
  const _EditTodoDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<_EditTodoDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialTitle);

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
