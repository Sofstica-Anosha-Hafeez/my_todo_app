import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import '../widgets/add_todo_bar.dart';
import '../widgets/edit_todo_dialog.dart';
import '../widgets/todo_tile.dart';

/// The main screen: add, complete, edit and delete tasks.
class TodoScreen extends StatefulWidget {
  const TodoScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final TodoService _todoService = TodoService(widget.user.uid);

  /// Runs a database action and shows a message if it fails.
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Something went wrong.')),
      );
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final newTitle = await showEditTodoDialog(context, todo.title);
    if (newTitle == null || newTitle.isEmpty || newTitle == todo.title) return;
    await _run(() => _todoService.updateTitle(todo.id, newTitle));
  }

  @override
  Widget build(BuildContext context) {
    // Only show the email on wider screens (phones are too narrow).
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        actions: [
          if (isWide) Center(child: Text(widget.user.email ?? '')),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: widget.authService.signOut,
          ),
        ],
      ),
      body: Center(
        // Keeps the list readable on tablets, desktops and the web.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              AddTodoBar(onAdd: (title) => _run(() => _todoService.add(title))),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<Todo>>(
      stream: _todoService.watchTodos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load your tasks.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final todos = snapshot.data!;
        if (todos.isEmpty) {
          return const Center(child: Text('No tasks yet. Add one above!'));
        }

        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return TodoTile(
              key: ValueKey(todo.id),
              todo: todo,
              onToggle: (value) => _run(
                () => _todoService.setDone(todo.id, value),
              ),
              onEdit: () => _editTodo(todo),
              onDelete: () => _run(() => _todoService.delete(todo.id)),
            );
          },
        );
      },
    );
  }
}
