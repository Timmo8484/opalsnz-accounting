import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/report/report_bloc.dart';
import '../utils/tax_year.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  static final _currency = NumberFormat.currency(locale: 'en_NZ', symbol: r'$');

  @override
  void initState() {
    super.initState();
    final (start, end) = TaxYear.current();
    context.read<ReportBloc>().add(ReportRequested(start, end));
  }

  @override
  Widget build(BuildContext context) {
    final (start, end) = TaxYear.current();
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports - tax year ${start.year}/${end.year}'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.status != ReportStatus.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ReportSection(
                title: 'Income summary',
                rows: [
                  for (final t in state.incomeSummary!.streamTotals)
                    (t.incomeStream.label, _currency.format(t.total)),
                  (
                    'GST collected',
                    _currency.format(state.incomeSummary!.totalGst),
                  ),
                  (
                    'Grand total',
                    _currency.format(state.incomeSummary!.grandTotal),
                  ),
                ],
              ),
              _ReportSection(
                title: 'Home office claimable',
                rows: [
                  for (final c in state.homeOfficeSummary!.categoryTotals)
                    (
                      c.expenseCategoryName,
                      _currency.format(c.claimableAmount),
                    ),
                  (
                    'Total claimable GST',
                    _currency.format(
                      state.homeOfficeSummary!.totalClaimableGst,
                    ),
                  ),
                  (
                    'Total claimable',
                    _currency.format(
                      state.homeOfficeSummary!.totalClaimableAmount,
                    ),
                  ),
                ],
              ),
              _ReportSection(
                title: 'GST (year to date)',
                rows: [
                  (
                    'Output GST (collected on sales)',
                    _currency.format(state.gstPeriodSummary!.outputGst),
                  ),
                  (
                    'Input GST (claimed on expenses)',
                    _currency.format(state.gstPeriodSummary!.inputGst),
                  ),
                  (
                    state.gstPeriodSummary!.netGst >= 0
                        ? 'Net GST payable'
                        : 'Net GST refund',
                    _currency.format(state.gstPeriodSummary!.netGst.abs()),
                  ),
                ],
              ),
              _ReportSection(
                title: 'Depreciation schedule',
                rows: [
                  for (final l in state.depreciationSchedule!.lines)
                    (
                      l.assetDescription,
                      _currency.format(l.depreciationAmount),
                    ),
                  (
                    'Total depreciation',
                    _currency.format(
                      state.depreciationSchedule!.totalDepreciation,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            if (rows.isEmpty) const Text('No data for this tax year yet.'),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(label), Text(value)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
