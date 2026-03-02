import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/db_helper.dart';

class PdfGenerator {
  // ── Colors ──────────────────────────────────────────────────────────────────
  static final _teal       = PdfColor.fromHex('469B88');
  static final _blue       = PdfColor.fromHex('377CC8');
  static final _red        = PdfColor.fromHex('E0533D');
  static final _dark       = PdfColor.fromHex('242424');
  static final _yellow     = PdfColor.fromHex('EED868');
  static final _tealLight  = PdfColor.fromHex('E4F3F0');
  static final _bgGrey     = PdfColor.fromHex('F5F5F5');
  static final _lineGrey   = PdfColor.fromHex('EEEEEE');
  static final _textGrey   = PdfColor.fromHex('8A94A6');

  static Future<void> generateMonthlyReport(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = await DBHelper.getExpenses();
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final monthName = _monthName(now.month);

    final userName = prefs.getString('user_name') ?? 'User';
    final totalBudget = prefs.getDouble('total_budget') ?? 0.0;
    final currency = prefs.getString('user_currency') ?? 'INR';
    // Strip emoji/symbol — just keep the code e.g. "INR"
    final symbol = currency.contains(' ') ? currency.split(' ').last : currency;

    final monthExpenses = expenses.where((e) => e.date.startsWith(month)).toList();
    final totalSpent = monthExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final budgetLeft = totalBudget - totalSpent;
    final isOver = budgetLeft < 0;

    final Map<String, double> categoryTotals = {};
    for (final e in monthExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) => [

          // ── Header ──────────────────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: pw.BoxDecoration(
              color: _dark,
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('DudeOwes',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Monthly Expense Report',
                        style: pw.TextStyle(color: _textGrey, fontSize: 12)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('$monthName ${now.year}',
                        style: pw.TextStyle(
                            color: _teal,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(userName,
                        style: pw.TextStyle(color: _textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── Summary Cards ────────────────────────────────────────────────────
          pw.Row(
            children: [
              _summaryCard('Total Spent',
                  '${totalSpent.toStringAsFixed(0)} $symbol', _teal),
              pw.SizedBox(width: 10),
              _summaryCard('Monthly Budget',
                  '${totalBudget.toStringAsFixed(0)} $symbol', _blue),
              pw.SizedBox(width: 10),
              _summaryCard(
                isOver ? 'Over Budget' : 'Budget Left',
                '${budgetLeft.abs().toStringAsFixed(0)} $symbol',
                isOver ? _red : PdfColor.fromHex('4CAF82'),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // ── Category Breakdown ───────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _teal,
              borderRadius: pw.BorderRadius.only(
                topLeft: const pw.Radius.circular(10),
                topRight: const pw.Radius.circular(10),
              ),
            ),
            child: pw.Text('Spending by Category',
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold)),
          ),

          if (categoryTotals.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(color: _bgGrey),
              child: pw.Text('No expenses this month',
                  style: pw.TextStyle(color: _textGrey)),
            )
          else
            ...categoryTotals.entries.map((entry) {
              final percent = totalSpent > 0
                  ? (entry.value / totalSpent * 100).toStringAsFixed(1)
                  : '0';
              final barFraction = totalSpent > 0
                  ? (entry.value / totalSpent).clamp(0.0, 1.0)
                  : 0.0;
              final maxBarWidth = PdfPageFormat.a4.availableWidth - 72;

              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: _bgGrey,
                  border: pw.Border(
                      bottom: pw.BorderSide(color: _lineGrey, width: 1)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(entry.key,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: _dark)),
                        pw.Text(
                            '${entry.value.toStringAsFixed(0)} $symbol  ($percent%)',
                            style: pw.TextStyle(
                                fontSize: 11,
                                color: _dark,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 6),
                    pw.Stack(
                      children: [
                        pw.Container(
                          height: 7,
                          width: maxBarWidth,
                          decoration: pw.BoxDecoration(
                            color: _lineGrey,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                        pw.Container(
                          height: 7,
                          width: maxBarWidth * barFraction,
                          decoration: pw.BoxDecoration(
                            color: _teal,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          pw.SizedBox(height: 24),

          // ── Transactions Table ───────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: pw.BoxDecoration(
              color: _dark,
              borderRadius: pw.BorderRadius.only(
                topLeft: const pw.Radius.circular(10),
                topRight: const pw.Radius.circular(10),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 3, child: pw.Text('Description',
                    style: pw.TextStyle(color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold, fontSize: 11))),
                pw.Expanded(flex: 2, child: pw.Text('Category',
                    style: pw.TextStyle(color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold, fontSize: 11))),
                pw.Expanded(flex: 2, child: pw.Text('Date',
                    style: pw.TextStyle(color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold, fontSize: 11))),
                pw.Expanded(flex: 2, child: pw.Text('Amount',
                    style: pw.TextStyle(color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold, fontSize: 11),
                    textAlign: pw.TextAlign.right)),
              ],
            ),
          ),

          if (monthExpenses.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(color: _bgGrey),
              child: pw.Text('No transactions this month',
                  style: pw.TextStyle(color: _textGrey)),
            )
          else ...[
            ...monthExpenses.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final date = e.date.length >= 10 ? e.date.substring(0, 10) : e.date;
              final bg = i % 2 == 0 ? PdfColors.white : _bgGrey;
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: pw.BoxDecoration(
                  color: bg,
                  border: pw.Border(
                      bottom: pw.BorderSide(color: _lineGrey, width: 0.5)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text(e.title,
                        style: pw.TextStyle(fontSize: 11, color: _dark))),
                    pw.Expanded(flex: 2, child: pw.Text(e.category,
                        style: pw.TextStyle(fontSize: 11, color: _textGrey))),
                    pw.Expanded(flex: 2, child: pw.Text(date,
                        style: pw.TextStyle(fontSize: 11, color: _textGrey))),
                    pw.Expanded(flex: 2, child: pw.Text(
                        '${e.amount.toStringAsFixed(0)} $symbol',
                        style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: _teal),
                        textAlign: pw.TextAlign.right)),
                  ],
                ),
              );
            }),

            // Total row
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: pw.BoxDecoration(
                color: _tealLight,
                borderRadius: pw.BorderRadius.only(
                  bottomLeft: const pw.Radius.circular(10),
                  bottomRight: const pw.Radius.circular(10),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                          color: _dark)),
                  pw.Text('${totalSpent.toStringAsFixed(0)} $symbol',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                          color: _teal)),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 32),

          // ── Footer ───────────────────────────────────────────────────────────
          pw.Center(
            child: pw.Text(
                'Generated by DudeOwes  |  $monthName ${now.year}',
                style: pw.TextStyle(color: _textGrey, fontSize: 10)),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'DudeOwes_${monthName}_${now.year}.pdf',
    );
  }

  static pw.Widget _summaryCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 15)),
            pw.SizedBox(height: 6),
            pw.Text(label,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}