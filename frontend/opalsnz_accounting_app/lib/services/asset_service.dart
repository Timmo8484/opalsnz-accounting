import '../models/asset.dart';
import 'api_client.dart';

class AssetService {
  AssetService(this._client);

  final ApiClient _client;

  Future<List<Asset>> getAll() async {
    final json = await _client.get('/api/assets') as List;
    return json.map((e) => Asset.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Asset> create(Asset asset) async {
    final json = await _client.post('/api/assets', body: asset.toRequestJson());
    return Asset.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/api/assets/$id');

  Future<List<AssetDepreciationYear>> getDepreciationYears(int assetId) async {
    final json =
        await _client.get('/api/assets/$assetId/depreciation-years') as List;
    return json
        .map((e) => AssetDepreciationYear.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AssetDepreciationYear> createDepreciationYear({
    required int assetId,
    required DateTime taxYearStart,
    required DateTime taxYearEnd,
    int monthsOwnedThisYear = 12,
  }) async {
    final json = await _client.post(
      '/api/assets/depreciation-years',
      body: {
        'assetId': assetId,
        'taxYearStart': taxYearStart.toIso8601String().substring(0, 10),
        'taxYearEnd': taxYearEnd.toIso8601String().substring(0, 10),
        'monthsOwnedThisYear': monthsOwnedThisYear,
      },
    );
    return AssetDepreciationYear.fromJson(json as Map<String, dynamic>);
  }
}
