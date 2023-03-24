import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_nav_bar.dart';

///描述:当前搜索的顶部标记
///功能介绍:搜索顶部标记，点击跳转其他页面
///创建者:翁益亨
///创建日期:2022/6/20 16:32
class AppSearchBarView extends StatefulWidget {
  ///必填参数

  //未输入时内容填充
  final String hint;

  final String buttonText;

  ///可缺省参数

  //当前容器所需高度
  final double containerHeight;

  //搜索标记Logo
  final Widget? searchIcon;

  //默认按钮的padding属性设定
  final List<double> buttonPadding;

  //颜色以及尺寸相关

  //背景色
  final Color backgroundColor;

  //背景圆角
  final double backgroundRadius;

  //按钮背景色
  final Color buttonColor;

  //背景圆角
  final double buttonRadius;

  final Color buttonTextColor;
  final double buttonTextSize;

  final Color hintColor;
  final double hintSize;

  //当都左侧padding和右侧padding内容
  final double paddingLeft;
  final double paddingRight;

  //当前搜索按钮高度
  final double buttonHeight;

  //点击搜索进行搜索内容
  final VoidCallback? searchClickEvent;

  const AppSearchBarView(this.hint, this.buttonText,
      {Key? key,
      this.containerHeight = 40.0,
      this.searchIcon,
      this.buttonPadding = const [12.0, 4.0, 12.0, 4.0],
      this.backgroundColor = const Color(0XFFF6F7F9),
      this.backgroundRadius = 20.0,
      this.buttonColor = const Color(0XFF776FFF),
      this.buttonRadius = 16.0,
      this.buttonTextColor = Colors.white,
      this.buttonTextSize = 14.0,
      this.hintColor = const Color(0XFFABABAB),
      this.hintSize = 14.0,
      this.paddingLeft = 16.0,
      this.paddingRight = 6.0,
      this.buttonHeight = 28.0,
      this.searchClickEvent})
      : super(key: key);

  @override
  State<AppSearchBarView> createState() => _AppSearchBarViewState();
}

class _AppSearchBarViewState extends State<AppSearchBarView> {
  double? _height;

  @override
  void initState() {
    super.initState();
    var appBar = AppBar();
    //获取当前需要匹配的高度
    _height = appBar.preferredSize.height;

    //初始化的时候需要设置顶部状态栏内容变更
    SystemChrome.setSystemUIOverlayStyle(systemUiDarkOverlayStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(left: widget.paddingLeft, right: widget.paddingRight),
        height: widget.containerHeight,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius:
              BorderRadius.all(Radius.circular(widget.backgroundRadius)),
        ),
        child: Row(
          children: [
            widget.searchIcon != null
                ? Padding(
                    padding:const EdgeInsets.only(right: 4),
                    child: widget.searchIcon!,
                  )
                : const SizedBox(),
            Expanded(
                child: Text(
              widget.hint,
              style:
                  TextStyle(fontSize: widget.hintSize, color: widget.hintColor),
            )),
            GestureDetector(
              onTap: widget.searchClickEvent,
              child: Container(
                height: widget.buttonHeight,
                padding: EdgeInsets.only(
                    left: widget.buttonPadding[0],
                    top: widget.buttonPadding[1],
                    right: widget.buttonPadding[2],
                    bottom: widget.buttonPadding[3]),
                decoration: BoxDecoration(
                  color: widget.buttonColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.buttonRadius)),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.buttonText,
                  style: TextStyle(
                      fontSize: widget.buttonTextSize,
                      color: widget.buttonTextColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
