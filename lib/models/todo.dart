enum TaskCategory { todo, workout, event }

class Task {
  String id;
  String title;
  TaskCategory category;
  DateTime time;
  String notes;
  bool isDone;

  Task({
    this.id = '',
    required this.title,
    required this.category,
    required this.time,
    this.notes = '',
    this.isDone = false,
  });

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category.name, // Save enum as string
      'time': time.toIso8601String(), // Save DateTime as string
      'notes': notes,
      'isDone': isDone,
    };
  }

  // Convert Firestore Map to Task
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.todo,
      ),
      time: DateTime.parse(map['time']),
      notes: map['notes'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}
