import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/data/base_dialog.dart';

import '../config/enum_config.dart';
import '../data/dialog_info.dart';
import '../data/smart_tag.dart';
import '../helper/dialog_proxy.dart';
import '../smart_dialog.dart';
import '../util/view_util.dart';
import '../helper/route_record.dart';
import '../widget/attach_dialog_widget.dart';
import 'main_dialog.dart';

///描述:自定义Dialog显示的业务逻辑处理类
///功能介绍:对Dialog属性做对应处理，通过mainDialog进行展示
///这里要处理多个Dialog叠加的情况，不排除会出现这种情况（例如：Dialog上需要展示Pop选择器）
///创建者:翁益亨
///创建日期:2022/7/19 14:08
class CustomDialog extends BaseDialog {
  CustomDialog(super.overlayEntry);

  static MainDialog? mainDialogSingle;

  DateTime? clickMaskLastTime;

  var _timeRandom = Random().nextInt(666666) + Random().nextDouble();

  //展示Dialog
  Future<T?> show<T>({
    required Widget widget,
    required AlignmentGeometry alignment,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required SmartAnimationType animationType,
    required Color maskColor,
    required bool clickMaskDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required Duration? displayTime,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    if (!_handleMustOperate(
      tag: displayTime != null ? _getTimeKey(displayTime) : tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.dialog,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    )) return Future.value(null);
    int count = DialogProxy.instance.dialogQueue.length;
    return mainDialog.show<T>(
      count: count,//角标设置
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      onDismiss: _handleDismiss(onDismiss, displayTime),
      useSystem: useSystem,
      reuse: true,
      awaitOverType: SmartDialog.config.dialog.awaitOverType,
      onMask: () {
        //需要匹配是否已经执行了返回，避免和返回键冲突
        if(!RouteRecord.dialogBack){
          //两个都是自定义弹窗，第一个弹窗不能返回关闭，第二个弹窗可以返回关闭，连续点第二个弹窗蒙层和返回键，会出现问题，第一个弹窗的clickMaskDismiss变为true
          //经过排查，同时点击了返回和隐藏浮层导致的，当前点击的蒙层角标为2，还是之前允许关闭的浮层的内容
          //解决方式：在移除后对对应的位置添加重置标识，设置为隐藏状态，这个时候如果蒙层识别到点击状态，并且已经隐藏的界面点击，不应该响应
          if(!useSystem){
            if(mainDialog.offstage)return;
          }
          onMask?.call();
          //这里判断点击蒙层是否隐藏
          if (!clickMaskDismiss || !_clickMaskDebounce() || permanent) return;
          //走到这里一定为隐蒙层处理隐藏
          dismiss(isMaskBack: true);
        }
      },
    );
  }

  //固定位置展示内容
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
    required bool clickMaskDismiss,
    required bool debounce,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required VoidCallback? onDismiss,
    required VoidCallback? onMask,
    required Duration? displayTime,
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    if (!_handleMustOperate(
      tag: displayTime != null ? _getTimeKey(displayTime) : tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      debounce: debounce,
      type: DialogType.attach,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    )) return Future.value(null);

    return mainDialog.showAttach<T>(
      targetContext: targetContext,
      widget: widget,
      targetBuilder: targetBuilder,
      replaceBuilder: replaceBuilder,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      scalePointBuilder: scalePointBuilder,
      maskColor: maskColor,
      highlightBuilder: highlightBuilder,
      maskWidget: maskWidget,
      onDismiss: _handleDismiss(onDismiss, displayTime),
      useSystem: useSystem,
      awaitOverType: SmartDialog.config.attach.awaitOverType,
      onMask: () {
        if(!RouteRecord.dialogBack){
          if(!useSystem){
            if(mainDialog.offstage)return;
          }
          onMask?.call();
          if (!clickMaskDismiss || !_clickMaskDebounce() || permanent) return;
          dismiss();
        }
      },
    );
  }

  VoidCallback _handleDismiss(VoidCallback? onDismiss, Duration? displayTime) {
    Timer? timer;
    if (displayTime != null) {
      timer = Timer(displayTime, () => dismiss(tag: _getTimeKey(displayTime)));
    }

    return () {
      timer?.cancel();
      onDismiss?.call();
    };
  }

  String _getTimeKey(Duration time) => '${time.hashCode + _timeRandom}';

  bool _handleMustOperate({
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required bool debounce,
    required DialogType type,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    // 快速点击处理
    if (!_checkDebounce(debounce, type)) return false;

    //展示弹窗方法
    _handleDialogStack(
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      type: type,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    );

    //判断当前显示的类型，将对应显示状态设置为true
    SmartDialog.config.dialog.isExist = DialogType.dialog == type;
    return true;
  }

  void _handleDialogStack({
    required String? tag,
    required bool backDismiss,
    required bool keepSingle,
    required DialogType type,
    required bool permanent,
    required bool useSystem,
    required bool bindPage,
  }) {
    if (keepSingle) {
      DialogInfo? dialogInfo = _getDialog(tag: SmartTag.keepSingle);
      if (dialogInfo == null) {
        dialogInfo = DialogInfo(
          dialog: this,
          backDismiss: backDismiss,
          type: type,
          tag: SmartTag.keepSingle,
          permanent: permanent,
          useSystem: useSystem,
          bindPage: bindPage,
          route: RouteRecord.curRoute,
        );
        _pushDialog(dialogInfo);
        mainDialogSingle = mainDialog;
      }

      mainDialog = mainDialogSingle!;
      return;
    }

    // 弹窗对象信息
    var dialogInfo = DialogInfo(
      dialog: this,
      backDismiss: backDismiss,
      type: type,
      tag: tag,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
      route: RouteRecord.curRoute,
    );
    _pushDialog(dialogInfo);
  }

  //将展示的弹窗添加到显示队列中，为了可以快速从队列中获取对象进行处理
  void _pushDialog(DialogInfo dialogInfo) {
    var proxy = DialogProxy.instance;
    //持久化存储，就将弹窗放置到队列首部
    if (dialogInfo.permanent) {
      proxy.dialogQueue.addFirst(dialogInfo);
    } else {
      proxy.dialogQueue.addLast(dialogInfo);
    }
    // 将承载展示的界面添加到Overlay中进行展示
    //由于Dialog的样式多样性，所以不能预添加到初始化的Overlay中，所以只能通过这样的方式动态添加需要展示内容
    ViewUtil.addSafeUse(() {
      Overlay.of(DialogProxy.contextOverlay)!.insert(
        overlayEntry,
        below: proxy.entryLoading,
      );
    });
  }

  //快速点击处理，规定两次点击时间段内不响应，返回false不处理，返回true处理弹窗点击事件
  bool _checkDebounce(bool debounce, DialogType type) {
    if (!debounce) return true;

    var proxy = DialogProxy.instance;
    var now = DateTime.now();
    var debounceTime = type == DialogType.dialog
        ? SmartDialog.config.dialog.debounceTime
        : SmartDialog.config.dialog.debounceTime;
    var prohibit = proxy.dialogLastTime != null &&
        now.difference(proxy.dialogLastTime!) < debounceTime;
    proxy.dialogLastTime = now;
    if (prohibit) return false;

    return true;
  }

  bool _clickMaskDebounce() {
    var now = DateTime.now();
    var isShake = clickMaskLastTime != null &&
        now.difference(clickMaskLastTime!) < Duration(milliseconds: 500);
    clickMaskLastTime = now;
    if (isShake) return false;

    return true;
  }

  static Future<void>? dismiss<T>({
    bool isMaskBack = false,//蒙层点击专用
    DialogType type = DialogType.dialog,
    bool back = false,
    String? tag,
    T? result,
    bool force = false,
    bool route = false,
  }) {
    if (type == DialogType.dialog || type == DialogType.attach) {
      return _closeSingle<T>(
        isMaskBack: isMaskBack,
        type: type,
        back: back,
        tag: tag,
        result: result,
        force: force,
        route: route,
      );
    } else {
      DialogType? allType;
      if (type == DialogType.allDialog) allType = DialogType.dialog;
      if (type == DialogType.allAttach) allType = DialogType.attach;
      if (allType == null) return null;

      return _closeAll<T>(
        isMaskBack: isMaskBack,
        type: allType,
        back: back,
        tag: tag,
        result: result,
        force: force,
        route: route,
      );
    }
  }

  static Future<void> _closeAll<T>({
    required bool isMaskBack,
    required DialogType type,
    required bool back,
    required String? tag,
    required T? result,
    required bool force,
    required bool route,
  }) async {
    for (int i = DialogProxy.instance.dialogQueue.length; i > 0; i--) {
      await _closeSingle<T>(
        isMaskBack:isMaskBack,
        type: type,
        back: back,
        tag: tag,
        result: result,
        force: force,
        route: route,
      );
    }
  }

  //关闭单个弹窗
  static Future<void> _closeSingle<T>({
    required DialogType type,
    required bool back,
    required String? tag,
    required T? result,
    required bool force,
    required bool route,
    required bool isMaskBack,
  }) async {
    //尝试获取DialogProxy.instance.dialogQueue最新添加的弹窗
    var info = _getDialog(type: type, back: back, tag: tag, force: force,isMaskBack: isMaskBack);
    //如果没有获取到弹窗信息  或者  当前弹窗是永久性弹窗并且不强制退出 ，就不做关闭处理
    if (info == null || (info.permanent && !force)) return;
    //匹配路由信息，是当前即将退出的页面
    if (route && info.bindPage && info.route != RouteRecord.popRoute) return;

    //从弹窗队列中移除弹窗实例
    var proxy = DialogProxy.instance;

    //需要被移除的数据进行状态设置，用来同步快速点击造成的误差，如果已经被移除了，蒙层点击就应该不响应
    if(!info.useSystem){
      info.dialog.mainDialog.offstage = true;
    }

    proxy.dialogQueue.remove(info);

    //重置显示的状态
    proxy.config.dialog.isExist = false;

    //遍历队列数据，判断当前页面是否存在浮窗，处理多个Dialog返回层级关系
    for (var item in proxy.dialogQueue) {
      //再次匹配当前dialog是否还存在，如果存在的情况，这里采用全匹配，因为在返回的时候会匹配当前是否需要处理，判断当前如果是隐藏的时候，就不处理
      if (item.type == DialogType.dialog) {
        proxy.config.dialog.isExist = true;
      } else if (item.type == DialogType.attach) {}
    }

    //真正时界面上弹窗消失的方法调用
    var customDialog = info.dialog;

    //在响应前[navigator_observer.dart]文件中didPop方法执行前，都不响应返回按钮的操作，保证之前弹窗返回时，之前页面周期执行完毕
    RouteRecord.dialogBack = true;

    await customDialog.mainDialog.dismiss<T>(
      useSystem: info.useSystem,
      result: result,
      isDialog: true,
    );

    //将当前的弹窗从overlay中移除（完全移除）
    customDialog.overlayEntry.remove();
  }

  //根据参数尝试从DialogProxy.instance.dialogQueue获取对应的弹窗
  static DialogInfo? _getDialog({
    bool isMaskBack = false,
    DialogType type = DialogType.dialog, //弹窗类型申明
    bool back = false,//标识是否是返回键（物理/AppBar顶部返回）触发的流程
    String? tag,
    bool force = false, //永久性关闭的弹窗，一定要设置force为true才能关闭
  }) {
    var proxy = DialogProxy.instance;
    if (proxy.dialogQueue.isEmpty) return null;

    DialogInfo? info;
    var dialogQueue = proxy.dialogQueue;
    var list = dialogQueue.toList();

    //如果存在tag，那么从列表中匹配获取
    if (tag != null) {
      for (var i = dialogQueue.length - 1; i >= 0; i--) {
        if (dialogQueue.isEmpty) break;
        if (list[i].tag == tag) info = list[i];
      }
      return info;
    }

    if (force) {
      //关闭永久化dialog，按照添加顺序，从最后开始获取，获取到了就返回
      for (var i = dialogQueue.length - 1; i >= 0; i--) {
        if (dialogQueue.isEmpty) break;
        if (list[i].permanent) return list[i];
      }
    }

    //从队列中获取最后添加的匹配模式的Dialog
    for (var i = dialogQueue.length - 1; i >= 0; i--) {
      if (dialogQueue.isEmpty) break;
      if (type == DialogType.dialog || list[i].type == type) {
        info = list[i];
        break;
      }
    }

    //当前页面不允许返回判断后，返回null
    //backDismiss:返回事件将关闭loading，但是不会关闭页面
    //back:是否是物理/AppBar返回键触发的返回-->只用来区分来源
    // (!info.backDismiss && back)
    if(isMaskBack){
      //如果是点击蒙层，走到这里，那么一定会响应，因为点击前已经匹配过是否响应的字段，所以这里不做处理，直接返回

    }else{
      if (info != null && (!info.backDismiss&& back)) return null;
    }

    return info;
  }
}
