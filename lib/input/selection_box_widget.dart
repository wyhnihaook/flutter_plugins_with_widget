import 'package:flutter/material.dart';

///描述:选择/展示框样式
///功能介绍:点击/查看功能框
///创建者:翁益亨
///创建日期:2022/6/17 15:36

//当前不同模式下（水平/竖直）内容差值定义
///不可随便删除键值对，需要对代码完全迭代后才能操作
const modeSelectionBoxDiffSize = {'textSizeDiff': 2, 'marginSizeDiff': 24};

///默认适配的右侧箭头图片，可以使用本地图片替代
const rightArrow = Icon(
  Icons.arrow_forward_ios,
  size: 16,
  color: Color(0xffE3E3E3),
);

class SelectionBoxView extends StatefulWidget {
  ///界面必填参数

  //标题信息
  final String title;

  ///可选参数添加

  //背景颜色设置
  final Color backgroundColor;

  //显示内容
  final String content;

  //显示内容位置
  final TextAlign contentAlign;

  //标题左侧child,由外部定义当前数据
  final Widget? titleLeftView;

  //标题右侧child
  final Widget? titleRightView;

  //最右侧图标，普通模式下就是固定的返回箭头
  final Widget? rightView;

  //整体的高度由当前内边距+字体高度，默认边距信息
  final List<double> containerMargin;

  //是否显示下划分割线，默认显示
  final bool showSplitLine;

  //底部下划线距左边距，默认0
  final double lineToLeft;

  //底部下划线距右边距，默认0
  final double lineToRight;

  //颜色尺寸设置
  final Color titleColor;
  final Color contentColor;
  final Color lineColor;

  final double titleSize;
  final double contentSize;
  final double lineHeight;

  //当前填充的组件容器尺寸设定
  final int viewSize;

  //当容器点击时，是否需要发生事件的监听
  final GestureTapCallback? click;

  //是否是必填项
  final bool isNecessary ;

  //是否是图片模式，默认不是图片模式
  bool get picMode =>
      (titleLeftView != null || titleRightView != null || rightView != null);

  const SelectionBoxView(
    this.title, {
    Key? key,
        this.isNecessary = false,
    this.backgroundColor = Colors.white,
    this.content = "",
        this.contentAlign = TextAlign.left,
    this.titleLeftView,
    this.titleRightView,
    this.rightView,
    this.containerMargin = const [16, 16, 40, 16],
    this.showSplitLine = true,
    this.lineToLeft = 16,
    this.lineToRight = 0,
    this.titleColor = const Color(0xFF333333),
    this.contentColor = const Color(0xFFB3B3B3),
    this.lineColor = const Color(0xFFE9E9E9),
    this.titleSize = 16,
    this.contentSize = 16,
    this.lineHeight = 0.5,
    this.viewSize = 16,
    this.click,
  }) : super(key: key);

  @override
  State<SelectionBoxView> createState() => _SelectionBoxViewState();
}

class _SelectionBoxViewState extends State<SelectionBoxView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: GestureDetector(
        //点击事件暴露
        onTap: widget.click,
        child: Column(
          children: [
            Row(
              //设置竖直方向水平居中
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.titleLeftView != null
                    ? Padding(
                        padding:
                            EdgeInsets.only(left: widget.containerMargin[0]),
                        child: widget.titleLeftView,
                      )
                    : const SizedBox(),

                Container(
                  //存在图片时，居右尺寸减小
                  padding: EdgeInsets.fromLTRB(
                      widget.titleLeftView != null
                          ? 4
                          : widget.containerMargin[0],
                      widget.containerMargin[1],
                      widget.titleRightView != null
                          ? 4
                          : widget.containerMargin[2] -
                              (widget.picMode
                                  ? modeSelectionBoxDiffSize["marginSizeDiff"]!
                                  : 0),
                      widget.containerMargin[3]),
                  child: RichText(
                    text: TextSpan(
                      text: widget.title,
                        style: TextStyle(
                            fontSize: widget.titleSize -
                                (widget.picMode
                                    ? modeSelectionBoxDiffSize["textSizeDiff"]!
                                    : 0),
                            color: widget.titleColor),
                      children: [
                       TextSpan(text:  widget.isNecessary?" *":"",style: TextStyle(fontSize: 14,color: Color(0XFFE13737)))
                      ]
                    ),
                  )

                  // Text(
                  //   widget.title,
                  //   style: TextStyle(
                  //       fontSize: widget.titleSize -
                  //           (widget.picMode
                  //               ? modeSelectionBoxDiffSize["textSizeDiff"]!
                  //               : 0),
                  //       color: widget.titleColor),
                  // ),
                ),

                //右侧图片
                widget.titleRightView != null
                    ? Padding(
                        padding: EdgeInsets.only(
                            right: widget.containerMargin[2] -
                                modeSelectionBoxDiffSize["marginSizeDiff"]!),
                        child: widget.titleRightView,
                      )
                    : const SizedBox(),

                Expanded(
                    child: Text(
                  widget.content,
                  textAlign: widget.contentAlign,
                  style: TextStyle(
                      fontSize: widget.contentSize -
                          (widget.picMode ? modeSelectionBoxDiffSize["textSizeDiff"]! : 0),
                      color: widget.contentColor),
                )),

                //判断右侧内容是否需要默认箭头
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: (widget.picMode
                      ? widget.rightView ?? const SizedBox()
                      : rightArrow),
                ),
              ],
            ),
            widget.showSplitLine
                ? Divider(
                    height: widget.lineHeight,
                    indent: widget.lineToLeft,
                    endIndent: widget.lineToRight,
                    color: widget.lineColor,
                    thickness: widget.lineHeight,
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
