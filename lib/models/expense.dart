class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final String note;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  // Convert Expense to Map (for saving to database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  // Convert Map to Expense (for reading from database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      note: map['note'],
    );
  }
}