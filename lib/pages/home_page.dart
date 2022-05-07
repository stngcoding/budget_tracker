import 'package:budget_tracker/models/transaction_item.dart';
import 'package:budget_tracker/view_models/BudgetViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddTransactionDialog(
                itemtoAdd: (transactionItem) {
                  final budgetService =
                      Provider.of<BudgetService>(context, listen: false);
                  budgetService.addItem(transactionItem);
                  // setState(() {
                  //   items.add(transactionItem);
                  // });
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: screenSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Consumer<BudgetService>(
                    builder: (context, value, child) {
                      final balance = value.getBalance();
                      final budget = value.getBudget();
                      double percentage = balance / budget;
                      if (percentage < 0) {
                        percentage = 0;
                      }
                      if (percentage > 1) {
                        percentage = 1;
                      }
                      return CircularPercentIndicator(
                        radius: screenSize.width / 2,
                        lineWidth: 10,
                        percent: percentage,
                        backgroundColor: Colors.white,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "\$" + balance.toString().split(".")[0],
                              style: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "Balance",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "Budget: \$" + budget.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        progressColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<BudgetService>(
                  builder: ((context, value, child) {
                    return ListView.builder(
                      itemBuilder: ((context, index) {
                        return TxCard(txItem: value.items[index]);
                      }),
                      itemCount: value.items.length,
                      shrinkWrap: true,
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TxCard extends StatelessWidget {
  final TransactionItem txItem;
  const TxCard({required this.txItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Text("Delete Item"),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final budgetViewModel = Provider.of<BudgetService>(
                          context,
                          listen: false,
                        );
                        budgetViewModel.deleteItem(txItem);
                        Navigator.pop(context);
                      },
                      child: const Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No"),
                    ),
                  ],
                ),
              ),
            );
          }),
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  offset: const Offset(0, 25),
                  blurRadius: 50),
            ],
          ),
          padding: const EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Text(
                txItem.name,
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              Text(
                (!txItem.isExpense ? "+" : "-") +
                    "\$" +
                    txItem.amount.toString(),
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionItem) itemtoAdd;
  const AddTransactionDialog({required this.itemtoAdd, Key? key})
      : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController itemTitleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool _isExpenseController = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Text(
                "Add an expense",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: itemTitleController,
                decoration: const InputDecoration(hintText: "Name"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(hintText: "Amount in \$"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Is expense?"),
                  Switch.adaptive(
                    value: _isExpenseController,
                    onChanged: (b) {
                      setState(() {
                        _isExpenseController = b;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty &&
                        itemTitleController.text.isNotEmpty) {
                      widget.itemtoAdd(
                        TransactionItem(
                          name: itemTitleController.text,
                          isExpense: _isExpenseController,
                          amount: double.parse(amountController.text),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"))
            ],
          ),
        ),
      ),
    );
  }
}
