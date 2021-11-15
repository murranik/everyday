class Event {
  int ?id;
  String label;
  String ?text;
  String ?startDate;
  String ?endDate;
  String ?calendarColor;

  Event({
    this.id,
    required this.label,
    this.text,
    this.startDate,
    this.endDate,
    this.calendarColor,
  });

  factory Event.fromMap(Map<String, dynamic> json) => Event(
    id: json['id'],
    label: json['label'],
    text: json['text'],
    startDate: json['startDate'],
    endDate: json['endDate'],
    calendarColor: json['calendarColor'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'text': text,
    'startDate': startDate,
    'endDate': endDate,
    'calendarColor': calendarColor,
  };
}