import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/report/report_bloc.dart';
import '../utils/tax_year.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
        title: Text('Dashboard - tax year ${start.year}/${end.year}'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.status != ReportStatus.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final income = state.incomeSummary;
          final homeOffice = state.homeOfficeSummary;
          final gst = state.gstPeriodSummary;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _SummaryCard(
                  title: 'Income (year to date)',
                  value: _currency.format(income?.grandTotal ?? 0),
                  subtitle: 'incl. ${_currency.format(income?.totalGst ?? 0)} GST',
                ),
                _SummaryCard(
                  title: 'Home office claimable',
                  value: _currency.format(homeOffice?.totalClaimableAmount ?? 0),
                  subtitle: 'incl. ${_currency.format(homeOffice?.totalClaimableGst ?? 0)} GST',
                ),
                _SummaryCard(
                  title: 'Net GST (year to date)',
                  value: _currency.format(gst?.netGst ?? 0),
                  subtitle: (gst?.netGst ?? 0) >= 0 ? 'Payable to IRD' : 'Refund due',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value, required this.subtitle});

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
