import 'package:dio/dio.dart';
import 'dio_util.dart';

class ApiResponse<T> {
  ApiResponse({this.data, required this.code, this.msg = 'success', this.total, this.e});
  T? data;
  final int code;
  String? msg;
  int? total;
  Object? e;
}

abstract class RequestInterface<T> {
  Future<ApiResponse<T>> execute();
  void cancel([Object? reason]) {}
  DioMethod get method => DioMethod.get;
  Object? get data => null;
  Options? get option;
  Map<String, dynamic>? get queryParameters => null;
  String get path;
}

class JSBaseRequest<T> extends RequestInterface<T> {
  late CancelToken _cancelToken;
  late String url;
  final Object? _data;
  final Map<String, dynamic>? _queryParameters;
  final DioMethod? _method;
  final T Function(Map<String, dynamic>) fromJson;
  final Duration timeout;

  JSBaseRequest({
    required this.url,
    required this.fromJson,
    Object? data,
    Map<String, dynamic>? parameters,
    DioMethod? method,
    this.timeout = const Duration(seconds: 30),
  }) : _data = data,
        _queryParameters = parameters,
        _method = method ?? DioMethod.get {
    _cancelToken = CancelToken();
  }

  @override
  String get path => url;
  @override
  Object? get data => _data;
  @override
  DioMethod get method => _method ?? DioMethod.get;
  @override
  Map<String, dynamic>? get queryParameters => _queryParameters;


  @override
  Future<ApiResponse<T>> execute({Dio? dio}) async {
    try {
      var ret = await DioUtil().request(
        path,
        cancelToken: _cancelToken,
        parmas: queryParameters,
        data: data,
        dio: dio,
        options: option?.copyWith(sendTimeout: timeout, receiveTimeout: timeout),
        method: method,
      );

      var validatedData = validate(ret);
      if (validatedData != null) {
        var convertedData = convert(validatedData);
        return ApiResponse(code: 200, data: convertedData);
      } else {
        return handleException(ret);
      }
    } catch (e) {
      return ApiResponse(code: -1, msg: 'request error', e: e);
    }
  }

  T? convert(dynamic data) {
    if (data is List) {
      return data.map((item) => fromJson(item as Map<String, dynamic>)).toList() as T;
    } else if (data is Map<String, dynamic>) {
      return fromJson(data);
    } else {
      throw FormatException('Unexpected data format: ${data.runtimeType}');
    }
  }

  ApiResponse<T> handleException(DioResult? data) {
    // 实现默认的错误处理逻辑
    return ApiResponse<T>(code: -200, msg: 'Unknown error');
  }

  dynamic validate(DioResult? response) {
    // 实现默认的验证逻辑
    if (response?.response != null) {
      return response?.response?.data;
    }
    return null;
  }
  @override
  // TODO: implement option
  Options? get option => null;

// ... 其他方法保持不变 ...
}

// 使用示例 - 可以处理单个对象或列表
/*class HealingEntityRequest extends JSBaseRequest<dynamic> {
  HealingEntityRequest({required String url}) : super(
    url: url,
    fromJson: HealingEntity.fromJson,
  );

  @override
  ApiResponse<dynamic> handleException(DioResult? data) {
    // 实现 HealingEntity 特定的错误处理逻辑
    return ApiResponse(code: -1, msg: 'HealingEntity request failed');
  }
}*/