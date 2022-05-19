class AlarmData {
  int? id;
  String label;
  String? dateTime;
  int? isRepeat;
  int? isActive;

  AlarmData({
    this.id,
    required this.label,
    this.dateTime,
    this.isRepeat,
    this.isActive,
  });

  factory AlarmData.fromMap(Map<String, dynamic> json) => AlarmData(
        id: json['id'],
        label: json['label'],
        dateTime: json['dateTime'],
        isRepeat: json['isRepeat'],
        isActive: json['isActive'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'dateTime': dateTime,
        'isRepeat': isRepeat,
        'isActive': isActive,
      };
}
