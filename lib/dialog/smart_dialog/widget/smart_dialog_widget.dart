import 'package:flutter/material.dart';

import '../config/enum_config.dart';
import '../data/base_controller.dart';

///描述:真正承载显示在界面上的组件
///功能介绍:真正承载显示在界面上的组件，最终渲染的组件
///创建者:翁益亨
///创建日期:2022/7/13 15:55
class SmartDialogWidget extends StatefulWidget {
  const SmartDialogWidget({
    Key? key,
    required this.child,
    required this.controller,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationTime,
    required this.useAnimation,
    required this.animationType,
    required this.maskColor,
    required this.maskWidget,
  }) : super(key: key);

  /// 内容widget
  final Widget child;

  ///当前文件中的 SmartDialogController widget controller
  final SmartDialogController controller;

  /// 点击遮罩
  final VoidCallback onMask;

  /// 内容控件方向
  final AlignmentGeometry alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool usePenetrate;

  /// 动画时间
  final Duration animationTime;

  /// 是否使用动画
  final bool useAnimation;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final SmartAnimationType animationType;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  @override
  State<SmartDialogWidget> createState() => _SmartDialogWidgetState();
}

class _SmartDialogWidgetState extends State<SmartDialogWidget>
    //AnimationController 的vsync需要传入一个TickerProvider
    with TickerProviderStateMixin{
  //控制背景色的动画器
  AnimationController? _ctrlBg;
  //控制内容的动画器
  late AnimationController _ctrlBody;
  //动画效果过渡的坐标信息（这里指开始坐标）
  Offset? _offset;

  @override
  void initState() {
    _resetState();

    super.initState();
  }

  //重置当前显示的状态
  void _resetState() {
    _dealContentAnimate();

    //forward() 方法用来开始动画，即从无到有
    //reverse() 方法用来反向开始动画，即从有到无
    //上述正向反向需要参照begin: 1.0, end: 0.0 来进行处理的。例如：1.0->0.0 forward隐藏 reverse显示  0.0->1.0则反向

    //结合使用CurvedAnimation的动画效果0->1.0,使用的forward就是显示，默认初始化时要<显示>出来
    var duration = widget.animationTime;
    if (_ctrlBg == null) {
      _ctrlBg = AnimationController(vsync: this, duration: duration);
      _ctrlBody = AnimationController(vsync: this, duration: duration);
      _ctrlBg!.forward();
      _ctrlBody.forward();
    } else {
      _ctrlBg!.duration = duration;
      _ctrlBody.duration = duration;

      _ctrlBody.value = 0;
      _ctrlBody.forward();
    }

    //绑定当前显示组件，用于dismiss方法回调时处理额外情况
    widget.controller._bind(this);
  }

  //didUpdateWidget 是需要重新创建widget对象 才会调用 （setState方法调用）
  //界面重新加载的时候重置当前的状态
  @override
  void didUpdateWidget(covariant SmartDialogWidget oldWidget) {
    if (oldWidget.child != widget.child) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      //暗色背景widget动画
      _buildBgAnimation(
        onPointerUp: widget.onMask,
        child: (widget.maskWidget != null && !widget.usePenetrate)
            ? widget.maskWidget
            : Container(color: widget.usePenetrate ? null : widget.maskColor),
      ),

      //内容Widget动画
      Container(
        alignment: widget.alignment,
        child: widget.useAnimation ? _buildBodyAnimation() : widget.child,
      ),
    ]);
  }

  //显示背景处理
  Widget _buildBgAnimation({
    required void Function()? onPointerUp,
    required Widget? child,
  }) {
    return FadeTransition(
      //曲线变化，使过渡越来越慢 ,范围为0.0到1.0
      opacity: CurvedAnimation(parent: _ctrlBg!, curve: Curves.linear),
      //Listener处理触摸事件
      child: Listener(
        //事件是否由当前组件消化（默认由本身消化/deferToChild），当前使点击事件下发
        behavior: HitTestBehavior.translucent,
        //这里处理焦点抬起的情况
        onPointerUp: (event) => onPointerUp?.call(),
        child: child,
      ),
    );
  }

  //显示内容处理
  Widget _buildBodyAnimation() {
    var child = widget.child;
    var animation = CurvedAnimation(parent: _ctrlBody, curve: Curves.linear);
    //补间动画，在两个关键帧中完成动画效果
    var tw = Tween<Offset>(begin: _offset, end: Offset.zero);
    var type = widget.animationType;
    Widget animationWidget = FadeTransition(opacity: animation, child: child);

    //select different animation
    if (type == SmartAnimationType.fade) {
      animationWidget = FadeTransition(opacity: animation, child: child);
    } else if (type == SmartAnimationType.scale) {
      animationWidget = ScaleTransition(scale: animation, child: child);
    } else if (type == SmartAnimationType.centerFade_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animationWidget = FadeTransition(opacity: animation, child: child);
      } else {
        animationWidget = SlideTransition(
          position: tw.animate(_ctrlBody),
          child: child,
        );
      }
    } else if (type == SmartAnimationType.centerScale_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animationWidget = ScaleTransition(scale: animation, child: child);
      } else {
        animationWidget = SlideTransition(
          position: tw.animate(_ctrlBody),
          child: child,
        );
      }
    }
    return animationWidget;
  }

  ///处理下内容widget动画方向
  void _dealContentAnimate() {
    //当前方法只适用于滑动进入页面的情况
    //上左-1，右下1

    //页面显示在屏幕时，Offset的dx dy均为0；中间位置
    //如果需要动画页面从屏幕底部弹出，则应该是dy=0 到 dy=1
    //如果需要动画页面从屏幕顶部弹出，则应该是dy=0 到 dy=-1
    //如果需要动画页面从右侧推入到屏幕，则应该是dx=1 到 dx=0
    //如果需要动画页面从左侧推入到屏幕，则应该是dx=-1 到 dx=0

    AlignmentGeometry? alignment = widget.alignment;
    _offset = Offset(0, 0);

    if (alignment == Alignment.bottomCenter ||
        alignment == Alignment.bottomLeft ||
        alignment == Alignment.bottomRight) {
      //靠下
      _offset = Offset(0, 1);
    } else if (alignment == Alignment.topCenter ||
        alignment == Alignment.topLeft ||
        alignment == Alignment.topRight) {
      //靠上
      _offset = Offset(0, -1);
    } else if (alignment == Alignment.centerLeft) {
      //靠左
      _offset = Offset(-1, 0);
    } else if (alignment == Alignment.centerRight) {
      //靠右
      _offset = Offset(1, 0);
    } else {
      //居中使用缩放动画,空结构体,不需要操作
    }
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_ctrlBg == null) return;
    //结束动画，隐藏内容，例如：FadeTransition动画效果：控制子对象不透明度的动画 0为全透明，1为不透明。所以reverse重置到0就为隐藏内容
    _ctrlBg!.reverse();
    _ctrlBody.reverse();

    if (widget.useAnimation) {
      await Future.delayed(widget.animationTime);
    }
  }

  @override
  void dispose() {
    _ctrlBg?.dispose();
    _ctrlBg = null;
    _ctrlBody.dispose();

    super.dispose();
  }
}

///控制器：用于外部实现隐藏组件回调
class SmartDialogController extends BaseController {
  _SmartDialogWidgetState? _state;

  void _bind(_SmartDialogWidgetState _state) {
    this._state = _state;
  }

  @override
  Future<void> dismiss() async {
    try {
      await _state?.dismiss();
    } catch (e) {
      print("-------------------------------------------------------------");
      print("SmartDialog error: ${e.toString()}");
      print("-------------------------------------------------------------");
    }
    _state = null;
  }
}
