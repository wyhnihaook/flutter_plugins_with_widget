import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/util/view_util.dart';
import 'package:widget/dialog/smart_dialog/widget/loading_widget.dart';
import 'package:widget/dialog/smart_dialog/widget/toast_widget.dart';

import 'helper/dialog_proxy.dart';
import 'helper/monitor_pop_route.dart';
import 'helper/navigator_observer.dart';

///描述:页面初始化时，进行dialog属性样式的初始化
///功能介绍:初始化dialog属性样式，init方法绑定在当前的builder入口处
///主要用来处理物理<返回键、AppBar的back按钮  查看MonitorPopRoute.instance>、<手动Pop方法调用  查看observer>
///创建者:翁益亨
///创建日期:2022/7/13 10:42
typedef FlutterSmartToastBuilder = Widget Function(String msg);
typedef FlutterSmartLoadingBuilder = Widget Function(String msg);

///初始化入口
class FlutterSmartDialog extends StatefulWidget {
  ///传递当前子组件，显示的具体内容
  final Widget child;

  ///设置默认的Toast样式
  final FlutterSmartToastBuilder? toastBuilder;

  //设置默认的Loading样式
  final FlutterSmartLoadingBuilder? loadingBuilder;

  const FlutterSmartDialog({required this.child, this.toastBuilder,this.loadingBuilder, Key? key})
      : super(key: key);

  @override
  State<FlutterSmartDialog> createState() => _FlutterSmartDialogState();

  static final observer = SmartNavigatorObserver();

  ///初始化展示的样式组件
  static TransitionBuilder init({
    //动画构造器
    TransitionBuilder? builder,
    //set default toast widget
    FlutterSmartToastBuilder? toastBuilder,
    //set default loading widget
    FlutterSmartLoadingBuilder? loadingBuilder,

  }) {
    MonitorPopRoute.instance;

    //入参和MaterialApp-builder属性一致，在应用初始化时，创建一些公共的组件
    return (BuildContext context, Widget? child) {
      //根据当前动画需求创建对应的组件
      return builder == null
          ? FlutterSmartDialog(
        toastBuilder: toastBuilder,
        loadingBuilder: loadingBuilder,
        child: child??const SizedBox(),
      )
          : builder(
        context,
        FlutterSmartDialog(
          toastBuilder: toastBuilder,
          loadingBuilder: loadingBuilder,
          child: child??const SizedBox(),
        ),
      );
    };
  }
}

class _FlutterSmartDialogState extends State<FlutterSmartDialog> {
  @override
  void initState() {
    //当前代理的导航信息在<>调用
    ViewUtil.addPostFrameCallback((timeStamp) {
      try {
        var navigator = widget.child as Navigator;
        var key = navigator.key as GlobalKey;
        DialogProxy.contextNavigator = key.currentContext;
      } catch (e) {}
    });

    var proxy = DialogProxy.instance;
    // 初始化基础组件
    proxy.initialize();

    //默认的Toast样式声明
    defaultToast(String msg) {
      return ToastView(msg);
    }

    //默认的loading样式
    defaultLoading(String msg) {
      return LoadingView(msg);
    }

    //判断是否在初始化时声明/复写过FlutterSmartToastBuilder方法，设定返回的全局Toast样式，如果存在就沿用，不存在就使用默认的样式（在init方法中进行传递）
    proxy.toastBuilder = widget.toastBuilder ?? defaultToast;

    proxy.loadingBuilder = widget.loadingBuilder ?? defaultLoading;


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent, child: _buildOverlay());
  }

  Widget _buildOverlay() {
    //初始化悬浮层，将预设的组件信息插入，等待控制显示，这里就只处理loading/toast。dialog另外处理
    return Overlay(initialEntries: [
      //main layout
      OverlayEntry(
        builder: (BuildContext context) => widget.child,
      ),

      //provided separately for custom dialog
      OverlayEntry(builder: (BuildContext context) {
        DialogProxy.contextOverlay = context;
        return Container();
      }),

      //provided separately for loading
      // DialogProxy.instance.entryLoading,
      DialogProxy.instance.entryLoading,

      //provided separately for toast
      DialogProxy.instance.entryToast,
    ]);
  }
}
