import 'dart:developer';

import 'package:dio/dio.dart';

/// Logs method, URL, status and duration of every request.
/// Bodies are not logged: they can be large and are not needed to debug.
class HttpLogInterceptor extends Interceptor {
  static const _startKey = 'request_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    log('→ ${options.method} ${options.uri}', name: 'http');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log(
      '← ${response.statusCode} ${response.requestOptions.uri} '
      '(${_elapsed(response.requestOptions)} ms)',
      name: 'http',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      '✕ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.uri} (${_elapsed(err.requestOptions)} ms)',
      name: 'http',
    );
    handler.next(err);
  }

  int? _elapsed(RequestOptions options) {
    final start = options.extra[_startKey];
    return start is DateTime
        ? DateTime.now().difference(start).inMilliseconds
        : null;
  }
}
