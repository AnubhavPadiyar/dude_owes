import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';
import '../database/db_helper.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double _totalBudget = 0.0;
  double _totalSpent = 0.0;
  Map<String, double> _plannedAmounts = {};
  Map<String, double> _spentAmounts = {};

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food',    'icon': Icons.restaurant_outlined,      'color': const Color(0xFF4CAF82), 'bg': const Color(0xFFE8F5EE)},
    {'name': 'Travel',  'icon': Icons.directions_bus_outlined,  'color': AppColors.blue,          'bg': AppColors.blueLight},
    {'name': 'Clothes', 'icon': Icons.checkroom_outlined,       'color': AppColors.lavender,      'bg': AppColors.lavenderLight},
    {'name': 'Grocery', 'icon': Icons.shopping_basket_outlined, 'color': AppColors.pink,          'bg': AppColors.pinkLight},
    {'name': 'Fun',     'icon': Icons.sports_esports_outlined,  'color': AppColors.red,           'bg': AppColors.redLight},
    {'name': 'Other',   'icon': Icons.category_outlined,        'color': AppColors.grey,          'bg': AppColors.greyLight},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await DBHelper.getExpenses();
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final Map<String, double> spent = {};
    for (final e in expenses) {
      if (e.date.startsWith(month)) {
        spent[e.category] = (spent[e.category] ?? 0) + e.amount;
      }
    }
    final plannedJson = prefs.getString('planned_amounts') ?? '{}';
    final Map<String, dynamic> planned = jsonDecode(plannedJson);
    setState(() {
      _totalBudget = prefs.getDouble('total_budget') ?? 0.0;
      _spentAmounts = spent;
      _plannedAmounts = planned.map((k, v) => MapEntry(k, (v as num).toDouble()));
      _totalSpent = spent.values.fold(0.0, (sum, e) => sum + e);
    });
  }

  Future<void> _savePlanned() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('planned_amounts', jsonEncode(_plannedAmounts));
  }

  void _showSetBudgetDialog() {
    final ctrl = TextEditingController(
        text: _totalBudget > 0 ? _totalBudget.toStringAsFixed(0) : '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Set Monthly Budget', style: AppText.h2),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: AppText.h3,
              decoration: InputDecoration(
                labelText: 'Total Budget',
                prefixText: '₹ ',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.grey, size: 20),
                filled: true,
                fillColor: AppColors.greyLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final val = double.tryParse(ctrl.text) ?? 0;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('total_budget', val);
                setState(() => _totalBudget = val);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Text('Save Budget',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetPlannedDialog(String category) {
    final ctrl = TextEditingController(
        text: _plannedAmounts[category]?.toStringAsFixed(0) ?? '');
    final catData = _categories.firstWhere((c) => c['name'] == category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: catData['bg'] as Color,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(catData['icon'] as IconData,
                      color: catData['color'] as Color, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Budget for $category', style: AppText.h2),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: AppText.h3,
              decoration: InputDecoration(
                labelText: 'Planned Amount',
                prefixText: '₹ ',
                prefixIcon: const Icon(Icons.currency_rupee,
                    color: AppColors.grey, size: 20),
                filled: true,
                fillColor: AppColors.greyLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final val = double.tryParse(ctrl.text) ?? 0;
                setState(() => _plannedAmounts[category] = val);
                await _savePlanned();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: catData['color'] as Color,
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                  child: Text('Save',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _budgetProgress =>
      _totalBudget > 0 ? (_totalSpent / _totalBudget).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final budgetLeft = _totalBudget - _totalSpent;
    final isOverBudget = budgetLeft < 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget Planner', style: AppText.h1),
                      const SizedBox(height: 4),
                      Text('Plan your monthly spending', style: AppText.body),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showSetBudgetDialog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.tealLight,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.edit_outlined,
                          color: AppColors.teal, size: 22),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Overall budget card with progress ring
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(24)),
                child: _totalBudget == 0
                    ? GestureDetector(
                        onTap: _showSetBudgetDialog,
                        child: const Column(
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: Colors.white54, size: 40),
                            SizedBox(height: 12),
                            Text('Tap to set monthly budget',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          SizedBox(
                            width: 100, height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 35,
                                    startDegreeOffset: -90,
                                    sections: [
                                      PieChartSectionData(
                                        color: isOverBudget ? AppColors.red : AppColors.teal,
                                        value: _budgetProgress * 100,
                                        title: '',
                                        radius: 14,
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                      PieChartSectionData(
                                        color: Colors.white12,
                                        value: (1 - _budgetProgress) * 100,
                                        title: '',
                                        radius: 14,
                                        borderSide: const BorderSide(color: Colors.transparent),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(_budgetProgress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Monthly Budget',
                                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text('₹${_totalBudget.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _MiniChip(
                                        label: 'Spent',
                                        value: '₹${_totalSpent.toStringAsFixed(0)}',
                                        color: AppColors.yellow),
                                    const SizedBox(width: 8),
                                    _MiniChip(
                                        label: isOverBudget ? 'Over' : 'Left',
                                        value: '₹${budgetLeft.abs().toStringAsFixed(0)}',
                                        color: isOverBudget ? AppColors.red : AppColors.teal),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 28),

              // Category cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: AppText.h2),
                  Text('Tap to set budget',
                      style: AppText.label.copyWith(color: AppColors.teal)),
                ],
              ),
              const SizedBox(height: 14),

              ..._categories.map((cat) {
                final name = cat['name'] as String;
                final color = cat['color'] as Color;
                final bg = cat['bg'] as Color;
                final icon = cat['icon'] as IconData;
                final planned = _plannedAmounts[name] ?? 0;
                final spent = _spentAmounts[name] ?? 0;
                final isOver = spent > planned && planned > 0;
                final progress = planned > 0 ? (spent / planned).clamp(0.0, 1.0) : 0.0;

                return GestureDetector(
                  onTap: () => _showSetPlannedDialog(name),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppColors.cardShadow,
                      border: isOver
                          ? Border.all(color: AppColors.red.withOpacity(0.3))
                          : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                  color: bg, borderRadius: BorderRadius.circular(13)),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: AppText.h3),
                                  Text(
                                    planned == 0
                                        ? 'Tap to set budget'
                                        : 'Planned: ₹${planned.toStringAsFixed(0)}',
                                    style: AppText.label,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${spent.toStringAsFixed(0)}',
                                    style: AppText.h3.copyWith(
                                        color: isOver ? AppColors.red : color)),
                                if (isOver)
                                  Text('Over budget!',
                                      style: AppText.label.copyWith(color: AppColors.red)),
                              ],
                            ),
                          ],
                        ),
                        if (planned > 0) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress.toDouble(),
                              minHeight: 6,
                              backgroundColor: AppColors.greyLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  isOver ? AppColors.red : color),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₹${spent.toStringAsFixed(0)} spent',
                                  style: AppText.label),
                              Text(
                                '₹${(planned - spent).abs().toStringAsFixed(0)} ${isOver ? 'over' : 'left'}',
                                style: AppText.label.copyWith(
                                    color: isOver ? AppColors.red : AppColors.teal),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white12, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}