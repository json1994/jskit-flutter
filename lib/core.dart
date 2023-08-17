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
  Future<void> init({String? baseUrl, List<Interceptor>? interceptors}) async {
    /// 设置请求url
    this.baseUrl = baseUrl ?? this.baseUrl;

    /// 初始化Dio实例
    if (this.baseUrl != null) {
     await DioUtil().initNet(baseUrl: this.baseUrl!);
     interceptors?.forEach((element) {
       DioUtil().dio?.interceptors.add(element);
     });
    }
  }
}