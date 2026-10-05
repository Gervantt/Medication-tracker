import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/network/dio_failure_mapper.dart';

void main() {
  final options = RequestOptions(path: '/drug/label.json');

  DioException exception(
    DioExceptionType type, {
    int? statusCode,
    Object? error,
  }) {
    return DioException(
      requestOptions: options,
      type: type,
      error: error,
      response: statusCode == null
          ? null
          : Response<dynamic>(requestOptions: options, statusCode: statusCode),
    );
  }

  group('DioFailureMapper', () {
    test('maps timeouts', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(exception(type).toFailure(), isA<TimeoutFailure>());
      }
    });

    test('maps missing connection', () {
      expect(
        exception(DioExceptionType.connectionError).toFailure(),
        isA<NetworkFailure>(),
      );
      expect(
        exception(
          DioExceptionType.unknown,
          error: const SocketException('offline'),
        ).toFailure(),
        isA<NetworkFailure>(),
      );
    });

    test('maps HTTP statuses', () {
      expect(
        exception(DioExceptionType.badResponse, statusCode: 404).toFailure(),
        isA<NotFoundFailure>(),
      );
      expect(
        exception(DioExceptionType.badResponse, statusCode: 429).toFailure(),
        isA<RateLimitFailure>(),
      );
      expect(
        exception(DioExceptionType.badResponse, statusCode: 503).toFailure(),
        isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503),
      );
    });

    test('maps cancellation and unknown errors', () {
      expect(
        exception(DioExceptionType.cancel).toFailure(),
        isA<CancelledFailure>(),
      );
      expect(
        exception(DioExceptionType.unknown, error: 'boom').toFailure(),
        isA<UnexpectedFailure>(),
      );
    });
  });
}
