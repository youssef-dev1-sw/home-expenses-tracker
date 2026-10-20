
class Expensesmodel {
  final int? id;
  final String category;
  final String note;
  final String date;
  final double amount;

  Expensesmodel({
    this.id,
    required this.category,
    required this.note,
    required this.date,
    required this.amount,
  });

  factory Expensesmodel.fromMap(Map<String, dynamic> map) {
    return Expensesmodel(
      id: map["id"] as int?,
      category: map["category"],
      note: map["note"],
      date: map["date"],
      amount: (map["amount"] as num).toDouble(),
    );
  }

  static List<Expensesmodel> fromMapList(
    List<Map<String, Object?>> mapList,
  ) {
    return mapList.map((e) => Expensesmodel.fromMap(e)).toList();
  }
}
