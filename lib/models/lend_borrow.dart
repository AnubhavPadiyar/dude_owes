class LendBorrow {
  final int? id;
  final String personName;
  final String type; // 'lent' or 'borrowed'
  final double amount;
  double remainingAmount;
  final String date;
  final String note;
  bool isSettled;

  LendBorrow({
    this.id,
    required this.personName,
    required this.type,
    required this.amount,
    required this.remainingAmount,
    required this.date,
    required this.note,
    required this.isSettled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'type': type,
      'amount': amount,
      'remainingAmount': remainingAmount,
      'date': date,
      'note': note,
      'isSettled': isSettled ? 1 : 0,
    };
  }

  factory LendBorrow.fromMap(Map<String, dynamic> map) {
    return LendBorrow(
      id: map['id'],
      personName: map['personName'],
      type: map['type'],
      amount: map['amount'],
      remainingAmount: map['remainingAmount'],
      date: map['date'],
      note: map['note'],
      isSettled: map['isSettled'] == 1,
    );
  }
}