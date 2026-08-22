import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/home_office_expense/home_office_expense_bloc.dart';
import '../bloc/expense_category/expense_category_bloc.dart';
import '../models/expense_category.dart';
import '../models/home_office_expense_entry.dart';

class HomeOfficeExpensesPage extends StatefulWidget {
  const HomeOfficeExpensesPage({super.key});

  @override
  State<HomeOfficeExpensesPage> createState() => _HomeOfficeExpensesPageState();
}

class _HomeOfficeExpensesPageState extends State<HomeOfficeExpensesPage> {
  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');
  static final _date = DateFormat('d MMM y');

  @override
  void initState() {
    super.initState();
    context.read<HomeOfficeExpenseBloc>().add(HomeOfficeExpenseStarted());
    context.read<ExpenseCategoryBloc>().add(ExpenseCategoryStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Office Expenses'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog(context)),
        ],
      ),
      body: BlocBuilder<HomeOfficeExpenseBloc, HomeOfficeExpenseState>(
        builder: (context, state) {
          if (state.status == HomeOfficeExpenseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('No entries yet. Tap + to add one.'));
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = state.items[index];
              return ListTile(
                title: Text('${e.expenseCategoryName} - ${_currency.format(e.grossAmount)}'),
                subtitle: Text(
                  '${_date.format(e.entryDate)} - ${e.claimPercent.toStringAsFixed(0)}% claim'
                  '${e.hasGst ? ' (incl. GST)' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currency.format(e.claimableAmount)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<HomeOfficeExpenseBloc>().add(HomeOfficeExpenseDeleted(e.id)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final bloc = context.read<HomeOfficeExpenseBloc>();
    final categories = context.read<ExpenseCategoryBloc>().state.items;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an expense category in Settings first.')),
      );
      return;
    }

    final amountController = TextEditingController();
    var category = categories.first;
    var entryDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Add home office expense'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ExpenseCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: c, child: Text('${c.name} (${c.defaultClaimPercent.toStringAsFixed(0)}%)')),
                  ],
                  onChanged: (v) => setState(() => category = v!),
                ),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Gross amount (incl. GST if applicable)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                bloc.add(HomeOfficeExpenseAdded(HomeOfficeExpenseUpsertRequest(
                  expenseCategoryId: category.id,
                  entryDate: entryDate,
                  grossAmount: double.parse(amountController.text),
                )));
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
