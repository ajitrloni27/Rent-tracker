import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../database/isar_service.dart';
import '../repositories/transaction_repository.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TransactionRepository(isarService);
});

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions().map((transactions) {
    transactions.sort((a, b) => b.date.compareTo(a.date)); // descending by date
    return transactions;
  });
});

class TransactionStats {
  final double totalCredit;
  final double totalDebit;
  final double balance;

  TransactionStats({
    required this.totalCredit,
    required this.totalDebit,
    required this.balance,
  });
}

final transactionStatsProvider = Provider<TransactionStats>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  
  double credit = 0;
  double debit = 0;

  for (var t in transactions) {
    if (t.type == TransactionType.credit) {
      credit += t.amount;
    } else {
      debit += t.amount;
    }
  }

  return TransactionStats(
    totalCredit: credit,
    totalDebit: debit,
    balance: credit - debit,
  );
});
