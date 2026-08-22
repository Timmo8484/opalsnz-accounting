import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/asset/asset_bloc.dart';
import '../models/asset.dart';
import '../services/asset_service.dart';
import '../utils/tax_year.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');
  static final _date = DateFormat('d MMM y');

  @override
  void initState() {
    super.initState();
    context.read<AssetBloc>().add(AssetStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets & Depreciation'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog(context)),
        ],
      ),
      body: BlocBuilder<AssetBloc, AssetState>(
        builder: (context, state) {
          if (state.status == AssetStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) {
            return const Center(child: Text('No assets yet. Tap + to add one.'));
          }
          return ListView.separated(
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final a = state.items[index];
              return ListTile(
                title: Text(a.description),
                subtitle: Text(
                  '${_date.format(a.purchaseDate)} - ${_currency.format(a.costExclGst)}'
                  '${a.isLowValueWriteoff ? ' - expensed immediately (\u2264\$1,000)' : ' - ${a.depreciationMethod.label} @ ${a.depreciationRate.toStringAsFixed(0)}%'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!a.isLowValueWriteoff)
                      TextButton(
                        onPressed: () => _showDepreciationDialog(context, a),
                        child: const Text('Depreciation'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => context.read<AssetBloc>().add(AssetDeleted(a.id)),
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
    final bloc = context.read<AssetBloc>();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    final rateController = TextEditingController(text: '20');
    var method = DepreciationMethod.diminishingValue;
    var purchaseDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Add asset'),
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
                  controller: costController,
                  decoration: const InputDecoration(labelText: 'Cost (excl. GST)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
                DropdownButtonFormField<DepreciationMethod>(
                  value: method,
                  decoration: const InputDecoration(labelText: 'Depreciation method'),
                  items: [
                    for (final m in DepreciationMethod.values) DropdownMenuItem(value: m, child: Text(m.label)),
                  ],
                  onChanged: (v) => setState(() => method = v!),
                ),
                TextFormField(
                  controller: rateController,
                  decoration: const InputDecoration(labelText: 'Depreciation rate % (per IR265)'),
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
                bloc.add(AssetAdded(Asset(
                  id: 0,
                  description: descriptionController.text,
                  purchaseDate: purchaseDate,
                  costExclGst: double.parse(costController.text),
                  depreciationMethod: method,
                  depreciationRate: double.parse(rateController.text),
                  isLowValueWriteoff: false,
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

  void _showDepreciationDialog(BuildContext context, Asset asset) {
    final assetService = context.read<AssetService>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Depreciation - ${asset.description}'),
        content: SizedBox(
          width: 400,
          child: FutureBuilder<List<AssetDepreciationYear>>(
            future: assetService.getDepreciationYears(asset.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              final years = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (years.isEmpty) const Text('No depreciation years recorded yet.'),
                  for (final y in years)
                    ListTile(
                      dense: true,
                      title: Text('${_date.format(y.taxYearStart)} - ${_date.format(y.taxYearEnd)}'),
                      subtitle: Text(
                        'Opening ${_currency.format(y.openingValue)} - Depreciation ${_currency.format(y.depreciationAmount)} - Closing ${_currency.format(y.closingValue)}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      final (start, end) = TaxYear.current();
                      await assetService.createDepreciationYear(
                        assetId: asset.id,
                        taxYearStart: start,
                        taxYearEnd: end,
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    child: const Text('Calculate current tax year'),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }
}
