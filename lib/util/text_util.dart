import 'dart:ui';

import 'package:flutter/material.dart';

///描述:文本处理功能
///功能介绍:文本二次处理数据
///创建者:翁益亨
///创建日期:2022/7/6 16:12
class TextUtil {

  ///根据字符串和字符样式获取当前的内容Size
  static Size boundingTextSize(String text, TextStyle style,
      {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }
}
