import 'package:cloud_firestore/cloud_firestore.dart';

/// The blueprint for one to-do item.
///
/// `id` is the document id Firestore gives us, so we can update or delete it.
class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.isDone,
  });

  final String id;
  final String title;
  final bool isDone;

  /// Turns a Firestore document into a [Todo] object.
  factory Todo.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Todo(
      id: doc.id,
      title: data['title'] as String? ?? '',
      isDone: data['isDone'] as bool? ?? false,
    );
  }
}
