import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/widget/toast_helper.dart';

import '../config/enum_config.dart';
import '../config/smart_config.dart';
import '../custom/custom_dialog.dart';
import '../custom/custom_loading.dart';
import '../custom/custom_toast.dart';
import '../data/dialog_info.dart';
import '../init_dialog.dart';
import '../widget/attach_dialog_widget.dart';

///描述:代理类，用于代理所有
///功能介绍:代理方法
///创建者:翁益亨
///创建日期:2022/7/13 14:20
class DialogProxy{

  //代理当前全局的config配置
  late SmartConfig config;

  //Toast展示容器
  late OverlayEntry entryToast;
  //默认的展示的Toast中展示容器的承载组件，承载entryToast中的child组件信息
  late CustomToast _toast;

  //当前所有展示的信息，都用队列来处理 <只用来标识Dialog模块的内容>
  late Queue<DialogInfo> dialogQueue;

  //全局设定当前的Toast样式，在初始化的时候进行init方法调用的时候，会定义当前的toast类型
  late FlutterSmartToastBuilder toastBuilder;


  //Loading展示容器
  late OverlayEntry entryLoading;

  //Loading展示组件业务处理类
  late CustomLoading _loading;

  //loading能否支持返回消失
  bool loadingBackDismiss = true;

  late FlutterSmartLoadingBuilder loadingBuilder;

  //Dialog容器相关
  //显示的最后时间，用来短时间二次点击处理
  DateTime? dialogLastTime;


  //当前展示蒙层的context上下文
  static late BuildContext contextOverlay;
  //当前导航的最高级的上下文
  static BuildContext? contextNavigator;


  //在页面初始化时，进行创建，通过单例模式，保持后续获取的对象都是相同的
  factory DialogProxy() => instance;
  static DialogProxy? _instance;

  static DialogProxy get instance => _instance ??= DialogProxy._internal();

  DialogProxy._internal() {
    //初始化参数配置
    config = SmartConfig();
    dialogQueue = ListQueue();
  }

  //初始化当前组件信息
  void initialize() {
    //初始化当前的Toast悬浮组件
    entryToast = OverlayEntry(builder: (_){
      //回调时机：在Overlay.dart文件中的_OverlayEntryWidget/_OverlayEntryWidgetState调用，而Overlay/OverlayState中调用_OverlayEntryWidget该组件，开始回调，所以这里是挂载Overlay组件之后开始回调
      //也就是在init_dialog文件中，初始化的时候，初始化FlutterSmartDialog的时候在build方法Overlay组件创建完毕后回调，而initialize方法在FlutterSmartDialog的initState调用，所以一定调用完毕后才会走这里回调
      //initialize初始化执行完毕之后才会执行回调方法，这里保证当前的_toast一定不为空
      //调用markNeedsBuild方法刷新当前布局信息

      //调用show方法时，widget会初始化为对应的样式返回，刷新当前界面布局显示
      return _toast.getWidget();
    });

    //初始化当前Toast组件
    _toast = CustomToast(entryToast);


    //loading组件同toast
    entryLoading = OverlayEntry(builder: (_) => _loading.getWidget());
    _loading = CustomLoading(entryLoading);

  }


  //展示Toast方法
  Future<void> showToast({
    required AlignmentGeometry alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required bool consumeEvent,
    required Duration displayTime,
    required bool debounce,
    required SmartToastType displayType,
    required Widget widget,
  }) {
    return _toast.showToast(
      alignment: alignment,
      clickMaskDismiss: clickMaskDismiss,
      animationType: animationType,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      maskColor: maskColor,
      maskWidget: maskWidget,
      displayTime: displayTime,
      debounce: debounce,
      displayType: displayType,
      widget: ToastHelper(consumeEvent: consumeEvent, child: widget),
    );
  }


  //展示loading方法
  Future<T?> showLoading<T>({
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
    required Widget widget,
  }) {
    return _loading.showLoading<T>(
      clickMaskDismiss: clickMaskDismiss,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      backDismiss: backDismiss,
      widget: widget,
    );
  }

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
    required Widget? maskWidget,
    required bool debounce,
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
    CustomDialog? dialog;
    var entry = OverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(entry);
    return dialog.show<T>(
      widget: widget,
      alignment: alignment,
      usePenetrate: usePenetrate,
      useAnimation: useAnimation,
      animationTime: animationTime,
      animationType: animationType,
      maskColor: maskColor,
      maskWidget: maskWidget,
      clickMaskDismiss: clickMaskDismiss,
      debounce: debounce,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    );
  }



  Future<void>? dismiss<T>({
    required SmartStatus status,
    bool back = false,
    String? tag,
    T? result,
    bool force = false,
  }) {
    if (status == SmartStatus.smart) {
      //需要获取当前是否还显示在界面上，如果已经不显示了就不处理
      var loading = config.isExistLoading;
      if (!loading) {
        return CustomDialog.dismiss<T>(
          type: DialogType.dialog,
          back: back,
          tag: tag,
          result: result,
          force: force,
        );
      }
      if (loading) return _loading.dismiss(back: back);
    } else if (status == SmartStatus.toast) {
      return _toast.dismiss();
    } else if (status == SmartStatus.allToast) {
      return _toast.dismiss(closeAll: true);
    } else if (status == SmartStatus.loading) {
      //不显示在界面上就不处理
      var loading = config.isExistLoading;
      if(!loading){
        return null;
      }
      return _loading.dismiss(back: back);
    }

    DialogType? type = _convertEnum(status);
    if (type == null) return null;
    return CustomDialog.dismiss<T>(
      type: type,
      back: back,
      tag: tag,
      result: result,
      force: force,
    );
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
    required bool clickMaskDismiss,
    required Widget? maskWidget,
    required HighlightBuilder highlightBuilder,
    required bool debounce,
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
    CustomDialog? dialog;
    var entry = OverlayEntry(
      builder: (BuildContext context) => dialog!.getWidget(),
    );
    dialog = CustomDialog(entry);
    return dialog.showAttach<T>(
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
      maskWidget: maskWidget,
      highlightBuilder: highlightBuilder,
      clickMaskDismiss: clickMaskDismiss,
      debounce: debounce,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      tag: tag,
      backDismiss: backDismiss,
      keepSingle: keepSingle,
      permanent: permanent,
      useSystem: useSystem,
      bindPage: bindPage,
    );
  }

  DialogType? _convertEnum(SmartStatus status) {
    if (status == SmartStatus.dialog) {
      return DialogType.dialog;
    }  else if (status == SmartStatus.attach) {
      return DialogType.attach;
    } else if (status == SmartStatus.allDialog) {
      return DialogType.allDialog;
    } else if (status == SmartStatus.allAttach) {
      return DialogType.allAttach;
    }
    return null;
  }
}