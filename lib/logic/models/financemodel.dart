class FinanceModel {
  int ?id;
  String ?label;
  double price;
  int isIncome;

  FinanceModel({
    this.id,
    this.label,
    required this.price,
    required this.isIncome,
  });

  factory FinanceModel.fromMap(Map<String, dynamic> json) => FinanceModel(
    id: json['id'],
    label: json['label'],
    price: json['price'],
    isIncome: json['isIncome'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'price': price,
    'isIncome': isIncome,
  };
}