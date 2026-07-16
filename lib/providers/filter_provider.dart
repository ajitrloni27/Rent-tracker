import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import 'transaction_provider.dart';

enum DateFilter { today, thisWeek, thisMonth, custom }

class FilterState {
  final DateFilter dateFilter;
  final String searchQuery;

  FilterState({
    this.dateFilter = DateFilter.thisMonth,
    this.searchQuery = '',
  });

  FilterState copyWith({
    DateFilter? dateFilter,
    String? searchQuery,
  }) {
    return FilterState(
      dateFilter: dateFilter ?? this.dateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return FilterState();
  }

  void updateDateFilter(DateFilter filter) {
    state = state.copyWith(dateFilter: filter);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(() {
  return FilterNotifier();
});

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  final filterState = ref.watch(filterProvider);

  return transactions.where((tx) {
    // Search query filter
    final matchesSearch = filterState.searchQuery.isEmpty ||
        tx.reason.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
        tx.category.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
        tx.amount.toString().contains(filterState.searchQuery);

    if (!matchesSearch) return false;

    // Date filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

    switch (filterState.dateFilter) {
      case DateFilter.today:
        return txDate.isAtSameMomentAs(today);
      case DateFilter.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return txDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
               txDate.isBefore(today.add(const Duration(days: 1)));
      case DateFilter.thisMonth:
        return txDate.year == today.year && txDate.month == today.month;
      case DateFilter.custom:
        // Assume custom is handled separately or shows all for now
        return true;
    }
  }).toList();
});
