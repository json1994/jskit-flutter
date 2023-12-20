import 'package:dio/dio.dart';

import 'dio_util.dart';

class ApiResponse<T> {
  ApiResponse({this.data, required this.code, this.msg = 'success', this.total, this.e});
  T? data;
  final int code;
  String? msg;
  int? total;
  // 异常信息
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
/// T: 返回数据值
/// K: 接口返回的待序列化的数据
class JSBaseRequest<T, K> extends RequestInterface<T> {
  late CancelToken _cancelToken;
  late String url;
  final Object? _data;
  final Map<String, dynamic>? _queryParameters;
  final DioMethod? _method;
  JSBaseRequest(
      {required this.url,
      Object? data,
      Map<String, dynamic>? parameters,
      DioMethod? method})
      : _data = data,
        _queryParameters = parameters,
        _method = method ?? DioMethod.get {
    _cancelToken = CancelToken();
  }

  CancelToken get cancelToken => _cancelToken;

  @override
  String get path => url;

  @override
  Future<ApiResponse<T>> execute({Dio? dio}) async {
    try {
      var ret = await DioUtil().request(path,
          cancelToken: _cancelToken,
          parmas: queryParameters,
          data: data,
          dio: dio,
          options: option,
          method: method);

      var d = validate(ret);
      if (d != null) {
        var dd = covert(d);
        return ApiResponse(code: 200, data: dd);
      }else {
        var r = handleException(ret);
        return r;
      }
    } catch (e) {
      return ApiResponse(code: -1, msg: 'request error', e: e);
    }
  }

  T? covert(K? data) {
    return data as T;
  }
  ApiResponse<T> handleException(DioResult? data) {
    return ApiResponse<T>(code: -200);
  }
  K? validate(DioResult? response) {
    return null;
  }

  @override
  DioMethod get method => _method ?? DioMethod.get;

  @override
  Object? get data => _data;

  @override
  Map<String, dynamic>? get queryParameters => _queryParameters;

  @override
  void cancel([Object? reason]) {
    if (_cancelToken.isCancelled) {
      _cancelToken.cancel(reason);
    }
  }
  @override
  Options? get option => null;
}
//
// class CustomReq<T,K> extends JSBaseRequest<T,K> {
//   CustomReq({required super.url});
//
//   @override
//   bool validate(K? response) {
//     if (response is Map<String, dynamic>) {
//       return response['code'] == 200;
//     }
//     return super.validate(response);
//   }
//   @override
//   ApiResponse<T> handleException(K? data) {
//     if (data is Map<String, dynamic>) {
//       return ApiResponse(code: -1, msg: data['msg']);
//     }
//     return super.handleException(data);
//   }
//
// }
//
// class TestReq extends CustomReq<int, Map<String, dynamic>> {
//   TestReq({required super.url});
//
//   @override
//   int? covert(Map<String, dynamic>? data) {
//     // TODO: implement covert
//     return super.covert(data);
//   }
// }


