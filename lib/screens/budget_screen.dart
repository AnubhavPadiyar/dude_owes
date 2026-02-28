import 'package:flutter/material.dart';
import '../main.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

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
              Text('Budget Planner', style: AppText.h1),
              const SizedBox(height: 4),
              Text('Plan your monthly spending', style: AppText.body),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.pie_chart_outline,
                          color: AppColors.lavender, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text('Budget Planner', style: AppText.h2),
                    const SizedBox(height: 8),
                    Text('Coming soon!', style: AppText.body),
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