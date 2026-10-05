import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/data/datasources/open_fda_remote_data_source.dart';
import 'package:medtrack/features/drug_search/data/repositories/drug_repository_impl.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';

/// Answers every request with a fixed status and body and remembers it.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200, this.body = '{}', this.error});

  final int statusCode;
  final String body;
  final DioExceptionType? error;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (error != null) {
      throw DioException(requestOptions: options, type: error!);
    }
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  final fixture = File('test/fixtures/open_fda_label_search.json')
      .readAsStringSync();

  (DrugRepositoryImpl, _FakeAdapter) build(_FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: OpenFdaRemoteDataSource.baseUrl))
      ..httpClientAdapter = adapter;
    return (DrugRepositoryImpl(OpenFdaRemoteDataSource(dio)), adapter);
  }

  group('DrugRepositoryImpl.searchByName', () {
    test('queries brand and generic names and maps labels', () async {
      final (repository, adapter) = build(_FakeAdapter(body: fixture));

      final result = await repository.searchByName('Lip"itor');

      final query = adapter.lastRequest!.queryParameters;
      expect(
        query['search'],
        'openfda.brand_name:"Lip itor" openfda.generic_name:"Lip itor"',
      );
      expect(query['limit'], OpenFdaRemoteDataSource.searchLimit);

      final labels = (result as Ok<List<DrugLabel>>).value;
      expect(labels, hasLength(2));
      final rx = labels.first;
      expect(rx.brandName, 'Lipitor');
      expect(rx.manufacturer, 'Viatris Specialty LLC');
      expect(
        rx.purpose,
        '1 INDICATIONS AND USAGE LIPITOR is indicated '
        'to reduce the risk of MI.',
      );
      expect(
        rx.warnings,
        'Boxed warning text.\n\n5 WARNINGS AND PRECAUTIONS Myopathy.',
      );
      final otc = labels.last;
      expect(otc.brandName, isNull);
      expect(otc.name, 'IBUPROFEN');
      expect(otc.purpose, 'Pain reliever/fever reducer');
      expect(otc.sideEffects, isNull);
    });

    test('treats 404 as an empty result', () async {
      final (repository, _) = build(
        _FakeAdapter(
          statusCode: 404,
          body: '{"error":{"code":"NOT_FOUND","message":"No matches found!"}}',
        ),
      );

      final result = await repository.searchByName('zzz');

      expect((result as Ok<List<DrugLabel>>).value, isEmpty);
    });

    test('maps rate limiting and missing network to failures', () async {
      final (rateLimited, _) = build(_FakeAdapter(statusCode: 429));
      final (offline, _) = build(
        _FakeAdapter(error: DioExceptionType.connectionError),
      );

      expect(
        await rateLimited.searchByName('advil'),
        isA<Err<List<DrugLabel>>>().having(
          (e) => e.failure,
          'failure',
          isA<RateLimitFailure>(),
        ),
      );
      expect(
        await offline.searchByName('advil'),
        isA<Err<List<DrugLabel>>>().having(
          (e) => e.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
    });

    test('reports an unexpected response shape', () async {
      final (repository, _) = build(
        _FakeAdapter(body: '{"results":[{"no_id":true}]}'),
      );

      final result = await repository.searchByName('advil');

      expect(
        result,
        isA<Err<List<DrugLabel>>>().having(
          (e) => e.failure,
          'failure',
          isA<UnexpectedFailure>(),
        ),
      );
    });
  });

  group('DrugRepositoryImpl.getById', () {
    test('returns the label or NotFoundFailure', () async {
      final (found, adapter) = build(_FakeAdapter(body: fixture));
      final (missing, _) = build(_FakeAdapter(statusCode: 404));

      final result = await found.getById('rx-label-1');

      expect(adapter.lastRequest!.queryParameters['search'], 'id:"rx-label-1"');
      expect((result as Ok<DrugLabel>).value.id, 'rx-label-1');
      expect(
        await missing.getById('nope'),
        isA<Err<DrugLabel>>().having(
          (e) => e.failure,
          'failure',
          isA<NotFoundFailure>(),
        ),
      );
    });
  });
}
