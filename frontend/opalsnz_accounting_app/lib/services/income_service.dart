import '../models/income_entry.dart';
import 'api_client.dart';

class IncomeService {
  IncomeService(this._client);

  final ApiClient _client;

  Future<List<IncomeEntry>> getAll({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = <String, String>{
      if (fromDate != null)
        'fromDate': fromDate.toIso8601String().substring(0, 10),
      if (toDate != null) 'toDate': toDate.toIso8601String().substring(0, 10),
    };
    final json =
        await _client.get('/api/income', query: query.isEmpty ? null : query)
            as List;
    return json
        .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<IncomeEntry> create(IncomeEntry entry) async {
    final json = await _client.post('/api/income', body: entry.toRequestJson());
    return IncomeEntry.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/api/income/$id');
}
