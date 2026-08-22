import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense_category/expense_category_bloc.dart';
import '../models/expense_category.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseCategoryBloc>().add(ExpenseCategoryStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings - Home Office Expense Categories'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog(context)),
        ],
      ),
      body: BlocBuilder<ExpenseCategoryBloc, ExpenseCategoryState>(
        builder: (context, state) {
          if (state.status == ExpenseCategoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = state.items[index];
              return ListTile(
                title: Text(c.name),
                subtitle: Text('${c.defaultClaimPercent.toStringAsFixed(0)}% claim${c.hasGst ? ' - has GST' : ' - no GST'}'),
                trailing: Switch(
                  value: c.isActive,
                  onChanged: (v) => context.read<ExpenseCategoryBloc>().add(ExpenseCategoryUpdated(
                        c.id,
                        ExpenseCategory(
                          id: c.id,
                          name: c.name,
                          defaultClaimPercent: c.defaultClaimPercent,
                          hasGst: c.hasGst,
                          isActive: v,
                        ),
                      )),
                ),
                onTap: () => _showEditDialog(context, c),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) => _showUpsertDialog(context, title: 'Add category');

  void _showEditDialog(BuildContext context, ExpenseCategory category) =>
      _showUpsertDialog(context, title: 'Edit category', existing: category);

  void _showUpsertDialog(BuildContext context, {required String title, ExpenseCategory? existing}) {
    final bloc = context.read<ExpenseCategoryBloc>();
    final nameController = TextEditingController(text: existing?.name);
    final percentController = TextEditingController(text: existing?.defaultClaimPercent.toString() ?? '0');
    var hasGst = existing?.hasGst ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: percentController,
                  decoration: const InputDecoration(labelText: 'Default claim %'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
                CheckboxListTile(
                  title: const Text('Category has GST'),
                  value: hasGst,
                  onChanged: (v) => setState(() => hasGst = v ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final category = ExpenseCategory(
                  id: existing?.id ?? 0,
                  name: nameController.text,
                  defaultClaimPercent: double.parse(percentController.text),
                  hasGst: hasGst,
                  isActive: existing?.isActive ?? true,
                );
                if (existing == null) {
                  bloc.add(ExpenseCategoryAdded(category));
                } else {
                  bloc.add(ExpenseCategoryUpdated(existing.id, category));
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
