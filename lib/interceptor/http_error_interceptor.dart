import 'api_error.dart';

/// 错误处理拦截
class HttpErrorIntercepter {
  /// 对某个api建立白名单,特殊机制
  List<HttpApiEntity>? whiteListApi;

  /// 某个api全部自己处理,相关error会全部抛出
  List<HttpApiEntity>? noDefendListApi;

  /// 特殊处理,对errorCode特殊处理
  Map<int, ErrorintercepltorCompletion> errorCodePlan;

  /// 特殊处理,对api domain特殊处理
  Map<String, Map<int, ErrorintercepltorCompletion>>? errorApiPlan;

  /// 默认处理方式
  ErrorintercepltorCompletion defaultCompletion;

  /// 白名单功能开关
  bool isWhiteListFunctionOn;

  /// 无保护功能开关,打开之后,noDefendListApi中的接口会向上抛出错误
  bool isNoDefendListFunctionOn;

  HttpErrorIntercepter(
      {this.whiteListApi,
      this.noDefendListApi,
      this.isWhiteListFunctionOn = false,
      this.isNoDefendListFunctionOn = false,
      this.errorApiPlan,
      required this.defaultCompletion,
      required this.errorCodePlan});

  processError(ApiError error) {
    /// 白名单不处理
    if (isWhiteListFunctionOn && isHitWhiteListErrorTarget(error)) {
      return;
    }

    /// 错误预案的优先级高于 无需防御接口
    if (errorCodePlan.containsKey(error.code)) {
      errorCodePlan[error.code]?.call(error);
      return;
    }

    /// 根据api复合code做特殊处理
    String? errorUri = error.apiUri;
    if (errorApiPlan?.containsKey(errorUri) == true) {
      var apiCodePlans = errorApiPlan?[errorUri];
      if (apiCodePlans?.containsKey(error.code) == true) {
        apiCodePlans?[error.code]?.call(error);
        return;
      }
    }

    /// 无需防御的接口开关打开,将该接口所有错误不处理向上抛出
    if (isNoDefendListFunctionOn && noDefendError(error)) {
      throw error;
    }

    defaultCompletion.call(error);
  }

  /// 白名单错误,是否中靶
  bool isHitWhiteListErrorTarget(ApiError error) {
    var result = false;
    for (var white in whiteListApi ?? []) {
      /// 相对接口路径中标
      if (error.apiUri == white.api) {
        /// 如果接口在白名单,且有白名单错误码,错误码匹配的时候放过该错误
        if (white.errorCodes != null) {
          for (var errorItem in white.errorCodes ?? []) {
            if (errorItem == error.code) {
              return true;
            }
          }
        } else {
          /// 如果接口在白名单,无错误码,放过该错误
          return true;
        }
      }
    }
    return result;
  }

  /// 自行处理接口错误
  bool noDefendError(ApiError error) {
    var result = false;
    for (var blackApi in noDefendListApi ?? []) {
      if (error.apiUri == blackApi.api) {
        return true;
      }
    }
    return result;
  }
}

/// 白名单错误实体
/// notes:对某些api需要屏蔽特定的errorCode
class HttpApiEntity {
  /// 相对域名
  String? api;

  // /// 标签
  // String? tag;
  // /// 是否打开标签功能,
  // bool ontag;
  List<int>? errorCodes;
  HttpApiEntity(this.api, this.errorCodes);
}

/// 错误回调
typedef ErrorintercepltorCompletion = Function(ApiError);

class ErrorInterceptorCompletion {
  int? errorCode;
  ErrorintercepltorCompletion? completion;
  ErrorInterceptorCompletion({this.completion, this.errorCode});
}
