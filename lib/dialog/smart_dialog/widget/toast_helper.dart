import 'package:flutter/material.dart';

import '../util/view_util.dart';

///描述:toast弹出帮助类
///功能介绍:处理当前Toast触摸是否需要穿透等其他功能
///创建者:翁益亨
///创建日期:2022/7/13 14:47
class ToastHelper extends StatefulWidget {
  /// [smart_config_toast] consumeEvent 属性同步
  final bool consumeEvent;

  final Widget child;

  const ToastHelper({required this.consumeEvent, required this.child, Key? key})
      : super(key: key);

  @override
  State<ToastHelper> createState() => _ToastHelperState();
}

class _ToastHelperState extends State<ToastHelper>
    //组件状态监听
    with WidgetsBindingObserver{

  //当前的软键盘高度
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    //添加观察者
    widgetsBinding.addObserver(this);
    _dealKeyboard();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _keyboardHeight),
      child: widget.consumeEvent
          ? widget.child
          //IgnorePointer组件使手势透传
          : IgnorePointer(child: widget.child),
    );
  }

  //注意：添加观察者之后才会有回调
  //应用尺寸改变时回调，例如旋转，软键盘弹出
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    //widgetsBinding消化了之前的事件，为了让下个变化有响应，所以又要设置一次
    _dealKeyboard();
  }

  @override
  void dispose() {
    //移除观察者
    widgetsBinding.removeObserver(this);
    super.dispose();
  }

  //处理软键盘弹出之后的显示问题
  void _dealKeyboard() {
    ViewUtil.addPostFrameCallback((_) {
      if (!mounted) return;
      _keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      setState(() {});
    });
  }
}
