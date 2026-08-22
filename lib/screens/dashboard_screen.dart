import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../utils/currency_formatter.dart';
import '../models/transaction.dart';
import '../core/theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(currentBalanceProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final thisMonthIncome = ref.watch(thisMonthIncomeProvider);
    final thisMonthExpense = ref.watch(thisMonthExpenseProvider);
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBalanceCard(context, balance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard(context, 'Total Income', totalIncome, AppTheme.incomeColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(context, 'Total Expense', totalExpense, AppTheme.expenseColor)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryCard(context, 'This Mth Income', thisMonthIncome, AppTheme.incomeColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard(context, 'This Mth Expense', thisMonthExpense, AppTheme.expenseColor)),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRecentTransactions(transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(balance),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No transactions yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    
    final recent = transactions.take(5).toList();
    
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = recent[index];
          final isIncome = t.type == TransactionType.income;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? AppTheme.incomeColor.withOpacity(0.2) : AppTheme.expenseColor.withOpacity(0.2),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
              ),
            ),
            title: Text(t.description),
            subtitle: Text(CurrencyFormatter.formatDate(t.date)),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
