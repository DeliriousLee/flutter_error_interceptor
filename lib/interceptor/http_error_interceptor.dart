

import 'package:flutter_error_interceptor/interceptor/api_error.dart';

/// 错误处理拦截
class HttpErrorIntercepter {
  /// 对某个api建立白名单,特殊机制
  List<HttpWhiteListEntity>? whiteListApi;

  /// 特殊处理
  Map<int, ErrorintercepltorCompletion> errorPlan;

  /// 默认处理方式
  ErrorintercepltorCompletion defaultCompletion;

  /// 白名单功能开关
  bool isWhiteListFunctionOn;

  HttpErrorIntercepter(
      {this.whiteListApi,
      this.isWhiteListFunctionOn = false,
      required this.defaultCompletion,
      required this.errorPlan});

  processError(ApiError error) {
    /// 白名单不处理
    if (isWhiteListFunctionOn && isWhiteListError(error)) {
      return;
    }
    if (errorPlan.containsKey(error.code)) {
      errorPlan[error.code]?.call(error);
      return;
    }
    defaultCompletion.call(error);
  }

  /// 是在白名单中的错误,忽略
  bool isWhiteListError(ApiError error) {
    var result = false;
    for (var white in whiteListApi ?? []) {
      if (error.apiUri == white.api) {
        for (var errorItem in white.errorCodes ?? []) {
          if (errorItem == error.code) {
            return true;
          }
        }
      }
    }
    return result;
  }
}

/// 白名单错误实体
/// notes:对某些api需要屏蔽特定的errorCode
class HttpWhiteListEntity {
  String? api;
  List<int>? errorCodes;
  HttpWhiteListEntity(this.api, this.errorCodes);
}

/// 错误回调
typedef ErrorintercepltorCompletion = Function(ApiError);

class ErrorInterceptorCompletion {
  int? errorCode;
  ErrorintercepltorCompletion? completion;
  ErrorInterceptorCompletion({this.completion, this.errorCode});
}
