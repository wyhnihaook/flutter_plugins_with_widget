import 'package:flutter/material.dart';

///描述:虚线功能实现
///功能介绍:虚线功能实现
///创建者:翁益亨
///创建日期:2023/3/14 15:55
class DashLine extends CustomPainter{

  final Color lineColor;
  final double lineDashSpace;
  final double lineDashWidth;
  // indent/endIndent（距左/右间距）
  final double indent;
  final double endIndent;

  DashLine({Key? key,required this.lineColor,this.lineDashSpace = 5,this.lineDashWidth = 5,
  this.indent = 0,this.endIndent = 0}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint() // 创建一个画笔并配置其属性
      ..strokeWidth = 0.5 // 画笔的宽度
      ..isAntiAlias = true // 是否抗锯齿
      ..color=lineColor; // 画笔颜色

    var max =  size.width - endIndent; // size获取到宽度
    var dashWidth = lineDashWidth;
    var dashSpace = lineDashSpace;
    double startX = indent;
    final space = (dashSpace + dashWidth);

    while (startX < max) {
      canvas.drawLine(Offset(startX, 0.0), Offset(startX + dashWidth, 0.0), paint);
      startX += space;
    }
  }

  //不需要重复构图
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return false;
  }

}