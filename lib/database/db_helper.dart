import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/lend_borrow.dart';
import '../models/room_split.dart';
class DBHelper {
  static const String _expensesKey = 'expenses';

  // Get all expenses
  static Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_expensesKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Expense.fromMap(json)).toList();
  }

  // Add expense
  static Future<void> insertExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      note: expense.note,
    );
    expenses.insert(0, newExpense);
    await prefs.setString(_expensesKey, jsonEncode(
      expenses.map((e) => e.toMap()).toList()
    ));
  }

  // Get monthly total
  static Future<double> getMonthlyTotal() async {
    final expenses = await getExpenses();
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return expenses
        .where((e) => e.date.startsWith(month))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  // Delete expense
  static Future<void> deleteExpense(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await getExpenses();
    expenses.removeWhere((e) => e.id == id);
    await prefs.setString(_expensesKey, jsonEncode(
      expenses.map((e) => e.toMap()).toList()
    ));
  }
  //Lend/Borrow
static const String _lendBorrowKey = 'lend_borrow';

static Future<List<LendBorrow>> getLendBorrows() async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString(_lendBorrowKey);
  if (data == null) return [];
  final List<dynamic> jsonList = jsonDecode(data);
  return jsonList.map((json) => LendBorrow.fromMap(json)).toList();
}

static Future<void> insertLendBorrow(LendBorrow item) async {
  final prefs = await SharedPreferences.getInstance();
  final items = await getLendBorrows();
  final newItem = LendBorrow(
    id: DateTime.now().millisecondsSinceEpoch,
    personName: item.personName,
    type: item.type,
    amount: item.amount,
    remainingAmount: item.amount,
    date: item.date,
    note: item.note,
    isSettled: false,
  );
  items.insert(0, newItem);
  await prefs.setString(_lendBorrowKey, jsonEncode(
    items.map((e) => e.toMap()).toList()
  ));
}

static Future<void> updateLendBorrow(LendBorrow item) async {
  final prefs = await SharedPreferences.getInstance();
  final items = await getLendBorrows();
  final index = items.indexWhere((e) => e.id == item.id);
  if (index != -1) items[index] = item;
  await prefs.setString(_lendBorrowKey, jsonEncode(
    items.map((e) => e.toMap()).toList()
  ));
}

static Future<void> deleteLendBorrow(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final items = await getLendBorrows();
  items.removeWhere((e) => e.id == id);
  await prefs.setString(_lendBorrowKey, jsonEncode(
    items.map((e) => e.toMap()).toList()
  ));
}
// ── Room Split ──────────────────────────────────────────────────────────────
static const String _splitKey = 'split_groups';

static Future<List<SplitGroup>> getSplitGroups() async {
  final prefs = await SharedPreferences.getInstance();
  final String? data = prefs.getString(_splitKey);
  if (data == null) return [];
  final List<dynamic> jsonList = jsonDecode(data);
  return jsonList.map((json) => SplitGroup.fromMap(json)).toList();
}

static Future<void> insertSplitGroup(SplitGroup group) async {
  final prefs = await SharedPreferences.getInstance();
  final groups = await getSplitGroups();
  final newGroup = SplitGroup(
    id: DateTime.now().millisecondsSinceEpoch,
    name: group.name,
    members: group.members,
    expenses: group.expenses,
    isSettled: false,
  );
  groups.insert(0, newGroup);
  await prefs.setString(_splitKey,
      jsonEncode(groups.map((e) => e.toMap()).toList()));
}

static Future<void> updateSplitGroup(SplitGroup group) async {
  final prefs = await SharedPreferences.getInstance();
  final groups = await getSplitGroups();
  final index = groups.indexWhere((e) => e.id == group.id);
  if (index != -1) groups[index] = group;
  await prefs.setString(_splitKey,
      jsonEncode(groups.map((e) => e.toMap()).toList()));
}

static Future<void> deleteSplitGroup(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final groups = await getSplitGroups();
  groups.removeWhere((e) => e.id == id);
  await prefs.setString(_splitKey,
      jsonEncode(groups.map((e) => e.toMap()).toList()));
}
}