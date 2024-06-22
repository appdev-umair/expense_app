import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();
DateFormat dateFormat = DateFormat.yMd();

enum Category { food, travel, leisure, work }

const Map<Category, IconData> categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work,
};

class Expense {
  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String? id; // UUID for the expense
  final String title;
  final double amount;
  final Category category;
  final DateTime date;

  String get formattedDate {
    return dateFormat.format(date);
  }

  // Convert Expense object to JSON format for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category.toString().split('.').last,
      'date': date.toIso8601String(),
    };
  }
}

class ExpenseBucket {
  ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
