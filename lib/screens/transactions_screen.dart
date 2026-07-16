import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTransactions = ref.watch(filteredTransactionsProvider);
    final filterState = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search reason, category, or amount',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                ref.read(filterProvider.notifier).updateSearchQuery(val);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: DateFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_filterLabel(filter)),
                    selected: filterState.dateFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(filterProvider.notifier).updateDateFilter(filter);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return TransactionCard(
                        transaction: tx,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditTransactionScreen(transaction: tx),
                            ),
                          );
                        },
                        onDelete: () {
                          ref.read(transactionRepositoryProvider).deleteTransaction(tx.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(DateFilter filter) {
    switch (filter) {
      case DateFilter.today: return 'Today';
      case DateFilter.thisWeek: return 'This Week';
      case DateFilter.thisMonth: return 'This Month';
      case DateFilter.custom: return 'All Time';
    }
  }
}
