import 'package:flutter/material.dart';

///描述:展示在界面的Toast组件，默认定义的样式
///功能介绍:toast样式定义，没有可以改变的状态，使用StatelessWidget
///创建者:翁益亨
///创建日期:2022/7/13 10:51
class ToastView extends StatelessWidget {

  //展示在界面的toast信息
  final String msg;

  const ToastView(this.msg,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin:const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        padding:const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(msg, style:const TextStyle(color: Colors.white)),
      ),
    );
  }
}
