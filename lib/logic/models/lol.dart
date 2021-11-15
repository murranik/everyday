class Lol {
  int ?id;
  String label;
  String ?date;
  String ?place;

  Lol({
    this.id,
    required this.label,
    this.date,
    this.place,

  });

  factory Lol.fromMap(Map<String, dynamic> json) => Lol(
    id: json['id'],
    label: json['label'],
    date: json['date'],
    place: json['place'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'date': date,
    'place': place,
  };
}