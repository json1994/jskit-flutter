import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:keyboard_actions/keyboard_actions_item.dart';

enum ModalPosition { center, bottom }

class JsTools {
  /// 生成随机色
  static Color get generateRandomColor => Color.fromARGB(
      255,
      Random.secure().nextInt(220),
      Random.secure().nextInt(220),
      Random.secure().nextInt(220));

  /// 生成 6-11 位随机字符串
  static String get generateRandomString =>
      generateRandomStringByLength(length: Random.secure().nextInt(6) + 5);

  /// 生成指定长度随机字符串
  static String generateRandomStringByLength({int length = 10}) {
    const characters =
        '1234567890AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  static String getMd5(String org) => md5.convert(utf8.encode(org)).toString();

  /// 从底部弹出Widget
  static Future<T?> showSheetWidget<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    ModalPosition position = ModalPosition.bottom,
    barrierDismissible = true,
  }) async {
    return await showGeneralDialog<T?>(
        context: context,
        barrierColor: Colors.black12,
        useRootNavigator: true,
        barrierDismissible: barrierDismissible,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation1.drive(tween),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: GestureDetector(
                onTap: barrierDismissible
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Container(
                  color: Colors.transparent,
                  alignment: position == ModalPosition.bottom
                      ? Alignment.bottomCenter
                      : Alignment.center,
                  child: GestureDetector(onTap: () {}, child: builder(context),),
                ),
              ),
            ),
          );
        });
  }

  static Future<T?> showDropDownWidget<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    AlignmentGeometry? alignment = Alignment.bottomCenter,
    barrierDismissible = true,
  }) async {
    return await showGeneralDialog<T?>(
        context: context,
        barrierColor: Colors.black12,
        useRootNavigator: true,
        barrierDismissible: barrierDismissible,
        barrierLabel: "",
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation1.drive(tween),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: GestureDetector(
                onTap: barrierDismissible
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : null,
                child: Container(
                  color: Colors.transparent,
                  alignment: alignment,
                  child: GestureDetector(child: builder(context), onTap: () {},),
                ),
              ),
            ),
          );
        });
  }

  static KeyboardActionsConfig textFieldConfig(
      {required List<FocusNode> nodes,
      BuildContext? context,
      String? doneString,
      Color? background}) {
    return KeyboardActionsConfig(
        keyboardBarColor: background ?? const Color(0xfff2f2f2),
        defaultDoneWidget: Text(
          doneString ?? 'done',
          style:
              context != null ? Theme.of(context).textTheme.labelMedium : null,
        ),
        actions: [...nodes.map((e) => KeyboardActionsItem(focusNode: e))]);
  }

  /// [object]  解析的对象
  /// [deep]  递归的深度，用来获取缩进的空白长度
  /// [isObject] 用来区分当前map或list是不是来自某个字段，则不用显示缩进。单纯的map或list需要添加缩进
  static String logObj(dynamic object, int deep, {bool isObject = false}) {
    var buffer = StringBuffer();
    var nextDeep = deep + 1;
    if (object is Map) {
      var list = object.keys.toList();
      if (!isObject) {//如果map来自某个字段，则不需要显示缩进
        buffer.write(_getDeepSpace(deep));
      }
      buffer.write("{");
      if (list.isEmpty) {//当map为空，直接返回‘}’
        buffer.write("}");
      }else {
        buffer.write("\n");
        for (int i = 0; i < list.length; i++) {
          buffer.write("${_getDeepSpace(nextDeep)}\"${list[i]}\":");
          buffer.write(logObj(object[list[i]], nextDeep, isObject: true));
          if (i < list.length - 1) {
            buffer.write(",");
            buffer.write("\n");
          }
        }
        buffer.write("\n");
        buffer.write("${_getDeepSpace(deep)}}");
      }
    } else if (object is List) {
      if (!isObject) {//如果list来自某个字段，则不需要显示缩进
        buffer.write(_getDeepSpace(deep));
      }
      buffer.write("[");
      if (object.isEmpty) {//当list为空，直接返回‘]’
        buffer.write("]");
      }else {
        buffer.write("\n");
        for (int i = 0; i < object.length; i++) {
          buffer.write(logObj(object[i], nextDeep));
          if (i < object.length - 1) {
            buffer.write(",");
            buffer.write("\n");
          }
        }
        buffer.write("\n");
        buffer.write("${_getDeepSpace(deep)}]");
      }
    } else if (object is String) {//为字符串时，需要添加双引号并返回当前内容
      buffer.write("\"$object\"");
    } else if (object is num || object is bool) {//为数字或者布尔值时，返回当前内容
      buffer.write(object);
    }  else {//如果对象为空，则返回null字符串
      buffer.write("null");
    }
    return buffer.toString();
  }
  ///获取缩进空白符
  static String _getDeepSpace(int deep) {
    var tab = StringBuffer();
    for (int i = 0; i < deep; i++) {
      tab.write("\t");
    }
    return tab.toString();
  }
}

extension FormatTime on Duration? {
  String get timeString {
    if (this is Duration) {
      final minutes =
          this!.inMinutes.remainder(Duration.minutesPerHour).toString();
      final seconds = this
          ?.inSeconds
          .remainder(Duration.secondsPerMinute)
          .toString()
          .padLeft(2, '0');
      return this!.inHours > 0
          ? "${this?.inHours}:${minutes.padLeft(2, "0")}:$seconds"
          : "$minutes:$seconds";
    }
    return '';
  }
}
extension LogFormat on Object? {

}
