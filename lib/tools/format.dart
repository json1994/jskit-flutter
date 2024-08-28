import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 数字格式化
extension NumFormat on num? {
  String get countFormat {
    var count = this?.toInt() ?? 0;
    if (count > 10000) {
      return "${(count / 10000).toStringAsFixed(1)}w";
    }
    if (count > 1000) {
      return "${(count / 1000).toStringAsFixed(1)}k";
    }
    return count.toString();
  }

  String get durationFormat {
    var count = this?.toInt() ?? 0;
    var h = count ~/ 3600;
    var min = (count - h * 3600) ~/ 60;
    var s = count % 60;
    var hStr = h.toInt().toString().padLeft(2, '0');
    var minStr = min.toInt().toString().padLeft(2, '0');
    var sStr = s.toInt().toString().padLeft(2, '0');
    if (h > 0) {
      return "$hStr:$minStr:$sStr";
    } else {
      return "$minStr:$sStr";
    }
  }

  /// 毫秒
  DateTime get toDateTime {
    return DateTime.fromMillisecondsSinceEpoch(this?.toInt() ?? 0);
  }

  /// 格式化文件大小描述
  String get formatFileSize {
    if (this != null) {
      List<String> unitArr = ['B', 'K', 'M', 'G'];
      int index = 0;
      var value = this?.toDouble() ?? 0;
      if (value == 0) {
        return "0M";
      }
      while (value > 1024) {
        index++;
        value = value / 1024;
      }
      String size = value.toStringAsFixed(2);
      return size + unitArr[index];
    }
    return '0M';
  }
}

/// DateTime
extension TimerTool on DateTime? {
  String get week {
    if (this is DateTime) {
      switch (this!.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thursday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    }
    return "";
  }

  String get monthStr {
    if (this is DateTime) {
      switch (this!.month) {
        case 1:
          return "January";
        case 2:
          return "February";
        case 3:
          return "March";
        case 4:
          return "April";
        case 5:
          return "May";
        case 6:
          return "June";
        case 7:
          return "July";
        case 8:
          return "August";
        case 9:
          return "September";
        case 10:
          return "October";
        case 11:
          return "November";
        case 12:
          return "December";
      }
    }
    return "";
  }

  String get toYMD {
    if (this is DateTime) {
      return "${this!.year}-${this!.month.toString().padLeft(2, '0')}-${this!.day.toString().padLeft(2, '0')}";
    }
    return "";
  }

  String formatTime(DateTime dateTime, {String format = "yyyy-MM-dd HH:mm:ss"}) {
    // 创建 DateFormat 实例
    var dateFormat = DateFormat(format);

// 使用 DateFormat 实例格式化日期时间数据
    var formattedDateTime = dateFormat.format(dateTime);
    return formattedDateTime;
  }

  String get period {
    if (this is DateTime) {
      var hour = this!.hour;
      if (hour < 12) {
        return "AM";
      } else {
        return "PM";
      }
    }
    return "";
  }

  String get periodTime {
    var format = DateFormat.jm();

    return format.format(this ?? DateTime.now());
  }
}

enum PasswordStrength {
  low,
  medium,
  high,
}

extension RegExpTool on String? {
  bool get isEmail {
    if (this is String) {
      return RegExp(r"^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$").hasMatch(this!);
    }
    return false;
  }
  // 密码强度判断
  PasswordStrength checkPasswordStrength() {
    // 低强度：只包含字母或数字
    final lowRegex = RegExp(r'^[a-zA-Z]+$|^\d+$');

    // 中强度：包含字母和数字的组合
    final mediumRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$');

    // 高强度：包含字母、数字和特殊字符的组合，且长度至少为8
    final highRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
    var password = this ?? '';
    if (highRegex.hasMatch(password)) {
      return PasswordStrength.high;
    } else if (mediumRegex.hasMatch(password)) {
      return PasswordStrength.medium;
    } else if (lowRegex.hasMatch(password)) {
      return PasswordStrength.low;
    } else {
      // 如果不匹配任何模式，我们也将其视为低强度
      return PasswordStrength.low;
    }
  }
}

extension ExtBotToast on BuildContext {
  void showAlertDialog(
      {BackButtonBehavior backButtonBehavior = BackButtonBehavior.ignore,
      VoidCallback? cancel,
      VoidCallback? confirm,
      VoidCallback? backgroundReturn,
      VoidCallback? onClose,
      Duration afterHidden = const Duration(seconds: 2),
      Widget Function(Function() cancel)? buildContent}) {
    BotToast.showAnimationWidget(
        clickClose: false,
        allowClick: false,
        onlyOne: true,
        crossPage: true,
        onClose: onClose,
        backButtonBehavior: backButtonBehavior,
        wrapToastAnimation: (controller, cancel, child) => Stack(
              children: <Widget>[
                AnimatedBuilder(
                  builder: (_, child) => Opacity(
                    opacity: controller.value,
                    child: child,
                  ),
                  animation: controller,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black26),
                    child: SizedBox.expand(),
                  ),
                ),
                CustomScaleAnimation(
                  controller: controller,
                  onCancel: cancel,
                  afterHidden: afterHidden,
                  child: child,
                )
              ],
            ),
        toastBuilder: (cancelFunc) => Center(
              child: buildContent?.call(cancelFunc) ?? SizedBox(),
            ),
        animationDuration: const Duration(milliseconds: 300));
  }

  // Future<bool> auth() async {
  //   if (app.container.read(loginProvider.notifier).state) {
  //     return true;
  //   }
  //   router.pushNamed("/login");
  //   return false;
  // }
}

extension ExtTimeDesc on DateTime? {
  // 时间显示，刚刚，x分钟前
  String messageTime() {
    if (this == null) return '';
    // 当前时间
    int time = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    int timeStamp = (this!.millisecondsSinceEpoch / 1000).round();
    // 对比
    int distance = time - timeStamp;
    if (distance <= 60) {
      return 'just now';
    } else if (distance <= 3600) {
      return '${(distance / 60).floor()} minutes ago';
    } else if (distance <= 43200) {
      return '${(distance / 60 / 60).floor()} hour ago';
    } else if (DateTime.fromMillisecondsSinceEpoch(time * 1000).year ==
        DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000).year) {
      return _CustomStamp_str(Timestamp: timeStamp, Date: 'MM/DD hh:mm', toInt: false);
    } else {
      return _CustomStamp_str(Timestamp: timeStamp, Date: 'YY/MM/DD hh:mm', toInt: false);
    }
  }

  // 时间戳转时间
  String _CustomStamp_str({
    int? Timestamp, // 为空则显示当前时间
    String? Date, // 显示格式，比如：'YY年MM月DD日 hh:mm:ss'
    bool toInt = true, // 去除0开头
  }) {
    Timestamp ??= (DateTime.now().millisecondsSinceEpoch / 1000).round();
    String timeStr = (DateTime.fromMillisecondsSinceEpoch(Timestamp * 1000)).toString();

    dynamic dateArr = timeStr.split(' ')[0];
    dynamic timeArr = timeStr.split(' ')[1];

    String YY = dateArr.split('-')[0];
    String MM = dateArr.split('-')[1];
    String DD = dateArr.split('-')[2];

    String hh = timeArr.split(':')[0];
    String mm = timeArr.split(':')[1];
    String ss = timeArr.split(':')[2];

    ss = ss.split('.')[0];

    // 去除0开头
    if (toInt) {
      MM = (int.parse(MM)).toString();
      DD = (int.parse(DD)).toString();
      hh = (int.parse(hh)).toString();
      mm = (int.parse(mm)).toString();
    }

    if (Date == null) {
      return timeStr;
    }

    Date = Date.replaceAll('YY', YY)
        .replaceAll('MM', MM)
        .replaceAll('DD', DD)
        .replaceAll('hh', hh)
        .replaceAll('mm', mm)
        .replaceAll('ss', ss);

    return Date;
  }
}

class CustomScaleAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;
  final Function()? onCancel;
  final Duration afterHidden;
  const CustomScaleAnimation(
      {Key? key,
      required this.controller,
      required this.child,
      this.afterHidden = const Duration(seconds: 2),
      this.onCancel})
      : super(key: key);

  @override
  _CustomScaleAnimationState createState() => _CustomScaleAnimationState();
}

class _CustomScaleAnimationState extends State<CustomScaleAnimation> {
  late Tween<Offset> tweenOffset;
  late Tween<double> tweenScale;

  late Animation<double> animation;

  @override
  void initState() {
    tweenOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    );
    tweenScale = Tween<double>(begin: 0.3, end: 1.0);
    animation = CurvedAnimation(parent: widget.controller, curve: Curves.easeInOut);
    super.initState();
    if (widget.afterHidden.inSeconds > 0 || widget.afterHidden.inMilliseconds > 0) {
      Future.delayed(widget.afterHidden, () {
        widget.onCancel?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return FractionalTranslation(
            translation: tweenOffset.evaluate(animation),
            child: ClipRect(
              child: Transform.scale(
                scale: tweenScale.evaluate(animation),
                child: Opacity(
                  opacity: animation.value,
                  child: child,
                ),
              ),
            ));
      },
      child: widget.child,
    );
  }
}
