import 'package:dio/dio.dart';

import 'net/dio_util.dart';

class JSCore {

  /// 私有构造函数
  JSCore._internal() {
    print('JSCore init');
  }
  /// 全局单例
  static final JSCore _singleton = JSCore._internal();

  /// 工厂构造方法
  factory JSCore() => _singleton;

  String? baseUrl;
  Future<Dio?> init({String? baseUrl, List<Interceptor>? interceptors, Function(RequestOptions options)? hookRequest, Dio? dio}) async {
    /// 设置请求url
    this.baseUrl = baseUrl ?? this.baseUrl;

    /// 初始化Dio实例
    if (this.baseUrl != null) {
     await DioUtil().initNet(baseUrl: this.baseUrl,dio: dio, hookRequest: hookRequest);
     interceptors?.forEach((element) {
       DioUtil().dio?.interceptors.insert(0, element);
     });
    }
    return DioUtil().dio;
  }
}