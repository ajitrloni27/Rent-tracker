import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();

    
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [TransactionSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
  

  Future<void> saveTransaction(Transaction transaction) async {
    final isar = await db;
    isar.writeTxnSync(() {
      isar.transactions.putSync(transaction);
    });
  }

  Future<void> deleteTransaction(int id) async {
    final isar = await db;
    isar.writeTxnSync(() {
      isar.transactions.deleteSync(id);
    });
  }

  Future<void> clearAll() async {
    final isar = await db;
    isar.writeTxnSync(() {
      isar.transactions.clearSync();
    });
  }

  Stream<List<Transaction>> listenToTransactions() async* {
    final isar = await db;
    yield* isar.transactions.where().watch(fireImmediately: true);
  }

  Future<List<Transaction>> getAllTransactions() async {
    final isar = await db;
    return await isar.transactions.where().findAll();
  }
}
