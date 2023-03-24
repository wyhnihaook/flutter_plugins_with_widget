import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

///描述:对组件的生命周期进行注入
///功能介绍:TODO
///创建者:翁益亨
///创建日期:2022/7/13 14:54
class ViewUtil {
  static bool routeSafeUse = false;

  static void addSafeUse(VoidCallback callback) {
    var schedulerPhase = schedulerBinding.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      ViewUtil.addPostFrameCallback((timeStamp) => callback());
    } else {
      callback();
    }
  }

  static void addPostFrameCallback(FrameCallback callback) {
    //当前触发了界面更改，并且渲染完毕后，会调用一次callback后并移除当前的回调。如果需要再设置就要重写设置一次
    widgetsBinding.addPostFrameCallback(callback);
  }
}

///负责组件和引擎交互工作

//处理Widget, Element之间的一些业务，给Widget层注册生命周期的监听，亮度改变等等
WidgetsBinding get widgetsBinding => WidgetsBinding.instance;

//任务调度器，它负责处理对各种类型任务调度的时机, 执行 UI构建前/UI构建后的一些任务，除此之外还可以对任务进行优先级排序
SchedulerBinding get schedulerBinding => SchedulerBinding.instance;