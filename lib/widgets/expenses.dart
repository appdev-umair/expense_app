import 'dart:math';

import 'package:flutter/material.dart';
import '/models/expense.dart';
import '/services/api_services.dart';
import '/widgets/add_expense.dart';
import '/widgets/charts/chart.dart';
import '/widgets/expenses_list/expenses_list.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final ApiService _apiService = ApiService(); // Instance of ApiService
  List<Expense> _registerExpenses = [];
  bool _isLoading = false; // Added to manage loading state

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    setState(() {
      _isLoading = true;
    });
    print('Umair Ali');
    try {
      final expenses = await _apiService.fetchExpenses();
      print('umair $expenses');
      setState(() {
        _registerExpenses = expenses;
      });
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      constraints: const BoxConstraints().copyWith(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddExpenseOverlay(
          onAddExpense: _addExpense,
        );
      },
    );
  }

  void _addExpense({required Expense expense}) async {
    debugPrint('zain ${expense.id}');
    setState(() {
      _isLoading = true;
    });
    try {
      debugPrint('umair ki jan: ${expense.id}');
      final newExpense = await _apiService.addExpense(expense);
      setState(() {
        _registerExpenses.add(newExpense);
      });
    } catch (e) {
      debugPrint('Error adding expense: $e');
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeExpense(Expense expense) async {
    debugPrint('umair ${expense.id}');

    final expenseIndex = _registerExpenses.indexOf(expense);
    setState(() {
      _registerExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Expense Deleted."),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              _registerExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );
    try {
      debugPrint('zain ki jan: ${expense.id}');

      await _apiService.deleteExpense(expense.id!);
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      // Optionally show an error message to the user
      setState(() {
        _registerExpenses.insert(expenseIndex, expense);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Widget content = const Center(child: Text("No Expense!"));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_registerExpenses.isNotEmpty) {
      content = ExpenseList(
        expenses: _registerExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter ExpenseTracker"),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registerExpenses),
                Expanded(child: content),
              ],
            )
          : Row(
              children: [
                Expanded(child: Chart(expenses: _registerExpenses)),
                Expanded(child: content),
              ],
            ),
    );
  }
}
