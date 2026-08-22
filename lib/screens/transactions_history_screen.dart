import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';
import '../core/theme.dart';

class TransactionsHistoryScreen extends ConsumerStatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  ConsumerState<TransactionsHistoryScreen> createState() => _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends ConsumerState<TransactionsHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    
    final filteredTransactions = transactions.where((t) {
      if (_filter == 'Income') return t.type == TransactionType.income;
      if (_filter == 'Expense') return t.type == TransactionType.expense;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Income', child: Text('Income')),
              const PopupMenuItem(value: 'Expense', child: Text('Expense')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: filteredTransactions.isEmpty
          ? const Center(
              child: Text(
                'No transactions found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.separated(
              itemCount: filteredTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = filteredTransactions[index];
                final isIncome = t.type == TransactionType.income;
                return Dismissible(
                  key: ValueKey(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this transaction?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    ref.read(transactionProvider.notifier).deleteTransaction(t.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                  },
                  child: ListTile(
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
                  ),
                );
              },
            ),
    );
  }
}
