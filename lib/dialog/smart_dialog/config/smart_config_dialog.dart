import 'package:flutter/material.dart';

import 'enum_config.dart';

///描述:Dialog配置信息
///功能介绍:Dialog配置信息
///创建者:翁益亨
///创建日期:2022/7/19 17:33
class SmartConfigDialog{
    SmartConfigDialog({
      this.alignment = Alignment.center,
      this.animationType = SmartAnimationType.centerScale_otherSlide,
      this.animationTime = const Duration(milliseconds: 260),
      this.useAnimation = true,
      this.usePenetrate = false,
      this.maskColor = const Color.fromRGBO(0, 0, 0, 0.35),//不透明度设置最后一个参数即可。例如：深色蒙层：0.6 / 浅色蒙层：0.3
      this.maskWidget,
      this.clickMaskDismiss = true,
      this.debounce = false,
      this.debounceTime = const Duration(milliseconds: 300),
      this.backDismiss = true,
      this.bindPage = true,
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

    /// true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
    /// 你仍然可以使用dismiss方法来关闭loading
    final bool backDismiss;

    /// 将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
    /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
    final bool bindPage;

    /// 弹窗await结束的类型
    final SmartAwaitOverType awaitOverType;

    /// 自定义dialog(show())，是否存在在界面上
    bool isExist;
}