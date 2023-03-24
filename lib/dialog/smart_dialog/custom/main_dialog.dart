import 'dart:async';

import 'package:flutter/material.dart';

import '../config/enum_config.dart';
import '../data/base_controller.dart';
import '../data/smart_tag.dart';
import '../helper/dialog_proxy.dart';
import '../util/view_util.dart';
import '../helper/route_record.dart';
import '../widget/attach_dialog_widget.dart';
import '../widget/smart_dialog_widget.dart';

///描述:界面渲染组件的包装类
///功能介绍:为真正承载显示在界面上的组件进行包装，对外提供对应需要暴露的操作方法
///创建者:翁益亨
///创建日期:2022/7/13 15:20
class MainDialog {

  Widget _widget;

  //当前需要显示内容的组件
  final OverlayEntry overlayEntry;

  //设置唯一的key，避免创建的多个组件之间的key冲突
  final _uniqueKey = UniqueKey();

  BaseController? _controller;

  //当前没有使用，可以忽略，如果要使用，请在异步中返回_completer.future
  Completer? _completer;

  VoidCallback? _onDismiss;

  SmartAwaitOverType _awaitOverType = SmartAwaitOverType.dialogDismiss;

  //控制组件false显示/true隐藏的功能，
  bool offstage = false;

  MainDialog({required this.overlayEntry}) : _widget = Container();

  int count = 0;
  Future<T?> show<T>({
    count:0,
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback onMask,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required bool reuse,
    required SmartAwaitOverType awaitOverType,
  }) {

    this.count = count;
    //初始化显示组件样式
    _widget = SmartDialogWidget(
      key: reuse ? _uniqueKey : UniqueKey(),
      controller: _controller = SmartDialogController(),
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      child: widget,
      onMask: onMask,
    );

    //控制组件消失的方法
    _handleCommonOperate(
      animationTime: animationTime,
      onDismiss: onDismiss,
      useSystem: useSystem,
      awaitOverType: awaitOverType,
    );

    //wait dialog dismiss
    var completer = _completer = Completer<T>();
    return completer.future;
  }


  Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required Widget widget,
    required TargetBuilder? targetBuilder,
    required ReplaceBuilder? replaceBuilder,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required ScalePointBuilder? scalePointBuilder,
    required Color maskColor,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required VoidCallback onMask,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required SmartAwaitOverType awaitOverType,
  }) {
    //attach dialog
    _widget = AttachDialogWidget(
      key: _uniqueKey,
      targetContext: targetContext,
      targetBuilder: targetBuilder,
      replaceBuilder: replaceBuilder,
      controller: _controller = AttachDialogController(),
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      scalePointBuilder: scalePointBuilder,
      maskColor: maskColor,
      maskWidget: maskWidget,
      highlightBuilder: highlightBuilder,
      child: widget,
      onMask: onMask,
    );

    _handleCommonOperate(
      animationTime: animationTime,
      onDismiss: onDismiss,
      useSystem: useSystem,
      awaitOverType: awaitOverType,
    );

    //wait dialog dismiss
    var completer = _completer = Completer<T>();
    return completer.future;
  }

  Widget getWidget() => Offstage(offstage: offstage, child: _widget);

  //匹配await类型，等待对应时长并开始隐藏显示的内容
  void _handleCommonOperate({
    required Duration animationTime,
    required VoidCallback? onDismiss,
    required bool useSystem,
    required SmartAwaitOverType awaitOverType,
  }) {
    _awaitOverType = awaitOverType;

    //SmartAwaitOverType.none
    Future.delayed(const Duration(milliseconds: 10), () {
      _handleAwaitOver(awaitOverType: SmartAwaitOverType.none);
    });

    //SmartAwaitOverType.dialogAppear
    Future.delayed(animationTime, () {
      _handleAwaitOver(awaitOverType: SmartAwaitOverType.dialogAppear);
    });

    ViewUtil.addSafeUse(() {
      //该方法会立即执行
      _onDismiss = onDismiss;

      //使用系统的API弹出浮窗
      if (useSystem && DialogProxy.contextNavigator != null) {
        var tempWidget = _widget;
        _widget = Container();
        showDialog(
          context: DialogProxy.contextNavigator!,
          barrierColor: Colors.transparent,
          barrierDismissible: false,
          useSafeArea: false,
          routeSettings: RouteSettings(name: SmartTag.systemDialog),
          builder: (BuildContext context) => tempWidget,
        );
      }

      //必须要刷新布局，因为overlayEntry的builder（dialog_proxy.dart文件）返回的widget中的界面信息已经发生更改，为了使其能显示，需要调用该方法
      overlayEntry.markNeedsBuild();
    });
  }

  //匹配当前弹窗await结束的类型
  void _handleAwaitOver<T>({
    required SmartAwaitOverType awaitOverType,
    T? result,
  }) {
    if (awaitOverType == _awaitOverType) {
      if (!(_completer?.isCompleted ?? true)) _completer?.complete(result);
    }
  }

  //显示界面上的组件内容消失方法
  Future<void> dismiss<T>({
    bool useSystem = false,
    T? result,
    bool isDialog = false,
    bool isLoading = false,
  }) async {

    //消失回调
    _onDismiss?.call();

    //关闭显示组件动画效果，上述判断不能移动到下面，因为这里会延时直到动画效果执行完毕，这个时候已经从队列中移除，但是还未真正意义上的从系统中移除，这个时候点击返回会出现问题
    await _controller?.dismiss();

    //从界面上移除显示内容
    _widget = Container();
    //重新加载界面显示内容，这里显示就为一个占位为0的空布局
    overlayEntry.markNeedsBuild();


    if (useSystem && DialogProxy.contextNavigator != null) {
      //在动画效果执行完毕后，再从界面中移除
      Navigator.pop(DialogProxy.contextNavigator!);
    }else{
      //自定义弹窗消化完毕，重置状态
      if(isDialog){
        //避免loading/toast错误重置状态，导致内容错乱
        RouteRecord.dialogBack = false;
      }

      //重置loading状态
      if(isLoading){
        RouteRecord.loadingBack = false;
      }
    }

    _handleAwaitOver<T>(
      awaitOverType: SmartAwaitOverType.dialogDismiss,
      result: result,
    );
  }
}