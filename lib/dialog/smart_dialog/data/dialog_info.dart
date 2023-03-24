import 'package:flutter/material.dart';

import '../config/enum_config.dart';
import 'base_dialog.dart';

///参数都由[smart_dialog.dart]文件的show方法传递提供，参考注释，从携带方法参数获取数据源构建的实体类
class DialogInfo {
  DialogInfo({
    required this.dialog,
    required this.backDismiss,
    required this.type,
    required this.tag,
    required this.permanent,
    required this.useSystem,
    required this.bindPage,
    required this.route,
  });

  final BaseDialog dialog;

  final bool backDismiss;

  final DialogType type;

  final String? tag;

  final bool permanent;

  //使用系统的showDialog弹出浮窗
  final bool useSystem;

  final bool bindPage;

  final Route<dynamic>? route;
}
