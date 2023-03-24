import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widget/swiper/swiper_config.dart';

///描述:轮播界面信息
///功能介绍:轮播组件
///创建者:翁益亨
///创建日期:2022/8/10 15:52
///核心使用pageView实现（基于当前数据结构比较简单的情况，不依赖其他插件实现）
///所有属性通过中间转化，设置swiper_config中属性
///使用该组件必须每一个页面都一致，只是根据数据变化
class Swiper extends StatefulWidget {
  final double height;

  final Color backgroundColor;

  final SwiperConfig? swiperConfig;

  const Swiper(
      {this.height = 300,
      this.backgroundColor = Colors.white,
      this.swiperConfig,
      Key? key})
      : super(key: key);

  @override
  _SwiperState createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  //当前选中的角标
  int currentIndex = 0;

  late PageController _controller;

  late SwiperConfig _swiperConfig;

  late Timer? _timer;

  @override
  void initState() {
    super.initState();

    //可以使用api快速定位
    _controller = PageController();

    //初始化轮播参数
    _swiperConfig = widget.swiperConfig ?? SwiperConfig();

    //1.识别是否需要开启轮播
    if (_swiperConfig.autoplay) {
      //在页面渲染完毕之后，启动定时器
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //开启定时器
        startTimer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //这里使用Listener更能有效监听手势的抬起和按下操作
    return Listener(
      onPointerUp: (_) {
        //抬起手势，重新开始定时器
        if (_swiperConfig.autoplay) {
          startTimer();
        }
      },
      onPointerDown: (_) {
        //按下手势，取消定时器
        if (_swiperConfig.autoplay) {
          cancelTimer();
        }
      },
      child: Container(
        height: widget.height,
        color: widget.backgroundColor,
        child: Stack(
          children: [
            PageView(
              //默认是提供侧滑的功能
              controller: _controller,
              onPageChanged: (index) {
                //定位到第几个,选中的index角标信息
                setState((){
                  currentIndex = index;
                });
              },
              //返回当前个数的item信息
              children: List.generate(
                  _swiperConfig.itemCount,
                  (index) => _swiperConfig.itemBuilder != null
                      ? _swiperConfig.itemBuilder!(index)
                      : const SizedBox()),
            ),
            //指示器显示
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: _swiperConfig.indicatorPadding),
                  child: Opacity(
                    opacity: _swiperConfig.showIndicator ? 1 : 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          _swiperConfig.itemCount,
                          (index){
                            return _swiperConfig.itemIndicatorBuilder != null
                                ? Padding(
                              padding: EdgeInsets.only(
                                  left: _swiperConfig.indicatorPadding / 2,
                                  right:
                                  _swiperConfig.indicatorPadding / 2),
                              child: _swiperConfig
                                  .itemIndicatorBuilder!(index,currentIndex),
                            )
                                : const SizedBox();
                          }),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  void startTimer() {

    _timer = Timer.periodic(_swiperConfig.delayPlayDuration, (_) {
      //时间到达后执行，判断是否当前是最后一条数据，如果是的情况
      //curve属性设置
      //linear	匀速的
      // decelerate	匀减速
      // ease	开始加速，后面减速
      // easeIn	开始慢，后面快
      // easeOut	开始快，后面慢
      // easeInOut	开始慢，然后加速，最后再减速
      int switchIndex =
          currentIndex + 1 >= _swiperConfig.itemCount ? 0 : currentIndex + 1;

      //为了效果正常，这里到最后一页时，快速切换到第一页
      if(switchIndex == 0){
        _controller.jumpToPage(switchIndex);//无动画效果
      }else{
      _controller.animateToPage(switchIndex,
          duration: _swiperConfig.animDuration, curve: Curves.ease);
      }
    });
  }

  void cancelTimer() {
    //取消倒计时
    if (_timer != null) {
      if (_timer!.isActive) {
        _timer!.cancel();
        _timer = null;
      }
    }
  }
}
