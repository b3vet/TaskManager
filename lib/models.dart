class Task {
  final String title;
  final bool completed;
  final int minuteToFinish;
  final double minuteDone;
  final bool onGoing;
  final DateTime startTime;

  const Task._internal({
    required this.title,
    required this.completed,
    required this.minuteToFinish,
    required this.startTime,
    required this.onGoing,
    required this.minuteDone,
  });

  factory Task({
    required String title,
    required bool completed,
    required int minuteToFinish,
    required DateTime startTime,
    bool? onGoing,
    double? minuteDone,
  }) {
    return Task._internal(
      title: title,
      completed: completed,
      minuteToFinish: minuteToFinish,
      startTime: startTime,
      onGoing: onGoing ?? false,
      minuteDone: minuteDone ?? 0,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      minuteToFinish: json['minuteToFinish'],
      minuteDone: json['minuteDone'],
      completed: json['completed'],
      startTime: DateTime.parse(json['startTime']),
      onGoing: json['onGoing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
      'minuteToFinish': minuteToFinish,
      'minuteDone': minuteDone,
      'startTime': startTime.toIso8601String(),
      'onGoing': onGoing,
    };
  }

  Task copyWith({
    String? title,
    bool? completed,
    int? minuteToFinish,
    double? minuteDone,
    bool? onGoing,
    DateTime? startTime,
  }) {
    return Task(
      completed: completed ?? this.completed,
      title: title ?? this.title,
      minuteToFinish: minuteToFinish ?? this.minuteToFinish,
      minuteDone: minuteDone ?? this.minuteDone,
      onGoing: onGoing ?? this.onGoing,
      startTime: startTime ?? this.startTime,
    );
  }
}
