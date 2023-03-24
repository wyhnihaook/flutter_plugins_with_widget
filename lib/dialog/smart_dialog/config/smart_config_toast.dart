import 'package:flutter/material.dart';

import 'enum_config.dart';

///描述:当前Toast展示配置信息
///功能介绍:Toast配置信息（全局配置信息）
///创建者:翁益亨
///创建日期:2022/7/13 10:43
class SmartConfigToast{
  SmartConfigToast({
    this.alignment = Alignment.center,
    this.animationType = SmartAnimationType.fade,
    this.animationTime = const Duration(milliseconds: 200),
    this.useAnimation = true,
    this.usePenetrate = true,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0.7),//不透明度设置最后一个参数即可。例如：深色蒙层：0.6 / 浅色蒙层：0.3
    this.maskWidget,
    this.clickMaskDismiss = false,
    this.debounce = false,
    this.debounceTime = const Duration(milliseconds: 300),
    this.displayType = SmartToastType.last,
    this.consumeEvent = false,
    this.displayTime = const Duration(milliseconds: 2000),
    this.intervalTime = const Duration(milliseconds: 100),
    this.awaitOverType = SmartAwaitOverType.dialogDismiss,
    this.isExist = false,
  });

  //控制dialog位于屏幕的位置
  final AlignmentGeometry alignment;

  //设置动画时间(显示和隐藏的动画过渡时间)
  final Duration animationTime;

  /// 动画类型[animationType]： 具体可参照[SmartAnimationType]注释
  final SmartAnimationType animationType;

  /// true（使用动画），false（不使用）
  final bool useAnimation;

  /// 屏幕上交互事件可以穿透遮罩背景：true（交互事件能穿透背景，遮罩会自动变成透明），false（不能穿透）
  final bool usePenetrate;

  /// 遮罩颜色：[usePenetrate]设置为true或[maskWidget]参数设置了数据，该参数会失效
  final Color maskColor;

  /// 遮罩Widget，可高度自定义你自己的遮罩背景：[usePenetrate]设置为true，该参数失效
  final Widget? maskWidget;

  /// true（点击遮罩关闭dialog），false（不关闭）
  final bool clickMaskDismiss;

  /// 防抖功能，它作用于toast和dialog上：默认（false）;
  final bool debounce;

  /// [debounceTime]：防抖时间内，多次点击只会响应第一次，第二次无效点击会触发防抖时间重新计时
  final Duration debounceTime;

  /// 提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  final SmartToastType displayType;

  /// true（toast会消耗触摸事件），false（toast不再消耗事件，触摸事件能穿透toast）
  final bool consumeEvent;

  /// toast在屏幕上的显示时间
  final Duration displayTime;

  /// 多个toast连续显示,每个toast之间显示的间隔时间
  final Duration intervalTime;

  /// 弹窗await结束的类型
  final SmartAwaitOverType awaitOverType;

  /// toast(showToast())是否存在在界面上
  bool isExist;
}
