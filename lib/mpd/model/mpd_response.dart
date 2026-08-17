import 'dart:async';

import 'package:flutter/foundation.dart';

class MpdResponse<T> {
  MpdResponseSuccess<T>? _success;
  MpdResponseError? _error;
  MpdResponse._();

  factory MpdResponse.error(String error, Exception e) =>
      MpdResponse._().._error = MpdResponseError(error, e);
  factory MpdResponse.success(T data) {
    return MpdResponse._().._success = MpdResponseSuccess<T>(data);
  }

  static Future<MpdResponse<X>> fromFunction<X>(
    FutureOr<X> Function() func,
  ) async {
    try {
      var data = await func();
      return MpdResponse._().._success = MpdResponseSuccess<X>(data);
    } catch (e) {
      if (e is! Exception) {
        rethrow;
      }
      return MpdResponse._().._error = MpdResponseError(e.toString(), e);
    }
  }

  bool get isValid => _error == null;
  String? get error => _error?.error;
  T get data {
    try {
      return _success!.data;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      if (_error?.exception != null) {
        throw _error!.exception;
      }
      rethrow;
    }
  }
}

class MpdResponseError {
  final String error;
  final Exception exception;
  const MpdResponseError(this.error, this.exception);
}

class MpdResponseSuccess<T> {
  final T data;
  const MpdResponseSuccess(this.data);
}
