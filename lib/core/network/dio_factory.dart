import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medtrack/core/network/http_log_interceptor.dart';

abstract final class DioFactory {
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);

  static Dio create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
      ),
    );
    if (kDebugMode) dio.interceptors.add(HttpLogInterceptor());
    return dio;
  }
}
