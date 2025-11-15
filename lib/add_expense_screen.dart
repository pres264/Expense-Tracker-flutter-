import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.blue},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink},
    {'name': 'Bills', 'icon': Icons.receipt, 'color': Colors.red},
    {'name': 'Healthcare', 'icon': Icons.medical_services, 'color': Colors.green},
    {'name': 'Other', 'icon': Icons.category, 'color': Colors.grey},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue[800],
            colorScheme: ColorScheme.light(primary: Colors.blue[800]!),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      
      Provider.of<ExpenseProvider>(context, listen: false).addExpense(
        amount,
        _selectedCategory,
        _descriptionController.text,
        _selectedDate,
      );

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Expense added successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Add Expense',
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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _submitExpense,
              icon: Icon(Icons.check, size: 20),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[800],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input
              _buildInputCard(
                icon: Icons.attach_money,
                title: 'Amount',
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 18),
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 20),

              // Category Selection
              _buildInputCard(
                icon: Icons.category,
                title: 'Category',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: category['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                category['icon'],
                                color: category['color'],
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              category['name'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Description Input
              _buildInputCard(
                icon: Icons.description,
                title: 'Description',
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter description...',
                    border: InputBorder.none,
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 20),

              // Date Selection
              _buildInputCard(
                icon: Icons.calendar_today,
                title: 'Date',
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(Icons.calendar_month, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Quick Amount Buttons
              _buildQuickAmounts(),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required IconData icon, required String title, required Widget child}) {
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmounts() {
    final quickAmounts = [500, 1000, 2000, 5000, 10,000];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amounts',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickAmounts.map((amount) {
            return ActionChip(
              label: Text('\$$amount'),
              onPressed: () {
                _amountController.text = amount.toString();
              },
              backgroundColor: Colors.blue[50],
              labelStyle: TextStyle(color: Colors.blue[800]),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}