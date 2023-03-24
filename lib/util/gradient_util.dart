import 'package:flutter/material.dart';

///描述:渐变色值处理
///功能介绍:所有渐变内容声明
///LinearGradient：线性渐变
/// RadialGradient：放射状渐变
/// SweepGradient：扇形渐变
///创建者:翁益亨
///创建日期:2022/7/6 13:37
class GradientUtil {
  ///渐变色创建器,从左到右渲染
  static LinearGradient getLinearGradient(
    List<Color> colors, {
    begin = AlignmentDirectional.centerStart,
    end = AlignmentDirectional.centerEnd,
  }) =>
      LinearGradient(colors: colors, begin: begin, end: end);

  ///从上到下平铺后进行扇形渐变
  static SweepGradient _getSweepGradient(
    Color top,
    Color bottom, {
    opacity = 1.0,
  }) =>
      SweepGradient(
          colors: [top.withOpacity(opacity), bottom.withOpacity(opacity)]);



  static LinearGradient whiteLinearGradient({
    begin = AlignmentDirectional.topStart,
    end = AlignmentDirectional.bottomEnd,
    opacity = 0.85,
  }) =>
      getLinearGradient(
        [const Color(0X00FFFFFF),
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity)],
        begin: begin,
        end: end,
      );

  static SweepGradient whiteSweepGradient({
    opacity = 0.95,
  }) =>
      _getSweepGradient(Colors.white, Colors.white, opacity: opacity);
}
