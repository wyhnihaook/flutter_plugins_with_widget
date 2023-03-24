import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:widget/dialog/smart_dialog/data/base_dialog.dart';

import '../config/enum_config.dart';
import '../smart_dialog.dart';

///描述:Toast展示容器组件
///功能介绍:固定的容器组件，处理Toast定义属性
///创建者:翁益亨
///创建日期:2022/7/13 15:25
class CustomToast extends BaseDialog{

  CustomToast(super.overlayEntry);

  //存储Toast展示的任务队列 <模式相同展示的列表>
  Queue<Future<void> Function()> _toastQueue = ListQueue();

  //临时存储数据<模式不相同展示的列表>
  Queue<_ToastInfo> _tempQueue = ListQueue();

  //toast已经显示，开始执行倒计时任务隐藏toast
  Timer? _curTime;

  //时间
  DateTime? _lastTime;

  //完成事件队列消息通知，在异步返回未知的情况，返回Completer实例.future，当前await方法的调用将不会往下执行，直到收到Completer实例.complete(返回的参数-可缺省)才会往下执行
  Completer? _curCompleter;

  //展示的toast的模式
  SmartToastType? _lastType;

  //展示toast方法
  Future<void> showToast({
    required AlignmentGeometry alignment,
    required bool clickMaskDismiss,
    required SmartAnimationType animationType,
    required bool usePenetrate,
    required bool useAnimation,
    required Duration animationTime,
    required Color maskColor,
    required Widget? maskWidget,
    required Duration displayTime,
    required bool debounce,
    required SmartToastType displayType,
    required Widget widget,
  }) async {

    if (debounce) {
      // 是否在规定时间内只响应一次手势触发操作<弊端会重新计时，容易造成toast内容隐藏后无法再显示对应的toast内容>
      var now = DateTime.now();
      var isShake = _lastTime != null &&
          now.difference(_lastTime!) < SmartDialog.config.toast.debounceTime;
      _lastTime = now;
      if (isShake) return;
    }

    //界面上设置显示属性
    SmartDialog.config.toast.isExist = true;

    //内部方法声明，当前最终调用的显示toast的组件MainDialog <当前类只是对队列的处理，控制显示的交互>
    showToast() {
      mainDialog.show(
        widget: widget,
        alignment: alignment,
        maskColor: maskColor,
        maskWidget: maskWidget,
        animationTime: animationTime,
        animationType: animationType,
        useAnimation: useAnimation,
        usePenetrate: usePenetrate,
        onDismiss: null,
        useSystem: false,
        reuse: false,
        awaitOverType: SmartDialog.config.toast.awaitOverType,
        onMask: () => clickMaskDismiss ? _realDismiss() : null,
      );
    }

    //异步内部方法，设定从队列取出toast任务的方式
    Future<void> multiTypeToast() async {
      if (displayType == SmartToastType.normal) {
        //普通模式，先进先出，依次显示（显示完毕后再显示下一个队列中的任务）
        await _normalToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.first) {
        await _firstToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.last) {
        await _lastToast(time: displayTime, onShowToast: showToast);
      } else if (displayType == SmartToastType.firstAndLast) {
        await _firstAndLastToast(time: displayTime, onShowToast: showToast);
      }

      afterDismiss();
    }

    //处理不同类型的toast
    await handleMultiTypeToast(curType: displayType, fun: multiTypeToast);
  }

  //普通展示toast模式
  Future<void> _normalToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    //先进行弹出toast任务的添加，等待当前轮询器从队列中获取展示到界面上
    _toastQueue.add(() async {
      //特殊情况处理，当前内容不存在的情况，理论上不存在这种情况
      if (_toastQueue.isEmpty) return;
      //在界面上显示toast的方法调用
      onShowToast();
      //延迟等待显示时长，这里要注意：显示动画时间执行过程在延时时间内
      await _toastDelay(time);
      //显示时长到达后使当前toast消失，这里要注意：调用smart_dialog_widget.dart文件中的回调dismiss方法，执行消失动画
      await _realDismiss();
      //从队列中移除当前执行完毕的任务
      if (_toastQueue.isNotEmpty) _toastQueue.removeFirst();
      //继续从队列中获取下一个要展示的任务并执行
      if (_toastQueue.isNotEmpty) await _toastQueue.first();
    });

    //添加任务完毕之后，判断队列中如果只有一个任务，就立即执行（.first获取队列存储内容.first()获取并执行）
    if (_toastQueue.length == 1) await _toastQueue.first();
  }

  //当前存在toast信息时，将不再添加任何新的toast任务
  Future<void> _firstToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    //当前存在数据就返回
    if (_toastQueue.isNotEmpty) return;

    //如果不存在任务，就将当前toast任务添加到队列中，队列添加空数据，只是为了统一流程，添加完毕之后显示完毕后立即移除
    _toastQueue.add(() async {});
    onShowToast();
    await _toastDelay(time);
    await _realDismiss();

    if (_toastQueue.isNotEmpty) _toastQueue.removeLast();
  }

  //立即执行当前需要显示的toast内容，覆盖当前显示的内容
  Future<void> _lastToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    //这里实现的方式是以MainDialog中实际展示界面组件SmartDialogWidget通过新建，overlayEntry的builder回调会摒弃老的组件内容，老的组件走dispose回调被释放了
    //当前MainDialog的show方法调用后，悬浮组件会使用新的SmartDialogWidget刷新到界面上，老的显示内容被覆盖
    //这里要明白mainDialog是在当前类实例中是唯一的，不用关心队列情况，直接执行方法即可
    onShowToast();
    _toastQueue.add(() async {});
    await _toastDelay(time);
    if (_toastQueue.length == 1) await _realDismiss();

    if (_toastQueue.isNotEmpty) _toastQueue.removeLast();
  }


  //最多只保留两条显示toast，当前显示的一条和显示时间内产生的最后一条
  Future<void> _firstAndLastToast({
    required Duration time,
    required Function() onShowToast,
  }) async {
    //每个任务都正常添加，保留最新的在最后执行，将任务移除队列即可
    _toastQueue.add(() async {
      if (_toastQueue.isEmpty) return;

      onShowToast();
      await _toastDelay(time);
      await _realDismiss();

      //remove current toast
      if (_toastQueue.isNotEmpty) _toastQueue.removeFirst();
      //invoke next toast
      if (_toastQueue.isNotEmpty) await _toastQueue.first();
    });

    //只有一条数据的情况，立即执行方法
    if (_toastQueue.length == 1) await _toastQueue.first();
    //移除后保留原来角标为2的最后一条数据
    if (_toastQueue.length > 2) _toastQueue.remove(_toastQueue.elementAt(1));
  }

  //延迟等待当前toast显示完整
  Future _toastDelay(Duration duration) {
    var completer = _curCompleter = Completer();
    _curTime = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  //额外处理和当前不匹配的Toast类型，统一添加到临时的队列中<在当前类型显示完成之后，再进行匹配是否需要显示>
  Future<void> handleMultiTypeToast({
    required SmartToastType curType,
    required Future<void> Function() fun,
  }) async {
    _lastType = _lastType ?? curType;
    //模式是否存在不匹配的情况  或者  临时列表存在数据 当前存储的类型就转化到临时列表显示逻辑<为了适配当前不同显示规则>
    var useTempQueue = _lastType != curType || _tempQueue.isNotEmpty;
    _lastType = curType;
    if (useTempQueue) {
      //模式不相同（一定不时第一次添加的内容），先将当前需要显示的内容添加到队列中，等待当前的任务执行完毕之后，在afterDismiss方法中等待回调
      //在这里会将方法进行存储，不会往_toastQueue队列中添加数据
      //一旦存在不相同的模式，后续内容都会往临时列表存储
      _tempQueue.add(_ToastInfo(type: curType, fun: fun));
    } else {
      //模式相同的情况，直接执行对应的方法
      await fun();
    }
  }

  //当前类型的toast显示完毕之后，处理队列中存在<不一致>内容
  void afterDismiss() {
    if (_tempQueue.isEmpty && _toastQueue.isEmpty) {
      //不存在数据内容时，重置队列和显示类型
      _lastType = null;
      _tempQueue = ListQueue();
      _toastQueue = ListQueue();
    }

    //当前没有不一致内容的情况  或者  当前当前模式列表不是空 就不进行额外处理
    if (_tempQueue.isEmpty || _toastQueue.isNotEmpty) return;

    //存在不一致的数据内容，获取最近添加的对象
    _ToastInfo lastToast = _tempQueue.first;

    //将和当前显示模型 匹配 到的toast类型添加到list列表，一旦没有匹配到相同类型，就break，不处理
    List<_ToastInfo> list = [];
    for (var item in _tempQueue) {
      //第一个角标一定能匹配到
      if (item.type != lastToast.type) break;

      //匹配到之后，执行对应的任务，并且从_tempQueue队列中移除
      //这里一次性往_toastQueue添加多个相同的模式的Toast，但是只有第一次添加的时候会执行_toastQueue.first()，其他都是添加完毕后不直接响应
      //等待第一个任务执行完毕之后再从原来的队列中获取对应需要展示的内容进行展示，这个时候_toastQueue队列不为空，该方法在执行任务完毕后不会响应直到_toastQueue为空
      lastToast = item;
      list.add(item);
      item.fun();
    }

    list.forEach((element) => _tempQueue.remove(element));
  }

  //隐藏当前的toast显示内容
  Future<void> _realDismiss() async {
    await mainDialog.dismiss();
    //延迟处理，用于处理界面上两个toast的显示时间差
    await Future.delayed(SmartDialog.config.toast.intervalTime);
    if (_toastQueue.length > 1) return;
    SmartDialog.config.toast.isExist = false;
  }


  //暂时不需要理解---------------------------------------------------
  Future<T?> dismiss<T>({bool closeAll = false}) async {
    if (closeAll) _toastQueue.clear();
    _curTime?.cancel();
    if (!(_curCompleter?.isCompleted ?? true)) _curCompleter?.complete();
    await Future.delayed(SmartDialog.config.toast.animationTime);
    await Future.delayed(const Duration(milliseconds: 50));
    return null;
  }
}


///存储和当前展示中不一样的SmartToastType模式的toast 对象
class _ToastInfo {
  _ToastInfo({required this.type, required this.fun});

  SmartToastType type;
  Future<void> Function() fun;
}
