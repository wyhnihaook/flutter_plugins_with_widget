import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/widget/smart_dialog_controller.dart';

import '../util/view_util.dart';

///描述:自定义样式的父容器，控制组件状态
///功能介绍:存在自定义的Toast/Loading/Dialog的样式的父容器
///创建者:翁益亨
///创建日期:2022/7/13 15:59
class DialogScope extends StatefulWidget {
  const DialogScope({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final SmartDialogController? controller;

  final WidgetBuilder builder;

  @override
  State<DialogScope> createState() => _DialogScopeState();
}

class _DialogScopeState extends State<DialogScope> {
  VoidCallback? _callback;

  @override
  void initState() {
    widget.controller?.setListener(_callback = () {
      ViewUtil.addSafeUse(() => setState(() {}));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void dispose() {
    if (_callback == widget.controller?.callback) {
      widget.controller?.dismiss();
    }

    super.dispose();
  }
}
