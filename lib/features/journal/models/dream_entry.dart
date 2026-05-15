class DreamEntry {
  const DreamEntry({
    this.id,
    required this.title,
    required this.description,
    required this.mood,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final String mood;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DreamEntry.fromMap(Map<String, Object?> map) {
    return DreamEntry(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      mood: map['mood'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
