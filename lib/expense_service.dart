import 'package:hive/hive.dart';
import 'expense.dart';

class ExpenseService {
  static const String _boxName = 'expenses';
  static const String _budgetBox = 'budget';
  late Box<Expense> _expensesBox;
  late Box<double> _budgetBoxInstance;

  Future<void> init() async {
    _expensesBox = await Hive.openBox<Expense>(_boxName);
    _budgetBoxInstance = await Hive.openBox<double>(_budgetBox);
  }

  List<Expense> getExpenses() {
    return _expensesBox.values.toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _expensesBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _expensesBox.delete(id);
  }

  double getTotalSpent() {
    return _expensesBox.values.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getCategoryTotals() {
    Map<String, double> categoryTotals = {};
    
    for (var expense in _expensesBox.values) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    
    return categoryTotals;
  }

  // Budget management methods
  Future<void> saveBudget(double budget) async {
    await _budgetBoxInstance.put('monthly_budget', budget);
  }

  Future<double> getSavedBudget() async {
    return _budgetBoxInstance.get('monthly_budget') ?? 0.0;
  }
}