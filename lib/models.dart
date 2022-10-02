class Task {
  final String title;
  final bool completed;
  final int minuteToFinish;
  final int minuteDone;

  Task({
    required this.title,
    required this.completed,
    required this.minuteToFinish,
    this.minuteDone = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      minuteToFinish: json['minuteToFinish'],
      minuteDone: json['minuteDone'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
      'minuteToFinish': minuteToFinish,
      'minuteDone': minuteDone,
    };
  }
}
