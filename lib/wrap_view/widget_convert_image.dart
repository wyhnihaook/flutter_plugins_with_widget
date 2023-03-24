import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
///描述:页面中所有元素转化为图片
///功能介绍:页面中所有元素转化为图片
///创建者:翁益亨
///创建日期:2023/3/16 14:46
class WidgetConvertImage extends StatelessWidget {

  final GlobalKey globalKey ;
  final Widget child;//要转化为图片的页面信息

  const WidgetConvertImage({Key? key,required this.globalKey,required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: child,
    );
  }

  //将布局转化为图片
  //使用Image.memory（）可将图片展示
  Future<Uint8List> widgetToImage() async {
    Completer<Uint8List> completer = Completer();

    RenderRepaintBoundary render = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    print("ui.window.devicePixelRatio:${ui.window.devicePixelRatio}");
    ui.Image image = await render.toImage(pixelRatio:  ui.window.devicePixelRatio);//提高导出图片的清晰度
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    completer.complete(byteData?.buffer.asUint8List());

    return completer.future;
  }
}
