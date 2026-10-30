import 'package:flutter/material.dart';

/// The text box + "Add" button at the top of the screen.
class AddTodoBar extends StatefulWidget {
  const AddTodoBar({super.key, required this.onAdd});

  /// Called with the new task text when the user taps Add.
  final ValueChanged<String> onAdd;

  @override
  State<AddTodoBar> createState() => _AddTodoBarState();
}

class _AddTodoBarState extends State<AddTodoBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter a new task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: _submit, child: const Text('Add')),
        ],
      ),
    );
  }
}
