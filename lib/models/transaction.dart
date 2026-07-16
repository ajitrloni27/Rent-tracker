import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;

  @enumerated
  late TransactionType type;

  late String reason;
  late String category;
  late DateTime date;
  
  String? notes;

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum TransactionType {
  credit,
  debit,
}
