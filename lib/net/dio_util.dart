
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';

import 'dio_interceptor.dart';

enum DioMethod {
  get,
  post,
  put,
  delete,
  patch,
  head,
}

class DioUtil {
  /// 连接超时时间
  static const int CONNECT_TIMEOUT = 10;

  /// 响应超时时间
  static const int RECEIVE_TIMEOUT = 10;

  /// 请求的URL前缀 通过外部调用initNet() 初始化请求框架
  /// online
  // static String BASE_URL = "https://xxx.xx.xx";

  /// 是否开启网络缓存,默认false
  static bool CACHE_ENABLE = false;

  /// 最大缓存时间(按秒), 默认缓存七天,可自行调节
  static int MAX_CACHE_AGE = 7 * 24 * 60 * 60;

  /// 最大缓存条数(默认一百条)
  static int MAX_CACHE_COUNT = 100;

  Dio? get dio => _dio;

  Dio? _dio;

  /// 取消请求token
  final CancelToken _cancelToken = CancelToken();

  /// 私有构造函数
  DioUtil._internal();
  Future<void> initNet({required String baseUrl}) async {

    BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: CONNECT_TIMEOUT),
        receiveTimeout: const Duration(seconds: RECEIVE_TIMEOUT));
    _dio = Dio(options);

    // add interceptors
    _dio?.interceptors.add(DioInterceptor());
    _dio?.interceptors.add(AwesomeDioInterceptor());
  }

  /// 保存单利
  static final DioUtil _singleton = DioUtil._internal();

  /// 工厂构造方法
  factory DioUtil() => _singleton;

  Future<T?> request<T>(String path,
      {DioMethod method = DioMethod.get,
      Map<String, dynamic>? parmas,
      data,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    const _methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head'
    };
    assert(_dio != null, "请调用init方法初始化网络请求");
    options ??= Options(method: _methodValues[method]);

    try {
      Response response = await _dio!.request(path,
          data: data,
          queryParameters: parmas,
          cancelToken: cancelToken ?? _cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response.data;
    } catch (e) {
      // debugInfo('请求失败 $e');
      return null;
    }

  }
}

//定义一个top-level（全局）变量，页面引入该文件后可以直接使用 api
var dioUtil = DioUtil();
