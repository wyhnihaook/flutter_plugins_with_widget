import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/data/base_dialog.dart';

import '../config/enum_config.dart';
import '../helper/dialog_proxy.dart';
import '../helper/route_record.dart';
import '../smart_dialog.dart';

///描述:自定义Loading容器
///功能介绍:处理Loading相关的业务
///loading状态下，任意其他loading覆盖都使其无效化
///loading状态下的触摸事件不能穿透<手势作用下的页面不响应>
///创建者:翁益亨
///创建日期:2022/7/18 17:45
class CustomLoading extends BaseDialog{

  CustomLoading(super.overlayEntry);

  //是否支持返回消失
  bool _canDismiss = false;

  //最小加载时间处理的计时器
  Timer? _timer;

  //当前自动关闭的loading定时器，如果有设置那么就会开始倒计时到自动关闭，如果没有设置displayTime就需要手动调用dismiss方法
  Timer? _displayTimer;

  //外部调用本类dismiss方法，真正能关闭Loading的方法回调是该方法，也就是_realDismiss方法
  //主要是为了实现最短loading的设计，避免一闪而过的loading，造成不好的用户体验
  Future Function()? _canDismissCallback;

  Future<T?> showLoading<T>({
    required Widget widget,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required Duration? displayTime,
    required bool backDismiss,
  }) {

    //判断是否在显示中
    if(SmartDialog.config.loading.isExist){
      //显示中不做任何处理，直接返回即可
      return Future(() => null);
    }
    //初始化状态
    DialogProxy.instance.loadingBackDismiss = backDismiss;
    SmartDialog.config.loading.isExist = true;

    _canDismiss = false;
    _canDismissCallback = null;

    _timer?.cancel();
    //计时器处理，至少显示多少时间（在时间段内无法取消）
    _timer = Timer(SmartDialog.config.loading.leastLoadingTime, () {
      //能够消失的状态设置
      _canDismiss = true;
      //如果之前已经调用过dismiss生成了_canDismissCallback的方法，直接调用即可。如果没有生成，那么说明当前还处于loading状态，等待后续调用dismiss方法手动调用
      _canDismissCallback?.call();
    });

    return mainDialog.show<T>(
      widget: widget,
      animationType: animationType,
      alignment: Alignment.center,
      maskColor: maskColor,
      maskWidget: maskWidget,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      onDismiss: _handleDismiss(onDismiss, displayTime),
      useSystem: false,
      reuse: true,
      awaitOverType: SmartDialog.config.loading.awaitOverType,
      onMask: () {
        if(!RouteRecord.loadingBack){
          onMask?.call();
          if (!clickMaskDismiss) return;
          _realDismiss();
        }
      },
    );
  }

  //自动消失逻辑添加
  VoidCallback _handleDismiss(VoidCallback? onDismiss, Duration? displayTime) {
    _displayTimer?.cancel();
    if (displayTime != null) {
      //存在提前定义的显示时长，那么会创建定时器，时间到达后关闭当前的loading
      _displayTimer = Timer(displayTime, () => dismiss());
    }

    return () {
      _displayTimer?.cancel();
      //loading消失后，执行设定的回调方法
      onDismiss?.call();
    };
  }

  //真正消失弹窗调用方法
  Future<void> _realDismiss({bool back = false}) async {
    //满足当前不能取消并且返回标识没有打上的情况就不做任何处理，其他情况就要隐藏
    if (!DialogProxy.instance.loadingBackDismiss && back) return ;

    //在响应前[navigator_observer.dart]文件中didPop方法执行前，都不响应返回按钮的操作，保证之前弹窗返回时，之前页面周期执行完毕
    RouteRecord.loadingBack = true;
    //真正隐藏的方法调用
    await mainDialog.dismiss(isLoading: true);
    SmartDialog.config.loading.isExist = false;
  }

  //提供外部调用消失loading方法
  Future<void> dismiss({bool back = false}) async {
    //外部通知关闭loading后，将真正消失方法设置到对应Function上，等待调用
    _canDismissCallback = () => _realDismiss(back: back);

    //避免不足最小的显示时间就进行消失，造成页面闪烁，在最小显示计时器执行回调之前都不能执行消失方法
    if (_canDismiss) await _canDismissCallback?.call();
  }
}