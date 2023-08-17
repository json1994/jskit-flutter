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
      if (Platform.isIOS) {
        options.headers["X-Platform"] = "Ios";
      } else if (Platform.isAndroid) {
        options.headers["X-Platform"] = "Android";
      } else {
        options.headers["X-Platform"] = "Web";
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

  String fmt(dynamic o, int lv, {String sp = ' '}) {
    String str = '';
    String pre = sp * lv;
    if (o is Map) {
      str += '{\n';
      for (var item in o.keys) {
        str += '$pre$sp"$item":${fmt(o[item], lv + 1)},\n';
      }
      str = str.replaceRange(str.length - 2, str.length, '\n');
      str += '$pre}';
      return str;
    }
    if (o is String) {
      return '"$o"';
    }
    if (o is num) {
      return o.toString();
    }
    if (o is List) {
      str += '[';
      bool isF = true;
      for (var item in o) {
        if (isF) {
          str += '${fmt(item, lv + 1)},\n';
          isF = false;
        } else {
          str += '$pre$sp${fmt(item, lv + 1)},\n';
        }
      }
      str = str.replaceRange(str.length - 2, str.length, '\n');
      str += '$pre]';
      return str;
    }
    if (o is bool) {
      return o ? 'true' : 'false';
    }
    return 'null';
  }

  String sortString(dynamic data) {
    if (data == null) return '';
    var allKeys = data.keys.toList();
    allKeys.sort();
    var str = '';
    for (var i = 0; i < allKeys.length; i++) {
      var key = allKeys[i];
      var value = data[key];
      if (i == allKeys.length - 1) {
        str += "$key=$value";
      } else {
        str += "$key=$value&";
      }
    }
    return str;
  }

  static String generateRandomString(int length) {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();

    return randomString;
  }

  // @override
  // void onError(DioError err, ErrorInterceptorHandler handler) {
  //   if (err.response?.statusCode == 422) {
  //     handler.resolve(err.response!);
  //     return;
  //   }
  //   print(err);
  //   super.onError(err, handler);
  // }
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 500 || err.response?.statusCode == 401) {
      handler.resolve(err.response!);
      return;
    }
    super.onError(err, handler);
  }
}
