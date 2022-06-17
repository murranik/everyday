class FinanceModel {
  int? id;
  String? label;
  double price;
  int isIncome;
  int? eventId;

  FinanceModel({
    this.id,
    this.label,
    required this.price,
    required this.isIncome,
    this.eventId,
  });

  factory FinanceModel.fromMap(Map<String, dynamic> json) => FinanceModel(
        id: json['id'],
        label: json['label'],
        price: json['price'],
        isIncome: json['isIncome'],
        eventId: json['eventId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'price': price,
        'isIncome': isIncome,
        'eventId': eventId,
      };
}
