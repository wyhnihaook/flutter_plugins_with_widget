import 'package:flutter/material.dart';

///描述:控制显示不占位内容
///功能介绍:从主组件中分离，因为只用来控制状态
///创建者:翁益亨
///创建日期:2022/7/6 16:52

const animationDuration = Duration(milliseconds: 300);

class OffstageView extends StatefulWidget {
  ///必填参数
  final Widget child;

  ///非必填参数
  //当前是否需要显示，默认显示
  final bool isVisible;

  const OffstageView(this.child, {this.isVisible = false, Key? key})
      : super(key: key);

  @override
  State<OffstageView> createState() => OffstageViewState();
}

class OffstageViewState extends State<OffstageView> //用于动画刷新帧监听
    with
        TickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _animation;

  late bool isVisibleStatus;

  @override
  void initState() {
    super.initState();

    isVisibleStatus = widget.isVisible;

    //初始化动画效果
    _animationController = AnimationController(
        //动画时长
        duration: animationDuration,
        //反向执行动画的时间
        reverseDuration: animationDuration,
        //controller变化最小值
        lowerBound: 0.0,
        //变化最大值
        upperBound: 1.0,
        vsync: this);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //当前动画完成
        if(!isVisibleStatus){
          //隐藏情况，需要刷新界面
          setState(() {
          });
        }
      }
    });

    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("isVisibleStatus $isVisibleStatus");
    return Offstage(
      //隐藏时不占位置
      //false显示，true隐藏
      offstage: !isVisibleStatus,
      child: FadeTransition(
        opacity: _animation,
        child: widget.child,
      ),
    );
  }

  //外部控制组件的状态
  void setVisibleStatus(bool isVisible) {
    if (isVisibleStatus == isVisible) {
      //不再重复处理当前数据
      return;
    }

    if (_animationController.isAnimating) {
      //暂停之前的动画效果
      _animationController.stop();
    }

    if (isVisible) {
      //显示是反向动画
      setState(() {
        isVisibleStatus = isVisible;
      });
      _animationController.reverse(from: _animationController.value);
    } else {
      //正向动画隐藏
      isVisibleStatus = isVisible;

      _animationController.forward(from: _animationController.value);
    }
  }
}
