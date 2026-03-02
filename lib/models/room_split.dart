class SplitGroup {
  final int? id;
  final String name;
  final List<String> members;
  final List<SplitExpense> expenses;
  final bool isSettled;

  SplitGroup({
    this.id,
    required this.name,
    required this.members,
    required this.expenses,
    this.isSettled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'isSettled': isSettled,
    };
  }

  factory SplitGroup.fromMap(Map<String, dynamic> map) {
    return SplitGroup(
      id: map['id'],
      name: map['name'],
      members: List<String>.from(map['members']),
      expenses: (map['expenses'] as List)
          .map((e) => SplitExpense.fromMap(e))
          .toList(),
      isSettled: map['isSettled'] ?? false,
    );
  }

  // Calculate balances: who owes whom
  Map<String, double> getBalances() {
    final Map<String, double> balances = {};
    for (final member in members) {
      balances[member] = 0.0;
    }
    for (final expense in expenses) {
      final share = expense.amount / expense.splitAmong.length;
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;
      for (final member in expense.splitAmong) {
        balances[member] = (balances[member] ?? 0) - share;
      }
    }
    return balances;
  }

  double get totalAmount =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);
}

class SplitExpense {
  final int? id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitAmong;
  final String date;

  SplitExpense({
    this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'paidBy': paidBy,
      'splitAmong': splitAmong,
      'date': date,
    };
  }

  factory SplitExpense.fromMap(Map<String, dynamic> map) {
    return SplitExpense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      paidBy: map['paidBy'],
      splitAmong: List<String>.from(map['splitAmong']),
      date: map['date'],
    );
  }
}