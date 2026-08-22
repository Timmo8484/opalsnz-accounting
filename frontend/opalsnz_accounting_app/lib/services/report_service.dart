import '../models/reports.dart';
import 'api_client.dart';

class ReportService {
  ReportService(this._client);

  final ApiClient _client;

  Future<IncomeSummary> getIncomeSummary(DateTime fromDate, DateTime toDate) async {
    final json = await _client.get('/api/reports/income-summary', query: _range(fromDate, toDate));
    return IncomeSummary.fromJson(json as Map<String, dynamic>);
  }

  Future<HomeOfficeSummary> getHomeOfficeSummary(DateTime fromDate, DateTime toDate) async {
    final json = await _client.get('/api/reports/home-office-summary', query: _range(fromDate, toDate));
    return HomeOfficeSummary.fromJson(json as Map<String, dynamic>);
  }

  Future<GstPeriodSummary> getGstPeriodSummary(DateTime periodStart, DateTime periodEnd) async {
    final json = await _client.get(
      '/api/reports/gst-period-summary',
      query: {
        'periodStart': periodStart.toIso8601String().substring(0, 10),
        'periodEnd': periodEnd.toIso8601String().substring(0, 10),
      },
    );
    return GstPeriodSummary.fromJson(json as Map<String, dynamic>);
  }

  Future<DepreciationSchedule> getDepreciationSchedule(DateTime taxYearStart, DateTime taxYearEnd) async {
    final json = await _client.get(
      '/api/reports/depreciation-schedule',
      query: {
        'taxYearStart': taxYearStart.toIso8601String().substring(0, 10),
        'taxYearEnd': taxYearEnd.toIso8601String().substring(0, 10),
      },
    );
    return DepreciationSchedule.fromJson(json as Map<String, dynamic>);
  }

  Map<String, String> _range(DateTime fromDate, DateTime toDate) => {
        'fromDate': fromDate.toIso8601String().substring(0, 10),
        'toDate': toDate.toIso8601String().substring(0, 10),
      };
}
