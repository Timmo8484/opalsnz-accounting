import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/trading_stock/trading_stock_bloc.dart';
import '../models/trading_stock_year.dart';
import '../utils/tax_year.dart';

class TradingStockPage extends StatefulWidget {
  const TradingStockPage({super.key});

  @override
  State<TradingStockPage> createState() => _TradingStockPageState();
}

class _TradingStockPageState extends State<TradingStockPage> {
  @override
  void initState() {
    super.initState();
    context.read<TradingStockBloc>().add(TradingStockStarted());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trading Stock (Opal Rough)'),
          bottom: const TabBar(tabs: [Tab(text: 'Tax years'), Tab(text: 'Pre-business purchases')]),
        ),
        body: BlocBuilder<TradingStockBloc, TradingStockState>(
          builder: (context, state) {
            if (state.status == TradingStockStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _YearsTab(years: state.years),
                _HistoryTab(purchases: state.historicalPurchases),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              final tabIndex = DefaultTabController.of(context).index;
              if (tabIndex == 0) {
                _showAddYearDialog(context);
              } else {
                _showAddHistoricalDialog(context);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showAddYearDialog(BuildContext context) {
    final bloc = context.read<TradingStockBloc>();
    final (start, end) = TaxYear.current();
    final openingValueController = TextEditingController();
    final closingValueController = TextEditingController();
    var openingMethod = OpeningValueMethod.priorYearClosing;
    var closingMethod = ClosingValueMethod.cost;
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('Trading stock year ${start.year}/${end.year}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<OpeningValueMethod>(
                  value: openingMethod,
                  decoration: const InputDecoration(labelText: 'Opening value method'),
                  items: [
                    for (final m in OpeningValueMethod.values) DropdownMenuItem(value: m, child: Text(m.label)),
                  ],
                  onChanged: (v) => setState(() => openingMethod = v!),
                ),
                if (openingMethod != OpeningValueMethod.priorYearClosing)
                  TextFormField(
                    controller: openingValueController,
                    decoration: const InputDecoration(
                      labelText: 'Opening value',
                      helperText: 'First year only - confirm with your accountant, see docs/tax',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                  ),
                TextFormField(
                  controller: closingValueController,
                  decoration: const InputDecoration(labelText: 'Closing value (leave blank until year end)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                DropdownButtonFormField<ClosingValueMethod>(
                  value: closingMethod,
                  decoration: const InputDecoration(labelText: 'Closing value method'),
                  items: [
                    for (final m in ClosingValueMethod.values) DropdownMenuItem(value: m, child: Text(m.label)),
                  ],
                  onChanged: (v) => setState(() => closingMethod = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                bloc.add(TradingStockYearAdded(
                  taxYearStart: start,
                  taxYearEnd: end,
                  openingValue: double.tryParse(openingValueController.text),
                  openingValueMethod: openingMethod,
                  closingValue: double.tryParse(closingValueController.text),
                  closingValueMethod: closingValueController.text.isEmpty ? null : closingMethod,
                ));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHistoricalDialog(BuildContext context) {
    final bloc = context.read<TradingStockBloc>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    var purchaseDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log pre-business opal purchase'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (e.g. bank statement reference)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              bloc.add(HistoricalStockPurchaseAdded(HistoricalStockPurchase(
                id: 0,
                purchaseDate: purchaseDate,
                description: descriptionController.text,
                amount: double.parse(amountController.text),
                notes: notesController.text.isEmpty ? null : notesController.text,
              )));
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _YearsTab extends StatelessWidget {
  const _YearsTab({required this.years});
  final List<TradingStockYear> years;

  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');
  static final _date = DateFormat('d MMM y');

  @override
  Widget build(BuildContext context) {
    if (years.isEmpty) {
      return const Center(child: Text('No trading stock years recorded yet.'));
    }
    return ListView.separated(
      itemCount: years.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final y = years[index];
        return ListTile(
          title: Text('${_date.format(y.taxYearStart)} - ${_date.format(y.taxYearEnd)}'),
          subtitle: Text(
            'Opening ${_currency.format(y.openingValue)}'
            '${y.closingValue != null ? ' - Closing ${_currency.format(y.closingValue!)}' : ' - closing not yet set'}'
            '${y.deductibleStockCost != null ? ' - Deductible ${_currency.format(y.deductibleStockCost!)}' : ''}',
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.purchases});
  final List<HistoricalStockPurchase> purchases;

  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');
  static final _date = DateFormat('d MMM y');

  @override
  Widget build(BuildContext context) {
    if (purchases.isEmpty) {
      return const Center(child: Text('No historical purchases logged yet.'));
    }
    return ListView.separated(
      itemCount: purchases.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = purchases[index];
        return ListTile(
          title: Text(p.description),
          subtitle: Text('${_date.format(p.purchaseDate)}${p.notes != null ? ' - ${p.notes}' : ''}'),
          trailing: Text(_currency.format(p.amount)),
        );
      },
    );
  }
}
