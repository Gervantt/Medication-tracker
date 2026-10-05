import 'dart:io';

import 'package:dio/dio.dart';
import 'package:medtrack/core/error/failure.dart';

extension DioFailureMapper on DioException {
  Failure toFailure() => switch (type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => const TimeoutFailure(),
    DioExceptionType.connectionError => const NetworkFailure(),
    DioExceptionType.cancel => const CancelledFailure(),
    DioExceptionType.badResponse => switch (response?.statusCode) {
      HttpStatus.notFound => const NotFoundFailure(),
      HttpStatus.tooManyRequests => const RateLimitFailure(),
      final statusCode => ServerFailure(statusCode),
    },
    DioExceptionType.unknown when error is SocketException =>
      const NetworkFailure(),
    DioExceptionType.badCertificate ||
    DioExceptionType.unknown => UnexpectedFailure(error ?? this),
  };
}
