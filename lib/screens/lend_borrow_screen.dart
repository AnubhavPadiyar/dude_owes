import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/lend_borrow.dart';
import '../main.dart';

class LendBorrowScreen extends StatefulWidget {
  const LendBorrowScreen({super.key});

  @override
  State<LendBorrowScreen> createState() => _LendBorrowScreenState();
}

class _LendBorrowScreenState extends State<LendBorrowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LendBorrow> _all = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final items = await DBHelper.getLendBorrows();
    setState(() => _all = items);
  }

  List<LendBorrow> get _pending =>
      _all.where((e) => !e.isSettled).toList();
  List<LendBorrow> get _settled =>
      _all.where((e) => e.isSettled).toList();

  double get _totalLent => _pending
      .where((e) => e.type == 'lent')
      .fold(0.0, (sum, e) => sum + e.remainingAmount);

  double get _totalBorrowed => _pending
      .where((e) => e.type == 'borrowed')
      .fold(0.0, (sum, e) => sum + e.remainingAmount);

  void _showAddSheet() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String type = 'lent';

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
              Text('Add Entry', style: AppText.h2),
              const SizedBox(height: 20),

              // Type selector
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => type = 'lent'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: type == 'lent' ? AppColors.teal : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text('I Lent',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: type == 'lent' ? Colors.white : AppColors.grey)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => type = 'borrowed'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: type == 'borrowed' ? AppColors.red : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text('I Borrowed',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: type == 'borrowed' ? Colors.white : AppColors.grey)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _InputField(controller: nameController, label: 'Person Name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _InputField(controller: amountController, label: 'Amount', icon: Icons.currency_rupee, keyboardType: TextInputType.number, prefix: '₹ '),
              const SizedBox(height: 12),
              _InputField(controller: noteController, label: 'Note (optional)', icon: Icons.note_outlined),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () async {
                  if (nameController.text.isEmpty || amountController.text.isEmpty) return;
                  final item = LendBorrow(
                    personName: nameController.text.trim(),
                    type: type,
                    amount: double.parse(amountController.text),
                    remainingAmount: double.parse(amountController.text),
                    date: DateTime.now().toIso8601String(),
                    note: noteController.text,
                    isSettled: false,
                  );
                  await DBHelper.insertLendBorrow(item);
                  Navigator.pop(context);
                  _loadData();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: type == 'lent' ? AppColors.teal : AppColors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
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
      ),
    );
  }

  void _showRepaySheet(LendBorrow item) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text('Record Repayment', style: AppText.h2),
            const SizedBox(height: 4),
            Text('Remaining: ₹${item.remainingAmount.toStringAsFixed(0)}',
                style: AppText.body),
            const SizedBox(height: 20),
            _InputField(
              controller: amountController,
              label: 'Repayment Amount',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              prefix: '₹ ',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final repaid = double.tryParse(amountController.text) ?? 0;
                      if (repaid <= 0) return;
                      item.remainingAmount =
                          (item.remainingAmount - repaid).clamp(0, item.amount);
                      if (item.remainingAmount == 0) item.isSettled = true;
                      await DBHelper.updateLendBorrow(item);
                      Navigator.pop(context);
                      _loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('Record',
                            style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      item.remainingAmount = 0;
                      item.isSettled = true;
                      await DBHelper.updateLendBorrow(item);
                      Navigator.pop(context);
                      _loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text('Settle All',
                            style: TextStyle(
                                color: AppColors.dark,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<LendBorrow> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.handshake_outlined,
                  color: AppColors.teal, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Nothing here yet', style: AppText.h3),
            const SizedBox(height: 4),
            Text('Tap + to add an entry', style: AppText.body),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLent = item.type == 'lent';
        final color = isLent ? AppColors.teal : AppColors.red;
        final bg = isLent ? AppColors.tealLight : AppColors.redLight;
        final progress = item.amount > 0
            ? (item.remainingAmount / item.amount)
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        item.personName[0].toUpperCase(),
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.personName, style: AppText.h3),
                        Text(
                          isLent ? 'You lent' : 'You borrowed',
                          style: AppText.label.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${item.remainingAmount.toStringAsFixed(0)}',
                          style: AppText.h3.copyWith(color: color)),
                      Text('of ₹${item.amount.toStringAsFixed(0)}',
                          style: AppText.label),
                    ],
                  ),
                ],
              ),

              if (!item.isSettled) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    minHeight: 5,
                    backgroundColor: AppColors.greyLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showRepaySheet(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text('Repayment',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        await DBHelper.deleteLendBorrow(item.id!);
                        _loadData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Delete',
                            style: AppText.label.copyWith(
                                color: AppColors.red)),
                      ),
                    ),
                  ],
                ),
              ],

              if (item.isSettled)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.teal, size: 14),
                      SizedBox(width: 4),
                      Text('Settled',
                          style: TextStyle(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
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
                  Text('Lend / Borrow', style: AppText.h1),
                  const SizedBox(height: 4),
                  Text('Track money you gave or took', style: AppText.body),
                  const SizedBox(height: 20),

                  // Summary row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('You will get',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('₹${_totalLent.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('You will give',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('₹${_totalBorrowed.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tabs
                  Container(
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
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12),
                      dividerColor: Colors.transparent,
                      tabs: [
                        const Tab(text: 'All'),
                        Tab(text: 'Pending (${_pending.length})'),
                        Tab(text: 'Settled (${_settled.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_all),
                  _buildList(_pending),
                  _buildList(_settled),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.teal,
        elevation: 4,
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Entry',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
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