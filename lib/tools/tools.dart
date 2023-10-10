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
        '+-*=?1234567890AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
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
