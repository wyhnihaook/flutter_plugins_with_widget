import 'package:flutter/material.dart';

import 'enum_config.dart';

///描述:当前Toast展示配置信息
///功能介绍:Toast配置信息（全局配置信息）
///当前Loading模式一定为在加载中又有Loading事件的时候不响应
///创建者:翁益亨
///创建日期:2022/7/13 10:43
class SmartConfigLoading {
  SmartConfigLoading({
    this.alignment = Alignment.center,
    this.animationType = SmartAnimationType.fade,
    this.animationTime = const Duration(milliseconds: 260),
    this.useAnimation = true,
    this.usePenetrate = false,
    this.maskColor = const Color.fromRGBO(0, 0, 0, 0),//不透明度设置最后一个参数即可。例如：深色蒙层：0.6 / 浅色蒙层：0.3
    this.maskWidget,
    this.backDismiss = true,
    this.clickMaskDismiss = false,
    this.leastLoadingTime = const Duration(milliseconds: 1000),//注意这里需要设置毫秒级别，如果需要修改，就将设置的单位设置自己想要的
    this.awaitOverType = SmartAwaitOverType.dialogDismiss,
    this.isExist = false,
  });


  /// 控制dialog位于屏幕的位置
  ///
  /// center: dialog位于屏幕中间，可使用[animationType]设置动画类型
  ///
  /// bottomCenter、bottomLeft、bottomRight：dialog位于屏幕底部，动画默认为位移动画，自下而上
  ///
  /// topCenter、topLeft、Alignment.topRight：dialog位于屏幕顶部，
  ///
  /// centerLeft：dialog位于屏幕左边，动画默认为位移动画，自左而右，
  ///
  /// centerRight：dialog位于屏幕左边，动画默认为位移动画，自右而左，
  final AlignmentGeometry alignment;

  /// [animationTime]：可设置动画时间
  final Duration animationTime;

  /// 动画类型[animationType]： 具体可参照[SmartAnimationType]注释
  final SmartAnimationType animationType;

  /// 是否使用动画（默认：true）
  final bool useAnimation;

  /// 屏幕上交互事件可以穿透遮罩背景：true（交互事件能穿透背景，遮罩会自动变成透明），false（不能穿透）
  final bool usePenetrate;

  /// 遮罩颜色：[usePenetrate]设置为true或[maskWidget]参数设置了数据，该参数会失效
  final Color maskColor;

  /// 遮罩Widget，可高度自定义你自己的遮罩背景：[usePenetrate]设置为true，该参数失效
  final Widget? maskWidget;

  /// true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭loading
  final bool backDismiss;

  /// true（点击遮罩关闭dialog），false（不关闭）
  final bool clickMaskDismiss;

  /// 最小加载时间: 如果该参数设置为1秒, showLoading()之后立马调用dismiss(), loading不会立马关闭, 会在加载时间达到1秒的时候关闭
  final Duration leastLoadingTime;

  /// 弹窗await结束的类型
  final SmartAwaitOverType awaitOverType;

  /// loading(showLoading())是否存在在界面上
  bool isExist;
}
