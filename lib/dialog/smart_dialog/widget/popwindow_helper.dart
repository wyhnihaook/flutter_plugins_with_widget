import 'package:flutter/material.dart';

///描述:弹窗帮助类
///功能介绍:弹窗帮助类，主要用于获取当前child的context进行定位
///创建者:翁益亨
///创建日期:2022/8/23 13:58
///返回当前context数据，用于定位
typedef ContextCallBack = Function(BuildContext context);
class PopWindowHelper extends StatefulWidget {

  //显示在界面上用于触发点击事件的组件，必填
  final Widget child;

  //点击组件回调
  final ContextCallBack? contextCallBack;

  const PopWindowHelper({Key? key,required this.child,this.contextCallBack}) : super(key: key);

  @override
  _PopWindowHelperState createState() => _PopWindowHelperState();
}

class _PopWindowHelperState extends State<PopWindowHelper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: (){
      widget.contextCallBack?.call(context);
    },child: Wrap(
      children:[
        widget.child
      ] ,
    ),);
  }
}
