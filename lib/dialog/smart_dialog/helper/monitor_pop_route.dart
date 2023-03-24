import 'package:flutter/material.dart';

import '../config/enum_config.dart';
import '../data/dialog_info.dart';
import '../data/smart_tag.dart';
import '../util/view_util.dart';
import 'route_record.dart';
import 'dialog_proxy.dart';

typedef PopTestFunc = bool Function();

///描述:入口初始化的builder入口中初始化声明，监听当前路由情况
///功能介绍:主要处理（返回键、AppBar的back按钮）导致界面的返回，会联动到Pop回调状态，详见[navigator_observer.dart]
///创建者:翁益亨
///创建日期:2022/7/13 10:42
class MonitorPopRoute with WidgetsBindingObserver {
  factory MonitorPopRoute() => instance;

  static MonitorPopRoute? _instance;

  static MonitorPopRoute get instance => _instance ??= MonitorPopRoute._();

  //设置本地监听器
  MonitorPopRoute._() {
    //检查widgetsBinding实例是否为null。如果是null，就创建一个实例，避免监听器（所以这里一定要先调用该方法检查，确保下面的实例存在）
    WidgetsFlutterBinding.ensureInitialized();
    //WidgetsBinding Widget层与Flutter engine的桥梁；监听的是（返回键、AppBar的back按钮）造成的返回情况
    widgetsBinding.addObserver(this);
  }

  //页面弹出回调-关闭页面时调用
  //返回true时拦截页面返回，false是不拦截
  @override
  Future<bool> didPopRoute() async {

    //表明系统弹窗正在退出中，避免快速点击返回键造成的问题
    if(RouteRecord.dialogBack)return true;

    if(RouteRecord.loadingBack)return true;

    //这里要判断是否存在dialog/loading，如果存在就关闭并拦截当前返回的请求
    //系统级别的弹窗，点击返回相当于Pop了一级页面，所以不用处理，本身响应即可

    bool deal = RouteRecord.instance.handleSmartDialog();

    if (deal) {
      //自定义弹窗这里消化
      DialogProxy.instance.dismiss(status: SmartStatus.smart, back: true);
      return true;
    }

    //情况1：两个系统弹窗，都不允许点击返回键返回，但是上一个允许点击背景消失。无法锁定到当前弹窗无法返回 ->已处理<removeLast手动调用>
    //情况2：蒙层和返回键产生的冲突，使用唯一标识[route_record.dart]文件的routeBack进行标识，点击返回或者蒙层的时候，都会走_closeSingle方法，在最终执行前进行标识添加，设置为true。系统弹窗回调[navigator_observer。dart]文件重置。普通自定义弹窗在方法调用结束后重置，蒙层添加判断再处理一个事件中不响应

    //匹配系统弹窗是否响应物理返回键，如果不能返回
    if(DialogProxy.instance.dialogQueue.isNotEmpty&& DialogProxy.instance.dialogQueue.last.useSystem){

      //如果是系统级的弹窗，并且可以通过backDismiss返回，就要从列表中移除
      if(!DialogProxy.instance.dialogQueue.last.backDismiss){
        return true;
      }else{
        //当前系统弹窗能返回，那么就要从列表中移除对应的浮层，然后将事件交给系统处理返回
        DialogProxy.instance.dialogQueue.removeLast();
      }

    }

    //系统返回也应该做拦截，返回后必定重置
    RouteRecord.dialogBack = true;

    //系统弹窗由[navigator_observer.dart]消化
    //执行到这里就是关闭页面级别的系统showDialog API调用弹窗

    Future<bool> popStatus = super.didPopRoute();

    popStatus.then((value){
      if(!value){
        //如果返回失败，就不会走回调[navigator_observer.dart]方法，需要这里做重置,避免返回问题
        RouteRecord.dialogBack = false;
      }
    });

    return popStatus;//调用super会走路由监听的回调[navigator_observer.dart]中的didPop方法

  }
}
