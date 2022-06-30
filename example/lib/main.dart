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
        whiteListApi: [
          HttpWhiteListEntity('/api/doi', [503, 404])
        ],
        defaultCompletion: (error) {
          /// showToast(error.message);
        },
        errorPlan: {
          /// 可能是未登录等
          503: (error) {
            // Route.to("LoginPage");
          }
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
