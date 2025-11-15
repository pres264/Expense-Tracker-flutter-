import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';

class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Food', 'Transport', 'Entertainment', 'Shopping', 'Bills', 'Healthcare', 'Other'];

  Map<String, dynamic> _getCategoryStyle(String category) {
    switch (category) {
      case 'Food':
        return {'icon': Icons.restaurant, 'color': Colors.orange};
      case 'Transport':
        return {'icon': Icons.directions_car, 'color': Colors.blue};
      case 'Entertainment':
        return {'icon': Icons.movie, 'color': Colors.purple};
      case 'Shopping':
        return {'icon': Icons.shopping_bag, 'color': Colors.pink};
      case 'Bills':
        return {'icon': Icons.receipt, 'color': Colors.red};
      case 'Healthcare':
        return {'icon': Icons.medical_services, 'color': Colors.green};
      default:
        return {'icon': Icons.category, 'color': Colors.grey};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'All Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final expenses = _selectedFilter == 'All' 
              ? expenseProvider.expenses
              : expenseProvider.expenses.where((expense) => expense.category == _selectedFilter).toList();
          
          final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'All' ? 'No expenses yet' : 'No $_selectedFilter expenses',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'All' 
                        ? 'Add your first expense to get started'
                        : 'No expenses in this category',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilter = selected ? filter : 'All';
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue[800],
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFilter == 'All' ? 'Total Spent' : '$_selectedFilter Total',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\Ksh${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${expenses.length} ${expenses.length == 1 ? 'expense' : 'expenses'}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Expenses List
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final categoryStyle = _getCategoryStyle(expense.category);
                    
                    return Dismissible(
                      key: Key(expense.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text("Are you sure you want to delete this expense?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        expenseProvider.deleteExpense(expense.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Expense deleted'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: categoryStyle['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              categoryStyle['icon'],
                              color: categoryStyle['color'],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            expense.description,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                expense.category,
                                style: TextStyle(
                                  color: categoryStyle['color'],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                _formatDate(expense.date),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\Ksh${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[600],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${_formatDate(expense.date)}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}