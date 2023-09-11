import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_error_interceptor/error_interceptor.dart';

class HttpConfig {
  HttpConfig._();
  static final HttpConfig _instance = HttpConfig._();
  static HttpConfig get instance => _instance;
  factory HttpConfig() => _instance;

  HttpErrorIntercepter? intercepter;

  init() {
    intercepter = HttpErrorIntercepter(
        isNoDefendListFunctionOn: true,
        isWhiteListFunctionOn: true,

        /// 白名单接口,
        /// errorCodes为null时,所有ApiError都不反应
        whiteListApi: [HttpApiEntity('api/whitelist/domain.json', null)],

        /// 不设置防御,不做容错措施.
        /// 出错之后,不做处理,会继续往上抛错误
        noDefendListApi: [HttpApiEntity('api/nodefence/domain.json', null)],
        defaultCompletion: ((e) {
          if (e.message?.isNotEmpty == true) {
            // showToast(e.message ?? '');
          }
        }),

        ///对接口,特殊错误码,特殊处理
        /// 例: 当报错发现是
        errorApiPlan: {
          'api/errorplan/four_one_two_error_plan.json': {
            412: (error) {
              // showToast('这是four_one_two_error_plan接口发送的412错误喔');
            }
          }
        },

        /// 对某个特殊错误码做处理
        errorCodePlan: {
          /// 例: 401错误,未登录
          401: (error) {
            /// 本地接口过期
            //  gotoLogin();
          },
        });
  }
}

void main() {
  HttpConfig.instance.init();
  var dio = Dio();
  var baseApi = 'http://baidu.com';
  var testRelateApi = '/api/doi';
  var fullPath = baseApi + testRelateApi;
  dio.interceptors.add(InterceptorsWrapper(
    onError: (e, handler) {
      var error = ApiError(
          apiUri: testRelateApi,
          code: e.response?.statusCode ?? 0,
          message: e.message);
      HttpConfig.instance.intercepter?.processError(error);
    },
  ));
  dio.get(fullPath);
}
