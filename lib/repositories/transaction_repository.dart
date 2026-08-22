import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../database/database_service.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dbService = ref.watch(databaseProvider);
  return TransactionRepository(dbService.isar);
});

class TransactionRepository {
  final Isar isar;

  TransactionRepository(this.isar);

  Future<int> addTransaction(Transaction transaction) async {
    return await isar.writeTxn(() async {
      return await isar.transactions.put(transaction);
    });
  }

  Future<int> updateTransaction(Transaction transaction) async {
    return await isar.writeTxn(() async {
      return await isar.transactions.put(transaction);
    });
  }

  Future<bool> deleteTransaction(int id) async {
    return await isar.writeTxn(() async {
      return await isar.transactions.delete(id);
    });
  }

  Future<List<Transaction>> getAllTransactions() async {
    final transactions = await isar.transactions.where().findAll();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> clearAll() async {
    return await isar.writeTxn(() async {
      await isar.transactions.clear();
    });
  }
}
