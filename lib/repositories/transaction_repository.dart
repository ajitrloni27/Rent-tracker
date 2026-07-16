import '../models/transaction.dart';
import '../database/isar_service.dart';

class TransactionRepository {
  final IsarService _isarService;

  TransactionRepository(this._isarService);

  Future<void> saveTransaction(Transaction transaction) =>
      _isarService.saveTransaction(transaction);

  Future<void> deleteTransaction(int id) => _isarService.deleteTransaction(id);

  Future<void> clearAll() => _isarService.clearAll();

  Stream<List<Transaction>> watchTransactions() =>
      _isarService.listenToTransactions();
      
  Future<List<Transaction>> getAllTransactions() => 
      _isarService.getAllTransactions();
}
