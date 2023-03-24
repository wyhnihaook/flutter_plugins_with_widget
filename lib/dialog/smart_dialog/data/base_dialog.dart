import 'package:flutter/material.dart';

import '../custom/main_dialog.dart';

///描述:当前承载toast/dialog/loading的基类
///功能介绍:住哟用于
///创建者:翁益亨
///创建日期:2022/7/13 15:17
class BaseDialog{
  //当前承载显示容器
  final OverlayEntry overlayEntry;

  MainDialog mainDialog ;

  //初始化时，创建真正承载容器组件
  BaseDialog(this.overlayEntry): mainDialog = MainDialog(overlayEntry:overlayEntry);

  //提供获取自身组件功能
  Widget getWidget()=>mainDialog.getWidget();

}