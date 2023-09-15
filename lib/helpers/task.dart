class Task {
  final int? id;
  final String subject;
  final String date;
  final String time;
  bool? completed;

  Task({
    this.id,
    required this.subject,
    required this.date,
    required this.time,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'date': date,
      'time': time,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'subject': subject,
      'date': date,
      'time': time, // Use your formatting method here
    };
  }
}
