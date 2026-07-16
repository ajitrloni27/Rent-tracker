import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../core/theme.dart';
import '../utils/formatters.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final stats = ref.watch(transactionStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No data for reports'));
          }

          final expenseCategories = _calculateTopExpenses(transactions);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryRow(stats),
                const SizedBox(height: 24),
                Text('Income vs Expense', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildPieChart(stats),
                const SizedBox(height: 32),
                Text('Top Expense Categories', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildExpenseList(expenseCategories),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryRow(TransactionStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Income', stats.totalCredit, AppTheme.creditColor),
        _buildStatItem('Expense', stats.totalDebit, AppTheme.debitColor),
        _buildStatItem('Balance', stats.balance, AppTheme.primaryColor),
      ],
    );
  }

  Widget _buildStatItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          AppFormatters.currency(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPieChart(TransactionStats stats) {
    if (stats.totalCredit == 0 && stats.totalDebit == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              color: AppTheme.creditColor,
              value: stats.totalCredit,
              title: '${(stats.totalCredit / (stats.totalCredit + stats.totalDebit) * 100).toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: AppTheme.debitColor,
              value: stats.totalDebit,
              title: '${(stats.totalDebit / (stats.totalCredit + stats.totalDebit) * 100).toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateTopExpenses(List<Transaction> transactions) {
    final Map<String, double> expenses = {};
    for (var tx in transactions) {
      if (tx.type == TransactionType.debit) {
        expenses[tx.category] = (expenses[tx.category] ?? 0) + tx.amount;
      }
    }
    final sorted = expenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  Widget _buildExpenseList(Map<String, double> expenses) {
    if (expenses.isEmpty) {
      return const Text('No expenses recorded.');
    }
    return Column(
      children: expenses.entries.map((e) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(e.key),
          trailing: Text(
            AppFormatters.currency(e.value),
            style: const TextStyle(color: AppTheme.debitColor, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }
}
