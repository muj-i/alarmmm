class AlarmModel {
  String title;
  String time;
  bool isEnable;
  // bool isCompleted;

  AlarmModel({required this.title, required this.time, required this.isEnable});

  // Convert AlarmModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time,
      'isEnable': isEnable,
      // 'isCompleted': isCompleted,
    };
  }

  // Create AlarmModel from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      title: json['title'],
      time: json['time'],
      isEnable: json['isEnable'],
      // isCompleted: json['isCompleted'],
    );
  }

  @override
  String toString() {
    return 'AlarmModel(title: $title, time: $time, isEnable: $isEnable)';
  }
}
