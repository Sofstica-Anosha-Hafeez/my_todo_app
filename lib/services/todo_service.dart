import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/todo.dart';

/// All database work for to-dos lives here (Create, Read, Update, Delete).
///
/// Data path in Firestore:  users / {uid} / todos / {todoId}
/// Each user therefore only ever touches their own tasks.
class TodoService {
  TodoService(this.uid);

  final String uid;

  CollectionReference<Map<String, dynamic>> get _todos => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('todos');

  /// READ: a live list that updates automatically when data changes.
  Stream<List<Todo>> watchTodos() {
    return _todos
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Todo.fromFirestore).toList());
  }

  /// CREATE
  Future<void> add(String title) {
    return _todos.add({
      'title': title,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// UPDATE the text of a task.
  Future<void> updateTitle(String id, String title) {
    return _todos.doc(id).update({'title': title});
  }

  /// UPDATE the completed checkbox.
  Future<void> setDone(String id, bool isDone) {
    return _todos.doc(id).update({'isDone': isDone});
  }

  /// DELETE
  Future<void> delete(String id) => _todos.doc(id).delete();
}
