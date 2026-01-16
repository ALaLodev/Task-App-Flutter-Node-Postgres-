class Task {
  final String id;
  final String title;
  final String description;
  final String hexColor;
  final String uid;
  final DateTime updatedAt;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.hexColor,
    required this.uid,
    required this.updatedAt,
    required this.createdAt,
  });
}
