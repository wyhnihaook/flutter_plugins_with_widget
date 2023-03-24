import 'package:flutter/material.dart';
import 'package:widget/util/const_util.dart';

import '../custom_widget/c_tab_bar_indicator.dart';
import '../custom_widget/c_tabs.dart';
import '../dialog/show_dialog.dart';
import '../nav_bar/app_top_navigator.dart';

///描述:存在Tab栏的选择器
///功能介绍:多级选择，可以设置为区间也可以设置为完全内容<只提供当前tab信息，不提供具体内部实现，内部实现由app_picker.dart实现>
///创建者:翁益亨
///创建日期:2022/7/12 13:41
class PickerTabView extends StatefulWidget {
  ///必填参数

  //当前展示的tab标签内容
  final List<Widget> tabs;

  //当前容器中展示的页面
  final List<Widget> pages;

  ///非必填参数

  //当前tab间距设定
  final double middlePadding;

  //回调方法
  final SubmitCallBack? submitCallBack;

  final CancelCallBack? cancelCallBack;

  //当前操作栏的高度
  final double titleBarHeight;

  //左侧操作文字内容、尺寸、颜色
  final String titleBarLeftContent;

  final double titleBarLeftContentSize;

  final Color titleBarLeftContentColor;

  //右侧操作文字内容、尺寸、颜色
  final String titleBarRightContent;

  final double titleBarRightContentSize;

  final Color titleBarRightContentColor;

  //中间title文字内容、尺寸、颜色
  final String titleBarCenterContent;

  final double titleBarCenterContentSize;

  final Color titleBarCenterContentColor;

  //顶部容器边缘处理
  final BoxDecoration titleBarBoxDecoration;

  //底部导航条信息
  final Decoration indicator;

  //是否需要手动退出
  final bool autoPop;

  const PickerTabView(
      {required this.tabs,
      required this.pages,
      this.autoPop = true,
      this.titleBarHeight = 48,
      this.middlePadding = kTabLabelMiddlePadding,
      this.submitCallBack,
      this.cancelCallBack,
      this.titleBarLeftContent = "取消",
      this.titleBarLeftContentSize = 14,
      this.titleBarLeftContentColor = const Color(0xFFB3B3B3),
      this.titleBarCenterContent = "",
      this.titleBarCenterContentSize = 16,
      this.titleBarCenterContentColor = const Color(0xFF333333),
      this.titleBarRightContent = "确定",
      this.titleBarRightContentSize = 14,
      this.titleBarRightContentColor = const Color(0xFF776FFF),
      this.titleBarBoxDecoration = const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      this.indicator = const TabBarIndicator(
        strokeCap: StrokeCap.round,
        width: 24,
      ),
      Key? key})
      : super(key: key);

  @override
  State<PickerTabView> createState() => _PickerTabViewState();
}

class _PickerTabViewState extends State<PickerTabView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarNavigator(
      indicator: widget.indicator,
      middlePadding: widget.middlePadding,
      topView: [_titleView()],
      topViewHeight: widget.titleBarHeight,
      backgroundColor: Colors.white,
      tabs: widget.tabs,
      pages: widget.pages,
    );
  }

  //顶部操作标题栏
  _titleView() {
    return Container(
      height: widget.titleBarHeight,
      decoration: widget.titleBarBoxDecoration,
      child: Row(
        //居于最左侧和最右侧，中间占位最多
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            highlightColor: Colors.transparent,
            radius: 0.0,
            onTap: () {
              if (widget.cancelCallBack != null) {
                widget.cancelCallBack!();
              }

              if(widget.autoPop){
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                widget.titleBarLeftContent,
                style: TextStyle(
                    fontSize: widget.titleBarLeftContentSize,
                    color: widget.titleBarLeftContentColor),
              ),
            ),
          ),
          Text(
            widget.titleBarCenterContent,
            style: TextStyle(
                fontSize: widget.titleBarCenterContentSize,
                color: widget.titleBarCenterContentColor),
          ),
          InkWell(
            highlightColor: Colors.transparent,
            radius: 0.0,
            onTap: () {
              //返回数据结构

              if (widget.submitCallBack != null) {
                //通过回调从app_picker组件中获取对应的数据，通过GlobalKey进行获取结果参数
                widget.submitCallBack!(true);
              }

              if(widget.autoPop){
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                widget.titleBarRightContent,
                style: TextStyle(
                    fontSize: widget.titleBarRightContentSize,
                    color: widget.titleBarRightContentColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
