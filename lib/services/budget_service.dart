import 'package:budget_tracker/models/transaction_item.dart';
import 'package:flutter/material.dart';

class BudgetService extends ChangeNotifier {
  double _budget = 2000.0;

  double balance = 0.0;

  final List<TransactionItem> _items = [];

  List<TransactionItem> get items => _items;

  double get budget => _budget;

  void addItems(TransactionItem item) {
    _items.add(item);
    updateBalance(item);
    notifyListeners();
  }

  void updateBalance(TransactionItem item) {
    if (item.isExpense) {
      balance += item.amount;
    } else {
      balance -= item.amount;
    }
  }

  set budget(double value) {
    _budget = value;
    notifyListeners();
  }
}
