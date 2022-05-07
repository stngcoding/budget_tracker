import 'package:budget_tracker/models/transaction_item.dart';
import 'package:budget_tracker/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class BudgetService extends ChangeNotifier {
  double getBudget() => LocalStorageService().getBudget();
  double getBalance() => LocalStorageService().getBalance();
  List<TransactionItem> get items => LocalStorageService().getAllTransactions();

  set budget(double value) {
    LocalStorageService().saveBudget(value);
    notifyListeners();
  }

  void addItem(TransactionItem item) {
    LocalStorageService().saveTransactionItem(item);
    notifyListeners();
  }

  void deleteItem(TransactionItem item) {
    final localStorage = LocalStorageService();
    //Call our localstorage service to delete item
    localStorage.deleteTransactionItem(item);
    notifyListeners();
  }
}
