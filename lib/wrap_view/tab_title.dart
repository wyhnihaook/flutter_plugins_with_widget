import 'package:flutter/material.dart';

///描述:Tab中tab中显示的内容
///功能介绍:添加适配，用来处理文本以外的数据结构（右上角高亮内容）
///创建者:翁益亨
///创建日期:2022/7/5 15:34
class TabTitleView extends StatefulWidget {
  ///必填参数

  //当前显示的标题
  final String title;

  ///非必填参数

  //当前提示信息，必须是配合属性isScrollable = false 均分的情况使用，如果不均分使用会报错，容器的宽度无法计算，因为有一个高亮点
  //当前提示内容，默认为空字符串，不需要匹配
  final String tipContent;

  //存在提示信息的相关渲染
  //提示信息的背景色
  final Color tipBackgroundColor;

  //设置字体内容
  final double tipContentSize;

  //设置字体颜色
  final Color tipContentColor;

  //设置容器最小宽度
  final double tipContentMinWidth;

  //设置容器最小高度
  final double tipContentMinHeight;

  //提示背景的圆角设置,顺序：leftTop,rightTop,leftBottom,rightBottom
  final List<double> tipRadius;

  //提示内容居于顶部高度
  final double tipTopMargin;

  //提示内容居于右侧宽度
  final double tipRightMargin;

  const TabTitleView(this.title,
      {this.tipContent = "",
      this.tipContentColor = const Color(0XFFFFFFFF),
      this.tipBackgroundColor = const Color(0XFFFB2F2F),
      this.tipContentSize = 11,
      this.tipContentMinWidth = 20,
      this.tipContentMinHeight = 13,
      this.tipRadius = const [6, 6, 0, 6],
      this.tipTopMargin = 5,
      this.tipRightMargin = 5,
      Key? key})
      : super(key: key);

  @override
  State<TabTitleView> createState() => TabTitleViewState();
}

class TabTitleViewState extends State<TabTitleView> {

  late String _tipContent;

  @override
  void initState(){
    super.initState();

    _tipContent = widget.tipContent;
  }

  @override
  Widget build(BuildContext context) {

    return _tipContent.isEmpty
        ? Text(widget.title)
        : Stack(
            // 撑满整个容器
            fit: StackFit.expand,
            children: [
              Center(
                child: Text(
                  widget.title,
                ),
              ),
              Positioned(
                top: widget.tipTopMargin,
                right: widget.tipRightMargin,
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(
                    minHeight: widget.tipContentMinHeight,
                    minWidth: widget.tipContentMinWidth,
                  ),
                  decoration: BoxDecoration(
                    color: widget.tipBackgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(widget.tipRadius[0]),
                        topRight: Radius.circular(widget.tipRadius[1]),
                        bottomLeft: Radius.circular(widget.tipRadius[2]),
                        bottomRight: Radius.circular(widget.tipRadius[3])),
                  ),
                  child: Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _tipContent,
                      style: TextStyle(
                          color: widget.tipContentColor,
                          fontSize: widget.tipContentSize),
                    ),
                  ),
                ),
              )
            ],
          );
  }

  //清空当前高亮数据
  void clearTipContent(){
    setState(() {
      _tipContent = "";
    });
  }
}
