import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '';
  String _username = '';
  String _currency = '₹ INR';
  double _budget = 0.0;
  bool _notificationsEnabled = true;
  String _fontSize = 'Medium';
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'User';
      _username = prefs.getString('user_username') ?? 'username';
      _currency = prefs.getString('user_currency') ?? '₹ INR';
      _budget = prefs.getDouble('total_budget') ?? 0.0;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _fontSize = prefs.getString('font_size') ?? 'Medium';
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
    if (value is double) await prefs.setDouble(key, value);
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This will delete all your expenses, budgets and settings. This cannot be undone!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()), (_) => false);
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final userCtrl = TextEditingController(text: _username);
    final budgetCtrl = TextEditingController(text: _budget.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Edit Profile', style: AppText.h2),
            const SizedBox(height: 20),
            _FieldItem(controller: nameCtrl, label: 'Full Name', icon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            _FieldItem(controller: userCtrl, label: 'Username', icon: Icons.alternate_email_rounded),
            const SizedBox(height: 14),
            _FieldItem(controller: budgetCtrl, label: 'Monthly Budget', icon: Icons.wallet_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_name', nameCtrl.text);
                await prefs.setString('user_username', userCtrl.text);
                await prefs.setDouble('total_budget', double.tryParse(budgetCtrl.text) ?? 0.0);
                setState(() {
                  _name = nameCtrl.text;
                  _username = userCtrl.text;
                  _budget = double.tryParse(budgetCtrl.text) ?? 0.0;
                });
                if (mounted) Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Link copied!'),
      backgroundColor: AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Manage your preferences', style: AppText.body),
              const SizedBox(height: 24),

              // Profile card
              GestureDetector(
                onTap: _showEditProfileDialog,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(16)),
                        child: Center(
                          child: Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                            Text('@$_username', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('Budget: $_currency ${_budget.toStringAsFixed(0)}/month',
                                style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Preferences
              Text('Preferences', style: AppText.h2),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                child: Column(
                  children: [
                    // Dark mode
                    _ToggleTile(
                      icon: Icons.dark_mode_outlined,
                      color: AppColors.lavender,
                      bg: AppColors.lavenderLight,
                      label: 'Dark Mode',
                      sub: 'Switch to dark theme',
                      value: _darkMode,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                        _saveSetting('dark_mode', val);
                      },
                    ),
                    _Divider(),

                    // Notifications
                    _ToggleTile(
                      icon: Icons.notifications_outlined,
                      color: AppColors.yellow,
                      bg: AppColors.yellowLight,
                      label: 'Notifications',
                      sub: 'Budget alerts & reminders',
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() => _notificationsEnabled = val);
                        _saveSetting('notifications', val);
                      },
                    ),
                    _Divider(),

                    // Font size
                    _SelectTile(
                      icon: Icons.text_fields_rounded,
                      color: AppColors.teal,
                      bg: AppColors.tealLight,
                      label: 'Font Size',
                      value: _fontSize,
                      options: const ['Small', 'Medium', 'Large'],
                      onChanged: (val) {
                        setState(() => _fontSize = val);
                        _saveSetting('font_size', val);
                      },
                    ),
                    _Divider(),

                    // Currency
                    _SelectTile(
                      icon: Icons.currency_exchange_rounded,
                      color: AppColors.blue,
                      bg: AppColors.blueLight,
                      label: 'Currency',
                      value: _currency,
                      options: const ['₹ INR', r'$ USD', '€ EUR', '£ GBP', '¥ JPY'],
                      onChanged: (val) {
                        setState(() => _currency = val);
                        _saveSetting('user_currency', val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Danger zone
              Text('Data', style: AppText.h2),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: _showClearDataDialog,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Clear All Data', style: AppText.h3.copyWith(color: AppColors.red)),
                          Text('Delete all expenses & settings', style: AppText.label),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.red, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // About section
              Text('About', style: AppText.h2),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
                child: Column(
                  children: [
                    _LinkTile(
                      icon: Icons.code_rounded,
                      color: AppColors.dark,
                      bg: AppColors.greyLight,
                      label: 'GitHub',
                      value: 'AnubhavPadiyar',
                      link: 'https://github.com/AnubhavPadiyar',
                      onTap: () => _copyToClipboard('https://github.com/AnubhavPadiyar'),
                    ),
                    _Divider(),
                    _LinkTile(
                      icon: Icons.work_outline_rounded,
                      color: AppColors.blue,
                      bg: AppColors.blueLight,
                      label: 'LinkedIn',
                      value: 'Anubhav Padiyar',
                      link: 'https://www.linkedin.com/in/anubhav-padiyar-b9235237b',
                      onTap: () => _copyToClipboard('https://www.linkedin.com/in/anubhav-padiyar-b9235237b'),
                    ),
                    _Divider(),
                    _LinkTile(
                      icon: Icons.email_outlined,
                      color: AppColors.red,
                      bg: AppColors.redLight,
                      label: 'Email',
                      value: 'anubhavpadiyar@gmail.com',
                      link: 'anubhavpadiyar@gmail.com',
                      onTap: () => _copyToClipboard('anubhavpadiyar@gmail.com'),
                    ),
                    _Divider(),
                    _InfoTile(icon: Icons.info_outline_rounded, color: AppColors.lavender, bg: AppColors.lavenderLight, label: 'App Version', value: '1.0.0'),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, color: Color(0xFFF0F0F0));
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, sub;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleTile({required this.icon, required this.color, required this.bg,
      required this.label, required this.sub, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppText.h3.copyWith(fontSize: 14)),
            Text(sub, style: AppText.label),
          ])),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.teal),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, value;
  final List<String> options;
  final Function(String) onChanged;

  const _SelectTile({required this.icon, required this.color, required this.bg,
      required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppText.h3.copyWith(fontSize: 14))),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppText.h2),
                      const SizedBox(height: 16),
                      ...options.map((opt) => GestureDetector(
                        onTap: () { onChanged(opt); Navigator.pop(context); },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: value == opt ? AppColors.tealLight : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: value == opt ? AppColors.teal : Colors.transparent),
                          ),
                          child: Row(children: [
                            Text(opt, style: TextStyle(fontWeight: FontWeight.w600, color: value == opt ? AppColors.teal : AppColors.dark)),
                            const Spacer(),
                            if (value == opt) const Icon(Icons.check_rounded, color: AppColors.teal, size: 18),
                          ]),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(8)),
              child: Text(value, style: AppText.label.copyWith(color: AppColors.teal, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, value, link;
  final VoidCallback onTap;

  const _LinkTile({required this.icon, required this.color, required this.bg,
      required this.label, required this.value, required this.link, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppText.label),
              Text(value, style: AppText.h3.copyWith(fontSize: 13)),
            ])),
            Icon(Icons.copy_rounded, color: AppColors.grey.withOpacity(0.4), size: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, value;

  const _InfoTile({required this.icon, required this.color, required this.bg, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppText.h3.copyWith(fontSize: 14))),
          Text(value, style: AppText.label.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FieldItem extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _FieldItem({required this.controller, required this.label, required this.icon,
      this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppText.h3,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.body,
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
      ),
    );
  }
}
