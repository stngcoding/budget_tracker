import 'package:budget_tracker/models/transaction_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static const String transactionBoxKey = "transactionBox";
  static const String balanceBoxKey = "balanceBox";
  static const String budgetBoxKey = "budgetBox";

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> initializeHive() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionItemAdapter());
    }

    await Hive.openBox<double>(budgetBoxKey);
    await Hive.openBox<TransactionItem>(transactionBoxKey);
    await Hive.openBox<double>(balanceBoxKey);
  }

  void saveTransactionItem(TransactionItem transaction) {
    Hive.box<TransactionItem>(transactionBoxKey).add(transaction);
    saveBalance(transaction);
  }

  void deleteTransactionItem(TransactionItem transaction) {
    //Get a list of transactions
    final transactions = Hive.box<TransactionItem>(transactionBoxKey);
    //Create a map
    final Map<dynamic, TransactionItem> map = transactions.toMap();
    dynamic desiredKey;
    //For each key in thew map, check if the transaction is the one to delete
    map.forEach((key, value) {
      if (value.name == transaction.name) desiredKey = key;
    });
    //If found delete it
    transactions.delete(desiredKey);
    //Update the balance
    saveBalanceOnDelete(transaction);
  }

  Future<void> saveBalanceOnDelete(TransactionItem item) async {
    final balanceBox = Hive.box<double>(balanceBoxKey);
    final currentBalance = balanceBox.get("balance") ?? 0.0;

    balanceBox.put("balance", currentBalance);
  }

  List<TransactionItem> getAllTransactions() {
    return Hive.box<TransactionItem>(transactionBoxKey).values.toList();
  }

  Future<void> saveBalance(TransactionItem item) async {
    final balanceBox = Hive.box<double>(balanceBoxKey);
    final currentBalance = balanceBox.get("balance") ?? 0.0;
    if (item.isExpense) {
      balanceBox.put("balance", currentBalance + item.amount);
    } else {
      balanceBox.put("balance", currentBalance - item.amount);
    }
  }

  double getBalance() {
    return Hive.box<double>(balanceBoxKey).get("balance") ?? 0.0;
  }

  double getBudget() {
    return Hive.box<double>(budgetBoxKey).get("budget") ?? 0.0;
  }

  Future<void> saveBudget(double budget) {
    return Hive.box<double>(budgetBoxKey).put("budget", budget);
  }
}
