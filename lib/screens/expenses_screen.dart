import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';
import '../main.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> _expenses = [];
  double _monthlyTotal = 0.0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food',    'icon': Icons.restaurant_outlined,  'color': const Color(0xFF4CAF82), 'bg': const Color(0xFFE8F5EE)},
    {'name': 'Travel',  'icon': Icons.directions_bus_outlined,'color': const Color(0xFF42A5F5),'bg': const Color(0xFFE3F2FD)},
    {'name': 'Clothes', 'icon': Icons.checkroom_outlined,   'color': AppColors.lavender,     'bg': AppColors.lavenderLight},
    {'name': 'Grocery', 'icon': Icons.shopping_basket_outlined,'color': AppColors.pink,    'bg': AppColors.pinkLight},
    {'name': 'Fun',     'icon': Icons.sports_esports_outlined,'color': const Color(0xFFE57373),'bg': const Color(0xFFFDEDED)},
    {'name': 'Other',   'icon': Icons.category_outlined,    'color': AppColors.grey,         'bg': AppColors.greyLight},
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await DBHelper.getExpenses();
    final total = await DBHelper.getMonthlyTotal();
    setState(() {
      _expenses = expenses;
      _monthlyTotal = total;
    });
  }

  Map<String, dynamic> _getCategoryData(String category) {
    return _categories.firstWhere((c) => c['name'] == category,
        orElse: () => _categories.last);
  }

  // ✅ NEW HELPER METHOD
  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final expense in _expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    final sorted = Map.fromEntries(
      totals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sorted;
  }

  void _showAddExpenseSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = 'Food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add Expense', style: AppText.h2),
              const SizedBox(height: 20),

              _InputField(controller: titleController, label: 'What did you spend on?', icon: Icons.edit_outlined),
              const SizedBox(height: 14),
              _InputField(controller: amountController, label: 'Amount', icon: Icons.currency_rupee, keyboardType: TextInputType.number, prefix: '₹ '),
              const SizedBox(height: 14),

              Text('Category', style: AppText.label),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = cat['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? cat['color'] : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'] as IconData,
                              size: 14,
                              color: isSelected ? Colors.white : AppColors.grey),
                          const SizedBox(width: 6),
                          Text(cat['name'],
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.grey)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _InputField(controller: noteController, label: 'Note (optional)', icon: Icons.note_outlined),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (titleController.text.isEmpty || amountController.text.isEmpty) return;
                    final expense = Expense(
                      title: titleController.text,
                      amount: double.parse(amountController.text),
                      category: selectedCategory,
                      date: DateTime.now().toIso8601String(),
                      note: noteController.text,
                    );
                    await DBHelper.insertExpense(expense);
                    Navigator.pop(context);
                    _loadExpenses();
                  },
                  child: const Text('Save Expense',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Expenses', style: AppText.h1),
                  const SizedBox(height: 4),
                  Text('Track every rupee you spend', style: AppText.body),
                  const SizedBox(height: 20),

                  // Monthly total card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('This Month', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('₹${_monthlyTotal.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),

                  // ✅ CHART SECTION
                  if (_expenses.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Spending by Category', style: AppText.h2),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 35,
                                sections: _getCategoryTotals().entries.map((entry) {
                                  final catData = _getCategoryData(entry.key);
                                  return PieChartSectionData(
                                    color: catData['color'] as Color,
                                    value: entry.value,
                                    title: '',
                                    radius: 40,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _getCategoryTotals().entries.map((entry) {
                                final catData = _getCategoryData(entry.key);
                                final percent = (_monthlyTotal > 0)
                                    ? (entry.value / _monthlyTotal * 100).toStringAsFixed(0)
                                    : '0';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: catData['color'] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(entry.key,
                                            style: AppText.label.copyWith(fontSize: 12)),
                                      ),
                                      Text('$percent%',
                                          style: AppText.h3.copyWith(
                                              fontSize: 12,
                                              color: catData['color'] as Color)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Text('All Expenses', style: AppText.h2),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            Expanded(
              child: _expenses.isEmpty
                  ? Center(
                      child: Text('No expenses yet', style: AppText.h3),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        final catData = _getCategoryData(expense.category);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(
                                  color: catData['bg'] as Color,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(catData['icon'] as IconData,
                                    color: catData['color'] as Color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(expense.title, style: AppText.h3),
                                    const SizedBox(height: 2),
                                    Text(expense.category, style: AppText.label),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${expense.amount.toStringAsFixed(0)}',
                                      style: AppText.h3.copyWith(color: AppColors.primary)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      await DBHelper.deleteExpense(expense.id!);
                                      _loadExpenses();
                                    },
                                    child: Text('Remove',
                                        style: AppText.label.copyWith(color: AppColors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 4,
        onPressed: _showAddExpenseSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}