import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/helper/route_record.dart';
import '../custom/custom_dialog.dart';
import '../data/smart_tag.dart';
import '../smart_dialog.dart';
import 'dialog_proxy.dart';

///描述:navigatorObservers中声明，监听当前路由情况
///功能介绍:主要处理调用Pop方法导致界面的返回
///创建者:翁益亨
///创建日期:2022/7/13 10:42
class SmartNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    //添加路由的情况，设定当前的context
    DialogProxy.contextNavigator ??= navigator?.context;
    //查看源码得知 route：primaryRoute/当前页面展示的路由  previousRoute：secondaryRoute/之前展示的路由
    RouteRecord.instance.push(route, previousRoute);

    //同步当前页面的路由信息
    RouteRecord.curRoute = route;

    //系统弹窗也是通过push一层路由显示
    //注意点：因为Dialog模式的浮层对象中是使用RouteRecord.curRoute进行匹配，处理（除系统Dialog）弹窗跟随页面的显示，所以系统弹窗后的所有自定义（除系统Dialog）弹窗都会跟随系统弹窗的路由绑定
    //生命周期和一般和页面挂钩的浮层有出入，暂无其他影响，只是做一个记录。可以用于多个浮窗有层级效果区别的实现，第一个浮窗选择完毕之后出来第二个浮窗，第一个浮窗要隐藏。第二个浮窗返回时，第一个浮窗要显示的情况
    //例如：和页面挂钩的浮层1，然后再打开系统浮层2，最后打开系统浮层2挂钩的普通浮层3.显示方式是：浮层3覆盖在浮层2显示，浮层1因为挂钩之前页面的navigator数据，所以暂时隐藏，直到系统浮层2退出
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    //物理返回键也会执行当前的方法
    //调用 Navigator.pop 会退出系统弹窗，在[custom_dialog.dart]文件中_closeSingle方法中会从队列中移除系统，所以不用处理

    //退出当前路由信息后同步转台
    //参数同didPush一致（previousRoute为Pop后显示的当前页面，route为即将退出的当前页面）

    RouteRecord.instance.pop(route, previousRoute);
    RouteRecord.popRoute = route;
    RouteRecord.curRoute = previousRoute;

    //系统弹窗消化完毕，重置状态
    RouteRecord.dialogBack = false;
  }
}
