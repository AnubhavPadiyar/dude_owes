import 'package:flutter/material.dart';
import '../main.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _firstNum = 0;
  String _operator = '';
  bool _shouldReplace = false;
  List<String> _history = [];

  void _onButton(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _firstNum = 0;
        _operator = '';
        _shouldReplace = false;
      } else if (value == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (['+', '-', '×', '÷'].contains(value)) {
        _firstNum = double.tryParse(_display) ?? 0;
        _operator = value;
        _expression = '$_display $value';
        _shouldReplace = true;
      } else if (value == '=') {
        if (_operator.isEmpty) return;
        final second = double.tryParse(_display) ?? 0;
        double result = 0;
        switch (_operator) {
          case '+': result = _firstNum + second; break;
          case '-': result = _firstNum - second; break;
          case '×': result = _firstNum * second; break;
          case '÷': result = second != 0 ? _firstNum / second : 0; break;
        }
        final historyEntry = '$_expression $_display = ${_formatResult(result)}';
        _history.insert(0, historyEntry);
        if (_history.length > 10) _history.removeLast();
        _expression = '';
        _display = _formatResult(result);
        _operator = '';
        _shouldReplace = true;
      } else if (value == '%') {
        final num = double.tryParse(_display) ?? 0;
        _display = _formatResult(num / 100);
      } else if (value == '+/-') {
        final num = double.tryParse(_display) ?? 0;
        _display = _formatResult(-num);
      } else if (value == '.') {
        if (!_display.contains('.')) {
          _display = _shouldReplace ? '0.' : '$_display.';
          _shouldReplace = false;
        }
      } else {
        // number
        if (_shouldReplace || _display == '0') {
          _display = value;
          _shouldReplace = false;
        } else {
          if (_display.length < 12) _display += value;
        }
      }
    });
  }

  String _formatResult(double result) {
    if (result == result.truncateToDouble()) {
      return result.toInt().toString();
    }
    return double.parse(result.toStringAsFixed(6)).toString();
  }

  Widget _buildButton(String label, {Color? color, Color? textColor, bool isWide = false}) {
    final bg = color ?? AppColors.white;
    final fg = textColor ?? AppColors.dark;
    return GestureDetector(
      onTap: () => _onButton(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: isWide ? double.infinity : null,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: fg,
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Calculator', style: AppText.h1),
                  GestureDetector(
                    onTap: () {
                      if (_history.isEmpty) return;
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => Container(
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('History', style: AppText.h2),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _history.clear());
                                      Navigator.pop(context);
                                    },
                                    child: Text('Clear',
                                        style: AppText.label.copyWith(color: AppColors.red)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._history.map((h) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(h, style: AppText.h3.copyWith(fontSize: 13)),
                                ),
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: AppColors.teal, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _display,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // Row 1
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('C', color: AppColors.redLight, textColor: AppColors.red)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('+/-', color: AppColors.greyLight, textColor: AppColors.dark)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('%', color: AppColors.greyLight, textColor: AppColors.dark)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('÷', color: AppColors.teal, textColor: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Row 2
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('7')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('8')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('9')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('×', color: AppColors.teal, textColor: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Row 3
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('4')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('5')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('6')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('-', color: AppColors.teal, textColor: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Row 4
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('1')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('2')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('3')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('+', color: AppColors.teal, textColor: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Row 5
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: _buildButton('0')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('.')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('⌫', color: AppColors.yellowLight, textColor: AppColors.dark)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('=', color: AppColors.yellow, textColor: AppColors.dark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}