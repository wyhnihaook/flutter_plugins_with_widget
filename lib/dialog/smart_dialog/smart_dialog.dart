import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/widget/attach_dialog_widget.dart';
import 'package:widget/dialog/smart_dialog/widget/smart_dialog_controller.dart';

import 'config/enum_config.dart';
import 'config/smart_config.dart';
import 'helper/dialog_proxy.dart';
import 'widget/dialog_scope.dart';

///描述:外部同一调用类方法，展示toast/loading/dialog信息
///功能介绍:展示组件容器
///统一处理当前的展示请求，通过DialogProxy的实体类去代理方法，去展示
///创建者:翁益亨
///创建日期:2022/7/13 14:16
class SmartDialog{

  /// SmartDialog全局配置
  static SmartConfig config = DialogProxy.instance.config;



  /// toast消息
  ///
  /// [msg]：呈现给用户的信息（使用[builder]参数自定义toast，该参数将失效）
  ///
  /// [controller]：可使用该控制器来刷新自定义的toast的布局
  ///
  /// [displayTime]：toast在屏幕上的显示时间
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭toast），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [debounce]：防抖功能
  ///
  /// [displayType]：提供多种显示逻辑，详细描述请查看 [SmartToastType] 注释
  ///
  /// [consumeEvent]：true（toast会消耗触摸事件），false（toast不再消耗事件，触摸事件能穿透toast）
  ///
  /// [builder]：自定义toast
  static Future<void> showToast(
      String msg, {
        SmartDialogController? controller,
        Duration? displayTime,
        AlignmentGeometry? alignment,
        bool? clickMaskDismiss,
        SmartAnimationType? animationType,
        bool? usePenetrate,
        bool? useAnimation,
        Duration? animationTime,
        Color? maskColor,
        Widget? maskWidget,
        bool? consumeEvent,
        bool? debounce,
        SmartToastType? displayType,
        WidgetBuilder? builder,
      }) async {
    return DialogProxy.instance.showToast(
      displayTime: displayTime ?? config.toast.displayTime,
      alignment: alignment ?? config.toast.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.toast.clickMaskDismiss,
      animationType: animationType ?? config.toast.animationType,
      usePenetrate: usePenetrate ?? config.toast.usePenetrate,
      useAnimation: useAnimation ?? config.toast.useAnimation,
      animationTime: animationTime ?? config.toast.animationTime,
      maskColor: maskColor ?? config.toast.maskColor,
      maskWidget: maskWidget ?? config.toast.maskWidget,
      debounce: debounce ?? config.toast.debounce,
      displayType: displayType ?? config.toast.displayType,
      consumeEvent: consumeEvent ?? config.toast.consumeEvent,
      widget: builder != null
          ? DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      )
          : DialogProxy.instance.toastBuilder(msg),
    );
  }

  /// loading弹窗
  ///
  /// [msg]：loading 的信息（使用[builder]参数，该参数将失效）
  ///
  /// [controller]：可使用该控制器来刷新自定义的loading的布局
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭loading），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），false（返回事件不会关闭loading，也不会关闭页面），
  /// 你仍然可以使用dismiss方法来关闭loading
  ///
  /// [builder]：自定义loading
  static Future<T?> showLoading<T>({
    String msg = 'loading...',
    SmartDialogController? controller,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    bool? backDismiss,
    WidgetBuilder? builder,
  }) {
    return DialogProxy.instance.showLoading<T>(
      clickMaskDismiss: clickMaskDismiss ?? config.loading.clickMaskDismiss,
      animationType: animationType ?? config.loading.animationType,
      usePenetrate: usePenetrate ?? config.loading.usePenetrate,
      useAnimation: useAnimation ?? config.loading.useAnimation,
      animationTime: animationTime ?? config.loading.animationTime,
      maskColor: maskColor ?? config.loading.maskColor,
      maskWidget: maskWidget ?? config.loading.maskWidget,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      backDismiss: backDismiss ?? config.loading.backDismiss,
      widget: builder != null
          ? DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      )
          : DialogProxy.instance.loadingBuilder(msg),
    );
  }

  /// 自定义弹窗
  ///
  /// [builder]：自定义 dialog
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [debounce]：防抖功能
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭;
  /// 注: 使用[displayTime]参数, 将禁止使用[tag]参数
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  ///
  /// [keepSingle]：默认（false），true（多次调用[show]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[show]会生成多个dialog）
  ///
  /// [permanent]：默认（false），true（将该dialog设置为永久化dialog）,false(不设置);-->注意：permanent设置为true，一定不能使用系统级弹窗
  /// 框架内部各种兜底操作(返回事件,路由)无法关闭永久化dialog, 需要关闭此类dialog可使用: dismiss(force: true)
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效; [tag], [keepSingle], [permanent]和[bindPage]禁止使用），
  /// false（使用SmartDialog），使用该参数可使SmartDialog, 与路由页面以及flutter自带dialog合理交互
  ///
  /// [bindPage]：将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  static Future<T?> show<T>({
    required WidgetBuilder builder,
    SmartDialogController? controller,
    AlignmentGeometry? alignment,
    bool? clickMaskDismiss,
    bool? usePenetrate,
    bool? useAnimation,
    SmartAnimationType? animationType,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    String? tag,
    bool? backDismiss,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
  }) {
    assert(
    (useSystem == true &&
        tag == null &&
        permanent == null &&
        keepSingle == null) ||
        (useSystem == null || useSystem == false),
    'useSystem is true; tag, keepSingle and permanent prohibit setting values',
    );
    assert(
    keepSingle == null || keepSingle == false || tag == null,
    'keepSingle is true, tag prohibit setting values',
    );
    assert(
    displayTime == null || tag == null,
    'displayTime is used, tag prohibit setting values',
    );

    return DialogProxy.instance.show<T>(
      widget: DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      ),
      alignment: alignment ?? config.dialog.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.dialog.clickMaskDismiss,
      animationType: animationType ?? config.dialog.animationType,
      usePenetrate: usePenetrate ?? config.dialog.usePenetrate,
      useAnimation: useAnimation ?? config.dialog.useAnimation,
      animationTime: animationTime ?? config.dialog.animationTime,
      maskColor: maskColor ?? config.dialog.maskColor,
      maskWidget: maskWidget ?? config.dialog.maskWidget,
      debounce: debounce ?? config.dialog.debounce,
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      tag: tag,
      backDismiss: backDismiss ?? config.dialog.backDismiss,
      keepSingle: keepSingle ?? false,
      permanent: permanent ?? false,
      useSystem: useSystem ?? false,
      bindPage: bindPage ?? config.dialog.bindPage,
    );
  }

  /// 定位弹窗
  ///
  /// [targetContext]：伴随位置widget的BuildContext
  ///
  /// [builder]：自定义 dialog
  ///
  /// [replaceBuilder]：[replaceBuilder]中返回widget会替换掉[builder]中返回的widget;
  /// [replaceBuilder]将回调目标widget的坐标,大小和dialog自身的坐标,大小, 你可以根据这些参数,重新自定义一个合适的替换widget,
  /// 强烈建议[replaceBuilder]返回的自定义的widget宽高和[builder]中的保持一致, showAttach中定位信息都是根据[builder]中widget计算得来的
  ///
  /// [controller]：可使用该控制器来刷新自定义的dialog的布局
  ///
  /// [targetBuilder]：手动指定合适坐标点，当targetBuilder被使用时，targetContext参数将无法自动设置位置,
  /// targetBuilder回调的参数是根据targetContext计算得来的
  ///
  /// [alignment]：控制弹窗的位置
  ///
  /// [clickMaskDismiss]：true（点击遮罩后，将关闭dialog），false（不关闭）
  ///
  /// [animationType]：具体可参照[SmartAnimationType]注释
  ///
  /// [scalePointBuilder]：缩放动画的缩放点, 默认点将自定义dialog控件的中心点作为缩放点;
  /// Offset(0, 0): 将控件左上点作为缩放点, Offset(控件宽度, 0): 将控件右上点作为缩放点
  /// Offset(0, 控件高度): 将控件左下点作为缩放点, Offset(控件宽度, 控件高度): 将控件右下点作为缩放点
  ///
  /// [usePenetrate]：true（点击事件将穿透遮罩），false（不穿透）
  ///
  /// [useAnimation]：true（使用动画），false（不使用）
  ///
  /// [animationTime]：动画持续时间
  ///
  /// [maskColor]：遮罩颜色，如果给[maskWidget]设置了值，该参数将会失效
  ///
  /// [maskWidget]：可高度定制遮罩
  ///
  /// [debounce]：防抖功能
  ///
  /// [highlightBuilder]：高亮功能，溶解特定区域的遮罩，可以快速获取目标widget信息（坐标和大小）
  ///
  /// [onDismiss]：在dialog被关闭的时候，该回调将会被触发
  ///
  /// [onMask]：点击遮罩时，该回调将会被触发
  ///
  /// [displayTime]：控制弹窗在屏幕上显示时间; 默认为null, 为null则代表该参数不会控制弹窗关闭;
  /// 注: 使用[displayTime]参数, 将禁止使用[tag]参数
  ///
  /// [tag]：如果你给dialog设置了tag, 你可以针对性的关闭它
  ///
  /// [backDismiss]：true（返回事件将关闭loading，但是不会关闭页面），
  /// false（返回事件不会关闭loading，也不会关闭页面），你仍然可以使用dismiss方法来关闭loading
  ///
  /// [keepSingle]：默认（false），true（多次调用[showAttach]并不会生成多个dialog，仅仅保持一个dialog），
  /// false（多次调用[showAttach]会生成多个dialog）
  ///
  /// [permanent]：默认（false），true（将该dialog设置为永久化dialog）,false(不设置);
  /// 框架内部各种兜底操作(返回事件,路由)无法关闭永久化dialog, 需要关闭此类dialog可使用: dismiss(force: true)
  ///
  /// [useSystem]：默认（false），true（使用系统dialog，[usePenetrate]功能失效; [tag], [keepSingle], [permanent]和[bindPage]禁止使用），
  /// false（使用SmartDialog），使用该参数可使SmartDialog, 与路由页面以及flutter自带dialog合理交互
  ///
  /// [bindPage]：将该dialog与当前页面绑定，绑定页面不在路由栈顶，dialog自动隐藏，绑定页面置于路由栈顶，dialog自动显示;
  /// 绑定页面被关闭,被绑定在该页面上的dialog也将被移除
  static Future<T?> showAttach<T>({
    required BuildContext? targetContext,
    required WidgetBuilder builder,
    ReplaceBuilder? replaceBuilder,
    SmartDialogController? controller,
    TargetBuilder? targetBuilder,
    AlignmentGeometry? alignment,
    bool? clickMaskDismiss,
    SmartAnimationType? animationType,
    ScalePointBuilder? scalePointBuilder,
    bool? usePenetrate,
    bool? useAnimation,
    Duration? animationTime,
    Color? maskColor,
    Widget? maskWidget,
    bool? debounce,
    HighlightBuilder? highlightBuilder,
    VoidCallback? onDismiss,
    VoidCallback? onMask,
    Duration? displayTime,
    String? tag,
    bool? backDismiss,
    bool? keepSingle,
    bool? permanent,
    bool? useSystem,
    bool? bindPage,
  }) {
    assert(
    targetContext != null || targetBuilder != null,
    'targetContext and target, cannot both be null',
    );
    assert(
    (useSystem == true &&
        tag == null &&
        permanent == null &&
        keepSingle == null) ||
        (useSystem == null || useSystem == false),
    'useSystem is true; tag, keepSingle and permanent prohibit setting values',
    );
    assert(
    keepSingle == null || keepSingle == false || tag == null,
    'keepSingle is true, tag prohibit setting values',
    );
    assert(
    displayTime == null || tag == null,
    'displayTime is used, tag prohibit setting values',
    );
    if(alignment!=null){
      print(alignment);
    }
    var highlight = highlightBuilder;
    return DialogProxy.instance.showAttach<T>(
      targetContext: targetContext,
      widget: DialogScope(
        controller: controller,
        builder: (context) => builder(context),
      ),
      targetBuilder: targetBuilder,
      replaceBuilder: replaceBuilder,
      alignment: alignment ?? config.attach.alignment,
      clickMaskDismiss: clickMaskDismiss ?? config.attach.clickMaskDismiss,
      animationType: animationType ?? config.attach.animationType,
      scalePointBuilder: scalePointBuilder,
      usePenetrate: usePenetrate ?? config.attach.usePenetrate,
      useAnimation: useAnimation ?? config.attach.useAnimation,
      animationTime: animationTime ?? config.attach.animationTime,
      maskColor: maskColor ?? config.attach.maskColor,
      maskWidget: maskWidget ?? config.attach.maskWidget,
      debounce: debounce ?? config.attach.debounce,
      highlightBuilder: highlight ?? (_, __) => Positioned(child: Container()),
      onDismiss: onDismiss,
      onMask: onMask,
      displayTime: displayTime,
      tag: tag,
      backDismiss: backDismiss ?? config.attach.backDismiss,
      keepSingle: keepSingle ?? false,
      permanent: permanent ?? false,
      useSystem: useSystem ?? false,
      bindPage: bindPage ?? config.attach.bindPage,
    );
  }

  /// 关闭dialog
  ///
  /// [status]：具体含义可参照[SmartStatus]注释
  /// 注意：status参数设置值后，closeType参数将失效。
  ///
  /// [tag]：如果你想关闭指定的dialog，你可以给它设置一个tag
  ///
  /// [result]：设置一个返回值,可在调用弹窗的地方接受
  ///
  /// [force]：强制关闭永久化的dialog; 使用该参数, 将优先关闭永久化dialog
  static Future<void> dismiss<T>({
    SmartStatus status = SmartStatus.smart,
    String? tag,
    T? result,
    bool force = false,
  }) async {
    return DialogProxy.instance.dismiss<T>(
      status: status,
      tag: tag,
      result: result,
      force: force,
    );
  }
}