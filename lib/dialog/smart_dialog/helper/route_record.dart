import 'dart:collection';

import 'package:flutter/material.dart';

import '../data/smart_tag.dart';
import '../smart_dialog.dart';
import 'dialog_proxy.dart';

///路由管理帮助类
class RouteRecord {
  factory RouteRecord() => instance;
  static RouteRecord? _instance;

  static RouteRecord get instance => _instance ??= RouteRecord._internal();

  //模拟构建路由栈
  static late Queue<Route<dynamic>> routeQueue;

  //当前展示的路由
  static Route<dynamic>? curRoute;

  //当前正在退出的路由
  static Route<dynamic>? popRoute;

  ///避免快速点击蒙层/物理返回键导致多次执行返回回调，添加执行过程的锁
  //记录dialog浮层正在退出
  static bool dialogBack = false;

  //记录loading浮层正在退出，loading是自定义的，所以不像dialog需要在系统回调监听，只需要在执行入口判断，出口重置即可
  static bool loadingBack = false;


  RouteRecord._internal() {
    routeQueue = DoubleLinkedQueue();
  }

  //路由切换到下一个页面时，额外进行的操作
  void push(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _offstageDialog(previousRoute);
    if (DialogProxy.instance.dialogQueue.isEmpty) return;
    routeQueue.add(route);
  }

  //路由退出路由栈时，额外进行的操作
  void pop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onstageDialog(previousRoute);
    if (routeQueue.isEmpty) return;
    routeQueue.remove(route);
  }

  //物理键返回，AppBar上的back按下时返回，判断是否需要处理列表内容
  //以为overlay的浮层级别是最高的，不会因为页面切换而消失，所以要在页面切换时控制对应之前界面的隐藏
  bool handleSmartDialog() {
    //默认是存在需要处理的弹窗信息
    bool shouldHandle = true;
    try {
      //存在Loading的情况
      if (SmartDialog.config.isExistLoading) {
        return true;
      }

      //存在Dialog的情况
      if (DialogProxy.instance.dialogQueue.isEmpty) {
        //队列不存在弹窗的情况，重置存储队列
        if (routeQueue.isNotEmpty) routeQueue.clear();
        shouldHandle = false;
      } else {
        //获取队列中最后一个数据
        var info = DialogProxy.instance.dialogQueue.last;

        //处理系统弹窗的问题，这里尝试去匹配最后一个弹窗是否是自定义的tag
        //useSystem：true，调用系统方法showDialog方法弹窗 。参考[main_dialog.dart]文件中showDialog方法调用时机
        if (info.useSystem) {
          shouldHandle = false;
        }

        //这里匹配不是系统弹窗的情况
        //匹配最后一个浮层，是否属于当前页面内容，如果是，就设置显示状态
        bool offstage = info.dialog.mainDialog.offstage;

        //兜底逻辑，其他页面在切换的时候会设置offstage为true，标识已经隐藏
        //如果最后一个界面是隐藏的 或者 是永久存储的类型，就不处理
        if (offstage || info.permanent) {
          shouldHandle = false;
        }

      }
    } catch (e) {
      shouldHandle = false;
      print('SmartDialog back event error:${e.toString()}');
    }

    return shouldHandle;
  }

  //页面隐藏之后进行的操作
  void _offstageDialog(Route<dynamic>? curRoute) {
    //如果没有需要处理的Dialog信息就不做操作
    if (curRoute == null || DialogProxy.instance.dialogQueue.isEmpty) return;

    //遍历数据，设置关联页面的弹窗临时隐藏，然后刷新弹窗容器布局
    //注意：这里的curRoute指的时之前隐藏的页面
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == curRoute && item.bindPage) {
        item.dialog.mainDialog.offstage = true;
        item.dialog.overlayEntry.markNeedsBuild();
      }
    }
  }

  //页面展示到前台后操作
  void _onstageDialog(Route<dynamic>? curRoute) {
    //如果没有需要处理的Dialog信息就不做操作
    if (curRoute == null || DialogProxy.instance.dialogQueue.isEmpty) return;

    //遍历数据，设置关联页面的弹窗显示，然后刷新弹窗容器布局
    //注意：这里的curRoute指的时现在显示的页面
    for (var item in DialogProxy.instance.dialogQueue) {
      if (item.route == curRoute && item.bindPage) {
        item.dialog.mainDialog.offstage = false;
        item.dialog.overlayEntry.markNeedsBuild();
      }
    }
  }
}
