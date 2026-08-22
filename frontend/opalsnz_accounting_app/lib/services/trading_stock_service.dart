import '../models/trading_stock_year.dart';
import 'api_client.dart';

class TradingStockService {
  TradingStockService(this._client);

  final ApiClient _client;

  Future<List<TradingStockYear>> getAll() async {
    final json = await _client.get('/api/trading-stock-years') as List;
    return json
        .map((e) => TradingStockYear.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TradingStockYear> create({
    required DateTime taxYearStart,
    required DateTime taxYearEnd,
    double? openingValue,
    required OpeningValueMethod openingValueMethod,
    double? closingValue,
    ClosingValueMethod? closingValueMethod,
    bool isFinalised = false,
    String? notes,
  }) async {
    final json = await _client.post(
      '/api/trading-stock-years',
      body: {
        'taxYearStart': taxYearStart.toIso8601String().substring(0, 10),
        'taxYearEnd': taxYearEnd.toIso8601String().substring(0, 10),
        'openingValue': openingValue,
        'openingValueMethod': openingValueMethod.wireValue,
        'closingValue': closingValue,
        'closingValueMethod': closingValueMethod?.wireValue,
        'isFinalised': isFinalised,
        'notes': notes,
      },
    );
    return TradingStockYear.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/api/trading-stock-years/$id');
}

class HistoricalStockPurchaseService {
  HistoricalStockPurchaseService(this._client);

  final ApiClient _client;

  Future<List<HistoricalStockPurchase>> getAll() async {
    final json = await _client.get('/api/historical-stock-purchases') as List;
    return json
        .map((e) => HistoricalStockPurchase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HistoricalStockPurchase> create(
    HistoricalStockPurchase purchase,
  ) async {
    final json = await _client.post(
      '/api/historical-stock-purchases',
      body: purchase.toRequestJson(),
    );
    return HistoricalStockPurchase.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) =>
      _client.delete('/api/historical-stock-purchases/$id');
}
