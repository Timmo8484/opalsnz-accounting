import '../models/expense_category.dart';
import 'api_client.dart';

class ExpenseCategoryService {
  ExpenseCategoryService(this._client);

  final ApiClient _client;

  Future<List<ExpenseCategory>> getAll({bool includeInactive = false}) async {
    final json = await _client.get(
      '/api/expense-categories',
      query: {'includeInactive': includeInactive.toString()},
    ) as List;
    return json.map((e) => ExpenseCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExpenseCategory> create(ExpenseCategory category) async {
    final json = await _client.post('/api/expense-categories', body: category.toRequestJson());
    return ExpenseCategory.fromJson(json as Map<String, dynamic>);
  }

  Future<ExpenseCategory> update(int id, ExpenseCategory category) async {
    final json = await _client.put('/api/expense-categories/$id', body: category.toRequestJson());
    return ExpenseCategory.fromJson(json as Map<String, dynamic>);
  }
}
