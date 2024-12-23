class ExpenseModel {
  final int id;
  final double amount;
  final String description;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}
