class MoodEntry {
  final int? id;
  final int moodIndex; // 0 to 4
  final String date; // YYYY-MM-DD
  final String activities; // Comma separated
  final String notes;

  MoodEntry({
    this.id,
    required this.moodIndex,
    required this.date,
    required this.activities,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moodIndex': moodIndex,
      'date': date,
      'activities': activities,
      'notes': notes,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      moodIndex: map['moodIndex'],
      date: map['date'],
      activities: map['activities'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  MoodEntry copyWith({
    int? id,
    int? moodIndex,
    String? date,
    String? activities,
    String? notes,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      moodIndex: moodIndex ?? this.moodIndex,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
    );
  }
}
