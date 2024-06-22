import 'package:flutter/material.dart';
import '/models/expense.dart';

class AddExpenseOverlay extends StatefulWidget {
  const AddExpenseOverlay({super.key, required this.onAddExpense});
  final void Function({required Expense expense}) onAddExpense;
  @override
  State<AddExpenseOverlay> createState() {
    return _AddExpenseOverlayState();
  }
}

class _AddExpenseOverlayState extends State<AddExpenseOverlay> {
  final _textController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  void _showDatePicker() {
    var now = DateTime.now();
    var firstDate = DateTime(now.year - 1);
    showDatePicker(
            context: context,
            initialDate: now,
            firstDate: firstDate,
            lastDate: now)
        .then((value) {
      setState(() {
        _selectedDate = value;
      });
    });
  }

  void _validateInputData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_textController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid Input"),
          content: const Text(
              "Please enter a valid title, amount date or category!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
      return;
    }
    widget.onAddExpense(
      expense: Expense(
          title: _textController.text,
          amount: enteredAmount,
          category: _selectedCategory,
          date: _selectedDate!),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 48, 16, keyboardSpace + 16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text("Title"),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefix: Text("\$ "),
                      label: Text("Amount"),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _selectedDate == null
                          ? "No Date Selected"
                          : dateFormat.format(_selectedDate!),
                    ),
                    IconButton(
                      onPressed: _showDatePicker,
                      icon: const Icon(Icons.calendar_month),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                DropdownButton(
                    value: _selectedCategory,
                    items: Category.values.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    }),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _textController.clear();
                    _amountController.clear();
                  },
                  child: const Text("Cancle"),
                ),
                ElevatedButton(
                  onPressed: _validateInputData,
                  child: const Text("Save Text"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
