import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final budgetController = TextEditingController();
  String _selectedCurrency = '₹ INR';

  final List<String> _currencies = ['₹ INR', r'$ USD', '€ EUR', '£ GBP', '¥ JPY'];

  Future<void> _saveAndContinue() async {
    if (nameController.text.isEmpty || usernameController.text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nameController.text.trim());
    await prefs.setString('user_username', usernameController.text.trim());
    await prefs.setString('user_currency', _selectedCurrency);
    await prefs.setDouble('total_budget', double.tryParse(budgetController.text) ?? 0.0);
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RootScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppColors.teal : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.wallet_outlined, color: AppColors.teal, size: 36),
          ),
          const SizedBox(height: 24),
          Text('Welcome to\nDudeOwes! 👋', style: AppText.h1.copyWith(fontSize: 30, height: 1.3)),
          const SizedBox(height: 12),
          Text('Your personal offline money tracker. Let\'s set up your profile first.', style: AppText.body.copyWith(fontSize: 15)),
          const SizedBox(height: 40),
          _InputField(controller: nameController, label: 'Full Name', icon: Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _InputField(controller: usernameController, label: 'Username', icon: Icons.alternate_email_rounded),
          const Spacer(),
          _NextButton(
            label: 'Continue',
            onTap: () {
              if (nameController.text.isEmpty || usernameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Please fill all fields'), backgroundColor: AppColors.red,
                      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                return;
              }
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.yellowLight, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.currency_exchange_rounded, color: AppColors.yellow, size: 36),
          ),
          const SizedBox(height: 24),
          Text('Choose Your\nCurrency 💱', style: AppText.h1.copyWith(fontSize: 30, height: 1.3)),
          const SizedBox(height: 12),
          Text('Select the currency you use daily for tracking expenses.', style: AppText.body.copyWith(fontSize: 15)),
          const SizedBox(height: 40),
          ...List.generate(_currencies.length, (i) {
            final isSelected = _selectedCurrency == _currencies[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedCurrency = _currencies[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.teal : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: isSelected ? AppColors.teal : Colors.transparent),
                ),
                child: Row(
                  children: [
                    Text(_currencies[i], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                        color: isSelected ? Colors.white : AppColors.dark)),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          _NextButton(
            label: 'Continue',
            onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.lavenderLight, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.lavender, size: 36),
          ),
          const SizedBox(height: 24),
          Text('Set Monthly\nBudget 📋', style: AppText.h1.copyWith(fontSize: 30, height: 1.3)),
          const SizedBox(height: 12),
          Text('How much do you plan to spend this month? You can change this later.', style: AppText.body.copyWith(fontSize: 15)),
          const SizedBox(height: 40),
          _InputField(controller: budgetController, label: 'Monthly Budget', icon: Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number, prefix: '${_selectedCurrency.split(' ')[0]} '),
          const Spacer(),
          _NextButton(label: "Let's Go! 🚀", onTap: _saveAndContinue),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: _saveAndContinue,
              child: Text('Skip for now', style: AppText.label.copyWith(color: AppColors.grey, decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
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

  const _InputField({required this.controller, required this.label, required this.icon,
      this.keyboardType = TextInputType.text, this.prefix});

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
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
      ),
    );
  }
}
