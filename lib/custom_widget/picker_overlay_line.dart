import 'package:flutter/material.dart';

///描述:选择器上选中覆盖的组件
///功能介绍:选中覆盖的组件信息
///创建者:翁益亨
///创建日期:2022/7/7 17:40
class PickerOverlayLineView extends StatelessWidget {
  //当前的组件高度
  final double height;

  //当前颜色的边距
  final double paddingInfo;

  //当前色值
  final Color lineColor;

  const PickerOverlayLineView(
      {
        this.height = 38,
      this.paddingInfo = 16,
      this.lineColor = const Color(0XFFEBEDF0),
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(top: 0,bottom: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Divider(
              height: 1,
              indent: paddingInfo,
              endIndent: paddingInfo,
              color: lineColor,
            ),
            Divider(
              height: 1,
              indent: paddingInfo,
              endIndent: paddingInfo,
              color: lineColor,
            )
          ],
        ),
      ),
    );
  }
}
