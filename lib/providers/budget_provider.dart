import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget_model.dart';
import '../config/constants.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  BudgetProvider() {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      _isLoading = true;
      notifyListeners();

      final box = await Hive.openBox<BudgetModel>(
        AppConstants.budgetBox,
      );
      _budgets = box.values.where((b) => b.isActive).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading budgets: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBudget(BudgetModel budget) async {
    try {
      final box = await Hive.openBox<BudgetModel>(
        AppConstants.budgetBox,
      );
      await box.add(budget);
      _budgets.add(budget);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding budget: $e');
      return false;
    }
  }

  Future<bool> updateBudget(BudgetModel budget) async {
    try {
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating budget: $e');
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting budget: $e');
      return false;
    }
  }

  BudgetModel? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere((b) => b.category == category);
    } catch (e) {
      return null;
    }
  }
}