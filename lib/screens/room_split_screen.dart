import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/room_split.dart';
import '../main.dart';

class RoomSplitScreen extends StatefulWidget {
  const RoomSplitScreen({super.key});

  @override
  State<RoomSplitScreen> createState() => _RoomSplitScreenState();
}

class _RoomSplitScreenState extends State<RoomSplitScreen> {
  List<SplitGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final groups = await DBHelper.getSplitGroups();
    setState(() => _groups = groups);
  }

  void _showCreateGroupSheet() {
    final nameController = TextEditingController();
    final memberController = TextEditingController();
    List<String> members = [];

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Create Split Group', style: AppText.h2),
                const SizedBox(height: 20),
                _InputField(
                  controller: nameController,
                  label: 'Group Name (e.g. Trip to Goa)',
                  icon: Icons.group_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                        controller: memberController,
                        label: 'Add Member',
                        icon: Icons.person_add_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (memberController.text.trim().isEmpty) return;
                        setModalState(() {
                          members.add(memberController.text.trim());
                          memberController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (members.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: members.map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(m, style: AppText.label.copyWith(color: AppColors.teal)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setModalState(() => members.remove(m)),
                            child: const Icon(Icons.close, size: 14, color: AppColors.teal),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    if (nameController.text.isEmpty || members.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add a name and at least 2 members')),
                      );
                      return;
                    }
                    final group = SplitGroup(
                      name: nameController.text.trim(),
                      members: members,
                      expenses: [],
                    );
                    await DBHelper.insertSplitGroup(group);
                    Navigator.pop(context);
                    _loadData();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Create Group',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
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
                  Text('Room Split', style: AppText.h1),
                  const SizedBox(height: 4),
                  Text('Split bills with friends', style: AppText.body),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _groups.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.blueLight,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.group_outlined,
                                color: AppColors.blue, size: 48),
                          ),
                          const SizedBox(height: 16),
                          Text('No groups yet', style: AppText.h3),
                          const SizedBox(height: 4),
                          Text('Tap + to create a split group', style: AppText.body),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SplitGroupDetailScreen(group: group),
                            ),
                          ).then((_) => _loadData()),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.blueLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.group_outlined,
                                      color: AppColors.blue, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(group.name, style: AppText.h3),
                                      Text(
                                        '${group.members.length} members • ${group.expenses.length} expenses',
                                        style: AppText.label,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${group.totalAmount.toStringAsFixed(0)}',
                                      style: AppText.h3.copyWith(color: AppColors.blue),
                                    ),
                                    Text('total', style: AppText.label),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blue,
        elevation: 4,
        onPressed: _showCreateGroupSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Group',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class SplitGroupDetailScreen extends StatefulWidget {
  final SplitGroup group;
  const SplitGroupDetailScreen({super.key, required this.group});

  @override
  State<SplitGroupDetailScreen> createState() => _SplitGroupDetailScreenState();
}

class _SplitGroupDetailScreenState extends State<SplitGroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late SplitGroup _group;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddExpenseSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String paidBy = _group.members.first;
    List<String> splitAmong = List.from(_group.members);

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Add Expense', style: AppText.h2),
                const SizedBox(height: 20),
                _InputField(
                  controller: titleController,
                  label: 'What was it for?',
                  icon: Icons.receipt_outlined,
                ),
                const SizedBox(height: 12),
                _InputField(
                  controller: amountController,
                  label: 'Amount',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  prefix: '₹ ',
                ),
                const SizedBox(height: 16),
                Text('Paid by', style: AppText.h3),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _group.members.map((m) {
                      final isSelected = paidBy == m;
                      return GestureDetector(
                        onTap: () => setModalState(() => paidBy = m),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.teal : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(m,
                              style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Split among', style: AppText.h3),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _group.members.map((m) {
                    final isSelected = splitAmong.contains(m);
                    return GestureDetector(
                      onTap: () => setModalState(() {
                        if (isSelected) {
                          if (splitAmong.length > 1) splitAmong.remove(m);
                        } else {
                          splitAmong.add(m);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.blueLight : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? Border.all(color: AppColors.blue) : null,
                        ),
                        child: Text(m,
                            style: TextStyle(
                                color: isSelected ? AppColors.blue : AppColors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    if (titleController.text.isEmpty || amountController.text.isEmpty) return;
                    final expense = SplitExpense(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: titleController.text.trim(),
                      amount: double.parse(amountController.text),
                      paidBy: paidBy,
                      splitAmong: splitAmong,
                      date: DateTime.now().toIso8601String(),
                    );
                    final updatedGroup = SplitGroup(
                      id: _group.id,
                      name: _group.name,
                      members: _group.members,
                      expenses: [..._group.expenses, expense],
                      isSettled: _group.isSettled,
                    );
                    await DBHelper.updateSplitGroup(updatedGroup);
                    setState(() => _group = updatedGroup);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Add Expense',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balances = _group.getBalances();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.dark, size: 20),
        ),
        title: Text(_group.name, style: AppText.h2),
        actions: [
          GestureDetector(
            onTap: () async {
              await DBHelper.deleteSplitGroup(_group.id!);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(label: 'Total',
                      value: '₹${_group.totalAmount.toStringAsFixed(0)}',
                      color: Colors.white),
                  _SummaryItem(label: 'Members',
                      value: '${_group.members.length}',
                      color: AppColors.teal),
                  _SummaryItem(
                      label: 'Per Head',
                      value: _group.members.isEmpty
                          ? '₹0'
                          : '₹${(_group.totalAmount / _group.members.length).toStringAsFixed(0)}',
                      color: AppColors.yellow),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: AppColors.cardShadow,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.dark,
                unselectedLabelColor: AppColors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Balances'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _group.expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.blueLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.receipt_outlined,
                                  color: AppColors.blue, size: 40),
                            ),
                            const SizedBox(height: 12),
                            Text('No expenses yet', style: AppText.h3),
                            const SizedBox(height: 4),
                            Text('Tap + to add an expense', style: AppText.body),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: _group.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _group.expenses[index];
                          final share = expense.amount / expense.splitAmong.length;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.blueLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.receipt_outlined,
                                      color: AppColors.blue, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.title, style: AppText.h3),
                                      Text(
                                        'Paid by ${expense.paidBy} • ₹${share.toStringAsFixed(0)}/person',
                                        style: AppText.label,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${expense.amount.toStringAsFixed(0)}',
                                  style: AppText.h3.copyWith(color: AppColors.blue),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: balances.entries.map((entry) {
                    final isPositive = entry.value > 0;
                    final isNeutral = entry.value.abs() < 0.01;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: isNeutral
                                  ? AppColors.greyLight
                                  : isPositive
                                      ? AppColors.tealLight
                                      : AppColors.redLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                entry.key[0].toUpperCase(),
                                style: TextStyle(
                                  color: isNeutral
                                      ? AppColors.grey
                                      : isPositive
                                          ? AppColors.teal
                                          : AppColors.red,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key, style: AppText.h3),
                                Text(
                                  isNeutral ? 'All settled!' : isPositive ? 'Gets back' : 'Owes',
                                  style: AppText.label.copyWith(
                                    color: isNeutral
                                        ? AppColors.grey
                                        : isPositive
                                            ? AppColors.teal
                                            : AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isNeutral ? '✓' : '₹${entry.value.abs().toStringAsFixed(0)}',
                            style: AppText.h3.copyWith(
                              color: isNeutral
                                  ? AppColors.teal
                                  : isPositive
                                      ? AppColors.teal
                                      : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blue,
        elevation: 4,
        onPressed: _showAddExpenseSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? prefix;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppText.h3,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.body,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
        filled: true,
        fillColor: AppColors.greyLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
      ),
    );
  }
}
