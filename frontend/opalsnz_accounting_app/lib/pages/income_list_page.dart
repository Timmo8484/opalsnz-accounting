import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/income/income_bloc.dart';
import '../models/income_entry.dart';

class IncomeListPage extends StatefulWidget {
  const IncomeListPage({super.key});

  @override
  State<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage> {
  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');
  static final _date = DateFormat('d MMM y');

  @override
  void initState() {
    super.initState();
    context.read<IncomeBloc>().add(IncomeStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
          if (state.status == IncomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == IncomeStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.items.isEmpty) {
            return const Center(
              child: Text('No income entries yet. Tap + to add one.'),
            );
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = state.items[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    entry.incomeStream == IncomeStream.opalSales
                        ? Icons.diamond_outlined
                        : Icons.code,
                  ),
                ),
                title: Text(entry.description),
                subtitle: Text(
                  '${entry.incomeStream.label} - ${_date.format(entry.entryDate)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currency.format(entry.totalAmount)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<IncomeBloc>().add(
                        IncomeEntryDeleted(entry.id),
                      ),
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
    final bloc = context.read<IncomeBloc>();
    final descriptionController = TextEditingController();
    final invoiceRefController = TextEditingController();
    final amountController = TextEditingController();
    final gstController = TextEditingController(text: '0');
    var stream = IncomeStream.softwareDevelopment;
    var entryDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Add income'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<IncomeStream>(
                    value: stream,
                    decoration: const InputDecoration(
                      labelText: 'Income stream',
                    ),
                    items: [
                      for (final s in IncomeStream.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: (v) => setState(() => stream = v!),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: invoiceRefController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice reference (optional)',
                    ),
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (excl. GST)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Enter a number'
                        : null,
                  ),
                  TextFormField(
                    controller: gstController,
                    decoration: const InputDecoration(labelText: 'GST amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Enter a number'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                bloc.add(
                  IncomeEntryAdded(
                    IncomeEntry(
                      id: 0,
                      incomeStream: stream,
                      entryDate: entryDate,
                      description: descriptionController.text,
                      invoiceReference: invoiceRefController.text.isEmpty
                          ? null
                          : invoiceRefController.text,
                      amountExclGst: double.parse(amountController.text),
                      gstAmount: double.parse(gstController.text),
                      totalAmount: 0,
                    ),
                  ),
                );
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
