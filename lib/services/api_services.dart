import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '/models/expense.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 10), // Increased to 10 seconds
    receiveTimeout: Duration(seconds: 10), // Increased to 10 seconds
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  ));

  ApiService() {
    dio.interceptors
        .add(LogInterceptor(responseBody: true)); // Add logging interceptor
  }

  Future<List<Expense>> fetchExpenses() async {
    debugPrint('Fetching expenses...');

    try {
      final response = await dio.get('/expenses');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        debugPrint('Zindagi');
        debugPrint('Big fan');

        if (data.isEmpty) {
          debugPrint('Umair Ali No expenses found.');
          return [];
        } else {
          List<Expense> expenses = [];
          for (var element in data) {
            debugPrint('ali ${element}');
            Category? category;
            switch (element['category']) {
              case 'food':
                category = Category.food;
                break;

              case 'travel':
                category = Category.travel;
                break;

              case 'movie':
                category = Category.leisure;
                break;
              default:
                category = Category.work;
            }
            expenses.add(Expense(
              id: element['_id'],
                title: element['title'],
                amount: element['amount'],
                category: category,
                date: DateTime.parse(element['date'])));
            debugPrint("zaibi $element ");
          }
          return expenses;
        }
      } else {
        debugPrint('Failed to load expenses: ${response.statusCode}');
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load expenses: ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      debugPrint('Dio error fetching expenses: ${e.message}');
      throw Exception('Failed to load expenses: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      throw Exception('Failed to load expenses: $e');
    }
  }

  Expense fromJson(Map<String, dynamic> json) {
    debugPrint('zaa $json');
    return Expense(
      title: json['title'],
      amount: json['amount'],
      category: Category.values
          .firstWhere((e) => e.toString() == 'Category.${json['category']}'),
      date: DateTime.parse(json['date']),
    );
  }

  Future<Expense> addExpense(Expense expense) async {
    try {
      
      final response = await dio.post(
        '/expenses',
        data: jsonEncode(expense.toJson()),
      );
      debugPrint('Add expense response: ${response.statusCode}');

      if (response.statusCode == 201) {
        return fromJson(response.data);
      } else {
        debugPrint('Failed to add expense: ${response.statusCode}');
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to add expense: ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      debugPrint('Dio error adding expense: ${e.message}');
      throw Exception('Failed to add expense: ${e.message}');
    } catch (e) {
      debugPrint('Error adding expense: $e');
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    debugPrint('hello abu $id');
    try {
      final response = await dio.delete('/expenses/$id');
      debugPrint('Delete expense response: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Failed to delete expense: ${response.statusCode}');
        throw DioError(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to delete expense: ${response.statusCode}',
        );
      }
    } on DioError catch (e) {
      debugPrint('Dio error deleting expense: ${e.message}');
      throw Exception('Failed to delete expense: ${e.message}');
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      throw Exception('Failed to delete expense: $e');
    }
  }
}
