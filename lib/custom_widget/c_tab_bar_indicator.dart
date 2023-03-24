import 'package:flutter/material.dart';

///描述:自定义底部导航条
///功能介绍:自定义底部导航条
///系统提供了一个参考的indicator：UnderlineTabIndicator
///创建者:翁益亨
///创建日期:2022/7/4 17:01

const double tabBarIndicatorWeight = 3.0;

class TabBarIndicator extends Decoration {

  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final StrokeCap strokeCap; // 控制器的边角形状,round圆角，square正方形，butt无形状（画笔形状）
  final double width; // 控制器的宽度，默认0，跟随指示器的宽度，indicatorSize  （tab-跟随tab的宽度/label-跟随内容），宽度大于0上述属性失效

  const TabBarIndicator({
    this.borderSide = const BorderSide(width: tabBarIndicatorWeight, color: Color(0XFF776FFF)),
    this.insets = EdgeInsets.zero,
    this.strokeCap= StrokeCap.square,
    this.width= 0,
  }) : assert(borderSide != null),
        assert(insets != null);


  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is UnderlineTabIndicator) {
      return UnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([ VoidCallback? onChanged ]) {
    return _TabBarIndicatorPainter(this, onChanged);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    assert(rect != null);
    assert(textDirection != null);
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    if(this.width == 0){
      return Rect.fromLTWH(
        indicator.left,
        indicator.bottom - borderSide.width,
        indicator.width,
        borderSide.width,
      );
    }
    //决定导航栏的尺寸
    // 希望的宽度
    double wantWidth = this.width;
    // 取中间坐标
    double cw = (indicator.left + indicator.right) / 2;
    // 这里是核心代码
    return Rect.fromLTWH(cw - wantWidth / 2,
        indicator.bottom - borderSide.width, wantWidth, borderSide.width);
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _TabBarIndicatorPainter extends BoxPainter {
  _TabBarIndicatorPainter(this.decoration, VoidCallback? onChanged)
      : assert(decoration != null),
        super(onChanged);

  final TabBarIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    //deflate方法传入数字，对于偏移之后返回Rect对象
    final Rect indicator = decoration._indicatorRectFor(rect, textDirection).deflate(decoration.borderSide.width / 2.0);

    //决定控制器边角（圆角）
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = decoration.strokeCap; // 这里修改控制器边角的形状
    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
