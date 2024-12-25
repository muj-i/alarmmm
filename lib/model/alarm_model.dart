class AlarmModel {
  String title;
  String time;
  bool isEnable;
  String alarmTone;
  // bool isCompleted;

  AlarmModel(
      {required this.title,
      required this.time,
      required this.isEnable,
      required this.alarmTone});

  // Convert AlarmModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
      'isEnable': isEnable,
      'alarmTone': alarmTone,
      // 'isCompleted': isCompleted,
    };
  }

  // Create AlarmModel from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      title: json['title'],
      time: json['time'],
      isEnable: json['isEnable'],
      alarmTone: json['alarmTone'],
      // isCompleted: json['isCompleted'],
    );
  }

  @override
  String toString() {
    return 'AlarmModel(title: $title, time: $time, isEnable: $isEnable, alarmTone: $alarmTone)';
  }
}
