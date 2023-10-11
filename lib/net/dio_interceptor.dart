import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

class DioInterceptor extends QueuedInterceptorsWrapper {
  Function(RequestOptions options)? hookOnRequest;
  DioInterceptor({
    this.hookOnRequest,
    InterceptorSendCallback? onRequest,
    InterceptorSuccessCallback? onResponse,
    InterceptorErrorCallback? onError,
  }) : super(onRequest: onRequest, onResponse: onResponse, onError: onError);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      if (hookOnRequest != null) {
        hookOnRequest!(options);
      }

      /// 添加用户Token
      ///

      handler.next(options);
    } catch (e) {
      assert(() {
        print(e);
        return false;
      }());
      super.onRequest(options, handler);
    }
  }
  String _getNormalizedUrl(String baseUrl, String queryParams) {
    if (baseUrl.contains("?")) {
      return baseUrl + "&$queryParams";
    } else {
      return baseUrl + "?$queryParams";
    }
  }

  String _getQueryParams(Map<String, dynamic> map) {
    String result = "";
    map.forEach((key, value) {
      result += "$key=${Uri.encodeComponent(value)}&";
    });
    return result;
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      if (response.data['errcode'] == 401) {}
      if (response.data['errcode'] == -5) {}
    } catch (e) {}
    handler.next(response);
    // super.onResponse(response, handler);
  }




  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) {
  //   if (err.response?.statusCode == 500 || err.response?.statusCode == 401) {
  //     handler.resolve(err.response!);
  //     return;
  //   }
  //   super.onError(err, handler);
  // }
}
