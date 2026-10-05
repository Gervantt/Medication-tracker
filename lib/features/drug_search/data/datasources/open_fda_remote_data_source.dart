import 'package:dio/dio.dart';
import 'package:medtrack/features/drug_search/data/models/drug_label_dto.dart';

/// openFDA Drug Label API. No API key is needed; without one the limit is
/// 240 requests per minute and 1000 per day per IP address.
class OpenFdaRemoteDataSource {
  const OpenFdaRemoteDataSource(this._dio);

  static const baseUrl = 'https://api.fda.gov';
  static const searchLimit = 10;

  final Dio _dio;

  /// Brand or generic name matches; a space between terms means OR.
  /// Throws [DioException]; openFDA answers 404 when nothing matches.
  Future<DrugLabelsResponseDto> searchByName(String name) {
    final term = _sanitize(name);
    return _search(
      'openfda.brand_name:"$term" openfda.generic_name:"$term"',
      limit: searchLimit,
    );
  }

  Future<DrugLabelsResponseDto> getById(String id) =>
      _search('id:"${_sanitize(id)}"', limit: 1);

  Future<DrugLabelsResponseDto> _search(String search, {required int limit}) {
    return _dio
        .get<Map<String, dynamic>>(
          '/drug/label.json',
          queryParameters: {'search': search, 'limit': limit},
        )
        .then((response) => DrugLabelsResponseDto.fromJson(response.data!));
  }

  /// Quotes and backslashes would break out of the quoted search term.
  String _sanitize(String value) => value.replaceAll(RegExp(r'["\\]'), ' ');
}
