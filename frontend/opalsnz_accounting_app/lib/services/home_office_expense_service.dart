import '../models/home_office_expense_entry.dart';
import 'api_client.dart';

class HomeOfficeExpenseService {
  HomeOfficeExpenseService(this._client);

  final ApiClient _client;

  Future<List<HomeOfficeExpenseEntry>> getAll({DateTime? fromDate, DateTime? toDate}) async {
    final query = <String, String>{
      if (fromDate != null) 'fromDate': fromDate.toIso8601String().substring(0, 10),
      if (toDate != null) 'toDate': toDate.toIso8601String().substring(0, 10),
    };
    final json = await _client.get('/api/home-office-expenses', query: query.isEmpty ? null : query) as List;
    return json.map((e) => HomeOfficeExpenseEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HomeOfficeExpenseEntry> create(HomeOfficeExpenseUpsertRequest request) async {
    final json = await _client.post('/api/home-office-expenses', body: request.toJson());
    return HomeOfficeExpenseEntry.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/api/home-office-expenses/$id');
}
