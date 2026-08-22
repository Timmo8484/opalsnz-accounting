import '../models/business_purchase.dart';
import 'api_client.dart';

class BusinessPurchaseService {
  BusinessPurchaseService(this._client);

  final ApiClient _client;

  Future<List<BusinessPurchase>> getAll({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final query = <String, String>{
      if (fromDate != null)
        'fromDate': fromDate.toIso8601String().substring(0, 10),
      if (toDate != null) 'toDate': toDate.toIso8601String().substring(0, 10),
    };
    final json =
        await _client.get(
              '/api/business-purchases',
              query: query.isEmpty ? null : query,
            )
            as List;
    return json
        .map((e) => BusinessPurchase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BusinessPurchase> create(BusinessPurchase purchase) async {
    final json = await _client.post(
      '/api/business-purchases',
      body: purchase.toRequestJson(),
    );
    return BusinessPurchase.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/api/business-purchases/$id');
}
