import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/business_purchase/business_purchase_bloc.dart';
import '../models/business_purchase.dart';

class BusinessPurchasesPage extends StatefulWidget {
  const BusinessPurchasesPage({super.key});

  @override
  State<BusinessPurchasesPage> createState() => _BusinessPurchasesPageState();
}

class _BusinessPurchasesPageState extends State<BusinessPurchasesPage> {
  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');
  static final _date = DateFormat('d MMM y');

  @override
  void initState() {
    super.initState();
    context.read<BusinessPurchaseBloc>().add(BusinessPurchaseStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Purchases'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog(context)),
        ],
      ),
      body: BlocBuilder<BusinessPurchaseBloc, BusinessPurchaseState>(
        builder: (context, state) {
          if (state.status == BusinessPurchaseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('No purchases yet. Tap + to add one.'));
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = state.items[index];
              return ListTile(
                title: Text(p.description),
                subtitle: Text(
                  '${p.purchaseType.label} - ${_date.format(p.purchaseDate)}'
                  '${p.isCapitalAsset ? ' - capital asset' : ''}'
                  '${p.isTradingStockPurchase ? ' - trading stock' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currency.format(p.amountExclGst + p.gstAmount)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<BusinessPurchaseBloc>().add(BusinessPurchaseDeleted(p.id)),
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
    final bloc = context.read<BusinessPurchaseBloc>();
    final descriptionController = TextEditingController();
    final supplierController = TextEditingController();
    final amountController = TextEditingController();
    final gstController = TextEditingController(text: '0');
    var purchaseType = PurchaseType.opalRoughStock;
    var isCapitalAsset = false;
    var isTradingStockPurchase = true;
    var purchaseDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Add business purchase'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<PurchaseType>(
                    value: purchaseType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      for (final t in PurchaseType.values) DropdownMenuItem(value: t, child: Text(t.label)),
                    ],
                    onChanged: (v) => setState(() {
                      purchaseType = v!;
                      isTradingStockPurchase = purchaseType == PurchaseType.opalRoughStock;
                      isCapitalAsset = purchaseType == PurchaseType.tool;
                    }),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: supplierController,
                    decoration: const InputDecoration(labelText: 'Supplier (optional)'),
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount (excl. GST)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                  ),
                  TextFormField(
                    controller: gstController,
                    decoration: const InputDecoration(labelText: 'GST amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                  ),
                  CheckboxListTile(
                    title: const Text('Capital asset (needs depreciating)'),
                    value: isCapitalAsset,
                    onChanged: (v) => setState(() => isCapitalAsset = v ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Trading stock purchase'),
                    value: isTradingStockPurchase,
                    onChanged: (v) => setState(() => isTradingStockPurchase = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                bloc.add(BusinessPurchaseAdded(BusinessPurchase(
                  id: 0,
                  purchaseDate: purchaseDate,
                  purchaseType: purchaseType,
                  description: descriptionController.text,
                  supplier: supplierController.text.isEmpty ? null : supplierController.text,
                  amountExclGst: double.parse(amountController.text),
                  gstAmount: double.parse(gstController.text),
                  isCapitalAsset: isCapitalAsset,
                  isTradingStockPurchase: isTradingStockPurchase,
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
