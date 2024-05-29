import 'package:flutter/material.dart';
import 'dart:ui';

///全局尺寸适配
class KScale {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static final double _width = mediaQuery.size.width;
  static final double _height = mediaQuery.size.height;
  static final double _topbarH = mediaQuery.padding.top;
  static final double _botbarH = mediaQuery.padding.bottom;
  static final double _pixelRatio = mediaQuery.devicePixelRatio;
  static var _ratio;
  //这里以375作为适配，当然还有750、
  static init(int number){
    int uiwidth = number is int ? number : 375;
    _ratio = _width / uiwidth;
  }

  static px(number){
    if(!(_ratio is double || _ratio is int)){KScale.init(375);}
    return number * _ratio;
  }
  //一个像素
  static onepx(){
    return 1/_pixelRatio;
  }

  static screenW(){
    return _width;
  }

  static screenH(){
    return _height;
  }

  static padTopH(){
    return _topbarH;
  }

  static padBotH(){
    return _botbarH;
  }
}

extension DoubleFit on double {
  double get px {
    return KScale.px(this);
  }
}

extension IntFit on int {
  double get px {
    return KScale.px(this.toDouble());
  }
}
