import 'package:flutter/foundation.dart';
import 'expense.dart';
import 'expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  double _monthlyBudget = 0.0; // Start with 0 instead of 2000

  List<Expense> get expenses => _expenses;
  double get monthlyBudget => _monthlyBudget;
  double get totalSpent => _expenseService.getTotalSpent();
  double get remainingBudget => monthlyBudget - totalSpent;
  Map<String, double> get categoryTotals => _expenseService.getCategoryTotals();

  Future<void> initialize() async {
    await _expenseService.init();
    _expenses = _expenseService.getExpenses();
    
    // Load saved budget from local storage
    final savedBudget = await _expenseService.getSavedBudget();
    _monthlyBudget = savedBudget;
    
    notifyListeners();
  }

  Future<void> addExpense(double amount, String category, String description, DateTime date) async {
    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      description: description,
      date: date,
    );
    
    await _expenseService.addExpense(newExpense);
    _expenses = _expenseService.getExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
    _expenses = _expenseService.getExpenses();
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await _expenseService.saveBudget(budget);
    notifyListeners();
  }
}