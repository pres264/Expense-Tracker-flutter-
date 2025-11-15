import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';

class HomeScreen extends StatelessWidget {
  void _showSetBudgetDialog(BuildContext context) {
    final TextEditingController budgetController = TextEditingController();
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Monthly Budget'),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Budget Amount (Ksh)',
            prefixText: 'Ksh ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(budgetController.text);
              if (budget != null && budget > 0) {
                expenseProvider.setMonthlyBudget(budget);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Budget set to Ksh ${budget.toStringAsFixed(2)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Set Budget'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSetBudgetDialog(context),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final totalSpent = expenseProvider.totalSpent;
          final monthlyBudget = expenseProvider.monthlyBudget;
          final remainingBudget = expenseProvider.remainingBudget;
          // Explicitly cast to double to fix the error
          final double progressValue = monthlyBudget > 0 ? (totalSpent / monthlyBudget) : 0.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Budget Overview Card - Now with explicit double types
                _buildBudgetCard(
                  context: context,
                  totalSpent: totalSpent,
                  monthlyBudget: monthlyBudget,
                  remainingBudget: remainingBudget,
                  progressValue: progressValue,
                ),
                
                SizedBox(height: 20),
                
                // Quick Actions
                _buildQuickActions(context),
                
                SizedBox(height: 20),
                
                // Category Overview
                _buildCategoryOverview(expenseProvider),
                
                SizedBox(height: 20),
                
                // Recent Expenses Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExpenseListScreen()),
                        );
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
                
                // Recent Expenses List
                _buildRecentExpenses(expenseProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  // Updated method with named parameters and explicit types
  Widget _buildBudgetCard({
    required BuildContext context,
    required double totalSpent,
    required double monthlyBudget,
    required double remainingBudget,
    required double progressValue,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[800]!,
            Colors.purple[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white70, size: 18),
                onPressed: () => _showSetBudgetDialog(context),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Ksh ${remainingBudget.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            monthlyBudget > 0 
                ? 'Remaining of Ksh ${monthlyBudget.toStringAsFixed(2)}'
                : 'Set your monthly budget',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 20),
          if (monthlyBudget > 0) ...[
            LinearProgressIndicator(
              value: progressValue > 1 ? 1 : progressValue,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                progressValue > 0.8 ? Colors.orange : Colors.green,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: Ksh ${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${(progressValue * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 10),
            Text(
              'Tap the edit icon to set your monthly budget',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add,
            label: 'Add Expense',
            color: Colors.blue[700]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              );
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.list_alt,
            label: 'All Expenses',
            color: Colors.green[600]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenseListScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOverview(ExpenseProvider expenseProvider) {
    final categoryTotals = expenseProvider.categoryTotals;
    
    if (categoryTotals.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: categoryTotals.entries.map((entry) {
              final double percentage = entry.value / expenseProvider.totalSpent;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCategoryColor(entry.key),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Ksh ${entry.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpenses(ExpenseProvider expenseProvider) {
    final recentExpenses = expenseProvider.expenses.take(5).toList();
    
    if (recentExpenses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first expense to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: recentExpenses.map((expense) {
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 20,
              ),
            ),
            title: Text(
              expense.description,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${expense.category} • ${_formatDate(expense.date)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Text(
              'Ksh ${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Entertainment': return Colors.purple;
      case 'Shopping': return Colors.pink;
      case 'Bills': return Colors.red;
      case 'Healthcare': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Entertainment': return Icons.movie;
      case 'Shopping': return Icons.shopping_bag;
      case 'Bills': return Icons.receipt;
      case 'Healthcare': return Icons.medical_services;
      default: return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}