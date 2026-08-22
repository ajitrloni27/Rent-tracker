import 'package:isar/isar.dart';

part 'transaction.g.dart';

enum TransactionType {
  income,
  expense,
}

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @enumerated
  late TransactionType type;

  late double amount;

  late String description;

  late DateTime date;

  late DateTime createdAt;
}
