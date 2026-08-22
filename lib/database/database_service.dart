import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError(); // Initialized in main.dart
});

class DatabaseService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [TransactionSchema],
      directory: dir.path,
    );
  }
}
