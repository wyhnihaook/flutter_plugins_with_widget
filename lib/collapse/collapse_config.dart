import 'package:flutter/material.dart';
import 'package:widget/collapse/collapse_status.dart';

///描述:折叠面板自定义属性
///功能介绍:所有默认显示的内容从这里定义（从构造函数中迁移出来）
///创建者:翁益亨
///创建日期:2022/8/11 10:49
///点击回调展开/收起功能，直接对defaultExpandStatus结果置反即可

///显示内容切入动画
enum AnimType{
  none,
  fade,//渐变显示、隐藏
  translate,//下拉式切入、收起
}

typedef OperatorCollapseCallBack = Function(bool isExpand);
class CollapseConfig extends CollapseStatus{
   CollapseConfig({
    this.collapseItemBuilder = const SizedBox(),
    this.expandChildItemBuilder = const SizedBox(),
    this.boxDecoration = const BoxDecoration(),
    this.containerMargin = EdgeInsets.zero,
    this.operatorCollapseCallBack,
    this.animType = AnimType.none,
    bool isExpanded = false,
  }):super(isExpanded: isExpanded);

  ///收缩起来后展示的可展开组件
  final Widget collapseItemBuilder;

  ///展开显示的子组件
  final Widget expandChildItemBuilder;

  ///容器展示的背景容器
  final BoxDecoration boxDecoration;

  ///外边距设置
  final EdgeInsetsGeometry containerMargin;

  ///操作回调
  final OperatorCollapseCallBack? operatorCollapseCallBack;

  //展示和收起过渡动画
  final AnimType animType;
}
