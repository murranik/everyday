class AlarmData {
  int ?id;
  String label;
  String ?dateTime;
  String ?rangeOfDateForRepeat; //(pn/vt/sr/cht/pt/sb/nd)
  int ?isRepeat;
  int ?isActive;

  AlarmData({
    this.id,
    required this.label,
    this.dateTime,
    this.rangeOfDateForRepeat,
    this.isRepeat,
    this.isActive,
  });

  factory AlarmData.fromMap(Map<String, dynamic> json) => AlarmData(
    id: json['id'],
    label: json['label'],
    dateTime: json['dateTime'],
    rangeOfDateForRepeat: json['rangeOfDateForRepeat'],
    isRepeat: json['isRepeat'],
    isActive: json['isActive'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'dateTime': dateTime,
    'rangeOfDateForRepeat': rangeOfDateForRepeat,
    'isRepeat': isRepeat,
    'isActive': isActive,
  };
}