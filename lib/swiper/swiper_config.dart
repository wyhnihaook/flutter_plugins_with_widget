import 'package:flutter/material.dart';

///描述:轮播属性设置
///功能介绍:轮播配置，主要用来缺省时统一设置参数
///创建者:翁益亨
///创建日期:2022/8/10 15:27
///后续有需求拓展对应指示器位置灯其他属性

typedef IndexedWidgetBuilder = Widget Function(int index);

//index：当前第几个指示器  currentIndex：目前选中的页面关联指示器
typedef IndexedWidgetIndicatorBuilder = Widget Function(int index,int currentIndex);

class SwiperConfig {
  SwiperConfig({
    this.itemBuilder,//要设置的返回渲染在页面上的数据
    this.itemCount = 0,
    this.autoplay = false,//默认不能自动滚动轮播
    this.animDuration = const Duration(milliseconds: 1500),
    this.delayPlayDuration = const Duration(milliseconds: 3500),
    this.loop = false,
    this.showIndicator = true,
    this.itemIndicatorBuilder,
    this.indicatorPadding = 4,
  });

  ///需要设置属性配置

  ///需要渲染的组件信息
  final IndexedWidgetBuilder? itemBuilder;

  ///轮播个数
  final int itemCount;

  //轮播的数据

  ///是否自动播放
  final bool autoplay;

  ///延时执行切换功能
  final Duration delayPlayDuration;

  ///自动滚动动画过渡时间设置
  final Duration animDuration;

  ///是否是无限轮播模式，设置true：滚动到最后一个就会滚动到第一个。false：滚动最后一个后停止，无法继续滑动
  final bool loop;


  ///指示器内容,是否显示指示器。true:显示 false：不显示
  final bool showIndicator;

  ///指示器的组件，颜色的指定可以在外部根据角标锁定设置
  final IndexedWidgetIndicatorBuilder? itemIndicatorBuilder;

  ///指示器之间的边距情况，上下边距
  final double indicatorPadding;
}
