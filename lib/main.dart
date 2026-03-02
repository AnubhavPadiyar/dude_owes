import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/expenses_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/lend_borrow_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/room_split_screen.dart';
import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(DudeOwesApp(showOnboarding: !onboardingDone));
}

class AppColors {
  static const background    = Color(0xFFF5F5F5);
  static const dark          = Color(0xFF242424);
  static const white         = Color(0xFFFFFFFF);
  static const red           = Color(0xFFE0533D);
  static const redLight      = Color(0xFFFDECE9);
  static const lavender      = Color(0xFF9DA7D0);
  static const lavenderLight = Color(0xFFEEF0F9);
  static const teal          = Color(0xFF469B88);
  static const tealLight     = Color(0xFFE4F3F0);
  static const blue          = Color(0xFF377CC8);
  static const blueLight     = Color(0xFFE8F1FB);
  static const yellow        = Color(0xFFEED868);
  static const yellowLight   = Color(0xFFFDF9E3);
  static const pink          = Color(0xFFE78C9D);
  static const pinkLight     = Color(0xFFFDEDF1);
  static const grey          = Color(0xFF8A94A6);
  static const greyLight     = Color(0xFFEEEEEE);
  static const primary       = teal;
  static const primaryLight  = tealLight;

  static const cardShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

class AppText {
  static const h1    = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.dark, letterSpacing: -0.5);
  static const h2    = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark);
  static const h3    = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dark);
  static const body  = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.grey);
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.grey, letterSpacing: 0.2);
}

class DudeOwesApp extends StatelessWidget {
  final bool showOnboarding;
  const DudeOwesApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DudeOwes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
        useMaterial3: true,
      ),
      home: showOnboarding ? const OnboardingScreen() : const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExpensesScreen(),
    BudgetScreen(),
    LendBorrowScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 20, offset: Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,         label: 'Home',     index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Expenses', index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.pie_chart_outline,     activeIcon: Icons.pie_chart_rounded,    label: 'Budget',   index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.handshake_outlined,    activeIcon: Icons.handshake_rounded,    label: 'Lend',     index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.settings_outlined,     activeIcon: Icons.settings_rounded,     label: 'Settings', index: 4, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final Function(int) onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label,
      required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.tealLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isActive ? activeIcon : icon,
                  color: isActive ? AppColors.teal : AppColors.grey, size: 22),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? AppColors.teal : AppColors.grey)),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _name = 'there';
  double _totalSpent = 0.0;
  double _budget = 0.0;
  List _recentExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await DBHelper.getExpenses();
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final total = expenses
        .where((e) => e.date.startsWith(month))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    final recent = expenses.take(3).toList();

    setState(() {
      _name = prefs.getString('user_name') ?? 'there';
      _budget = prefs.getDouble('total_budget') ?? 0.0;
      _totalSpent = total;
      _recentExpenses = recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetLeft = _budget - _totalSpent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        Text('Good day, $_name! 👋',
                            style: AppText.label.copyWith(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('DudeOwes', style: AppText.h1),
                      ],
                    ),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.teal, size: 22),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Spent This Month',
                          style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('₹${_totalSpent.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 36,
                              fontWeight: FontWeight.w800, letterSpacing: -1)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _BalanceChip(
                            label: 'Budget Left',
                            value: budgetLeft >= 0
                                ? '₹${budgetLeft.toStringAsFixed(0)}'
                                : '-₹${(-budgetLeft).toStringAsFixed(0)}',
                            color: budgetLeft >= 0 ? AppColors.teal : AppColors.red,
                          ),
                          const SizedBox(width: 12),
                          const _BalanceChip(label: 'Pending Dues', value: '₹0', color: AppColors.yellow),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LendBorrowScreen())).then((_) => _loadData()),
                        child: const _BigActionCard(
                          label: 'Lend / Borrow',
                          sub: 'Track dues',
                          icon: Icons.handshake_outlined,
                          color: AppColors.red,
                          bg: AppColors.redLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RoomSplitScreen())).then((_) => _loadData()),
                        child: const _BigActionCard(
                          label: 'Room Split',
                          sub: 'Split bills',
                          icon: Icons.group_outlined,
                          color: AppColors.blue,
                          bg: AppColors.blueLight,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ExpensesScreen())).then((_) => _loadData()),
                        child: const _BigActionCard(
                          label: 'My Expenses',
                          sub: 'Daily spending',
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.teal,
                          bg: AppColors.tealLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const BudgetScreen())),
                        child: const _BigActionCard(
                          label: 'Budget',
                          sub: 'Plan spending',
                          icon: Icons.pie_chart_outline,
                          color: AppColors.lavender,
                          bg: AppColors.lavenderLight,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions', style: AppText.h2),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ExpensesScreen())).then((_) => _loadData()),
                      child: Text('See all',
                          style: AppText.label.copyWith(
                              color: AppColors.teal, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _recentExpenses.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.tealLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.receipt_long_outlined,
                                    color: AppColors.teal, size: 32),
                              ),
                              const SizedBox(height: 14),
                              Text('No transactions yet', style: AppText.h3),
                              const SizedBox(height: 4),
                              Text('Add your first expense to get started', style: AppText.body),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          children: _recentExpenses.map((expense) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.tealLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_outlined,
                                        color: AppColors.teal, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(expense.title, style: AppText.h3.copyWith(fontSize: 14)),
                                        Text(expense.category, style: AppText.label),
                                      ],
                                    ),
                                  ),
                                  Text('₹${expense.amount.toStringAsFixed(0)}',
                                      style: AppText.h3.copyWith(color: AppColors.teal)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CalculatorScreen())),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                          color: AppColors.yellow.withOpacity(0.3),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calculate_outlined,
                              color: AppColors.dark, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Calculator',
                                style: AppText.h3.copyWith(color: AppColors.dark)),
                            Text('Do quick math',
                                style: AppText.label.copyWith(
                                    color: AppColors.dark.withOpacity(0.5))),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.dark, size: 16),
                      ],
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
}

class _BalanceChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BalanceChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final Color color, bg;
  const _BigActionCard({required this.label, required this.sub, required this.icon,
      required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(label, style: AppText.h3.copyWith(fontSize: 14)),
          const SizedBox(height: 2),
          Text(sub, style: AppText.label),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  const PlaceholderScreen({super.key, required this.label, required this.icon,
      required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.h1),
              const SizedBox(height: 4),
              Text('Coming soon!', style: AppText.body),
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(28)),
                      child: Icon(icon, color: color, size: 52),
                    ),
                    const SizedBox(height: 20),
                    Text(label, style: AppText.h2),
                    const SizedBox(height: 8),
                    Text('This screen is being built!', style: AppText.body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}