import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:widget/custom_widget/c_tab_bar_indicator.dart';
import 'package:widget/custom_widget/c_tab_scroll_physics.dart';
import 'package:widget/util/gradient_util.dart';

import '../custom_widget/c_tabs.dart';
import '../util/text_util.dart';
import '../wrap_view/offstage_view.dart';
import '../wrap_view/page_with_keep_alive.dart';

///描述:顶部Tab栏切换
///功能介绍:顶部tab+pageView封装功能
///创建者:翁益亨
///创建日期:2022/6/27 10:40

///顶部切换时回调
typedef SwitchTopTabListener = Function(int currentIndex, int preIndex);

class TabBarNavigator extends StatefulWidget {
  ///必填参数

  //当前展示的tab标签内容
  final List<Widget> tabs;

  //tab的padding属性设定
  final EdgeInsets tabPadding;

  //当前容器中展示的页面
  final List<Widget> pages;

  ///非必填参数

  //顶部添加额外数据组件，高度和内容必须一起传递，不然界面会出现问题
  final List<Widget> topView;
  final double topViewHeight;

  //当前居左右间距，仅当额外使用的时候设置，默认为0
  final double middlePadding;

  //当前切换tab的时候回调添加
  final SwitchTopTabListener? switchTopTabListener;

  //当前顶部高度设置
  final double tabBarHeight;

  //当前默认的Tab背景颜色
  final Color tabBackgroundColor;

  //当前默认的页面背景色
  final Color backgroundColor;

  //选项卡宽度是否和标签相同，默认true 宽度包裹内容（适合一屏幕展示不完的页面），false 宽度适应（适合一屏幕能展示完毕的页面）
  final bool isScrollable;

  //是否需要缓存，默认需要
  final bool keepAlive;

  //打开页面时默认选中的模块
  final int initialPage;

  //底部导航条信息
  final Decoration indicator;

  //阴影设置
  final Color shadowColor;

  //没有指定模式时，当前指定默认模式
  final TabBarIndicatorSize indicatorSize;

  final TextStyle unselectedLabelStyle;

  final Color unselectedLabelColor;

  final TextStyle selectedLabelStyle;

  final Color selectedLabelColor;

  //当前title列表获取,主要用来计算当前右侧阴影占位是否需要展示
  final List<String> titles;

  const TabBarNavigator(
      {required this.tabs,
      required this.pages,
      this.tabPadding = EdgeInsets.zero,
      this.topView = const [],
      this.topViewHeight = 0,
      this.middlePadding = kTabLabelMiddlePadding,
      this.tabBackgroundColor = const Color(0XFFFFFFFF),
      this.backgroundColor = const Color(0XFF00FF00),
      this.initialPage = 0,
      this.tabBarHeight = 46, //等同于tabs中的_kTabHeight，默认数据
      this.isScrollable = true,
      this.keepAlive = true,
      this.switchTopTabListener,
      this.indicatorSize = TabBarIndicatorSize.tab,
      this.shadowColor = Colors.transparent,
      this.unselectedLabelStyle = const TextStyle(
        fontSize: 14,
      ),
      this.unselectedLabelColor = const Color(0XFF999999),
      this.selectedLabelStyle = const TextStyle(
        fontSize: 14,
      ),
      this.selectedLabelColor = const Color(0XFF333333),
      this.indicator = const TabBarIndicator(
        strokeCap: StrokeCap.round,
        width: 24,
      ), //取消下划线 BoxDecoration()传入即可
      this.titles = const [],
      Key? key})
      : super(key: key);

  @override
  State<TabBarNavigator> createState() => _TabBarNavigatorState();
}

class _TabBarNavigatorState extends State<TabBarNavigator>
    with SingleTickerProviderStateMixin {
  //滑动Tab监听器
  TabController? _tabController;

  //页面控制器
  late PageController _pageController;

  late List<Widget> _tabs;

  late int currentIndex;

  late List<Widget> _pages;

  //是否存在遮挡的组件
  bool _needOcclusion = false;

  //当前占用总宽度处理
  double allDataWidth = 0;

  //控制滑动隐藏GlobalKey
  final globalKey = GlobalKey<OffstageViewState>();

  //添加PageView移动选中最后一个标识
  bool moveBodyCheckLastIndex = false;

  @override
  void initState() {
    super.initState();

    //判断当前是否需要占位组件显示
    //当前是可滚动并且列表tabs总长度大于屏幕尺寸进行展示
    if (widget.isScrollable && widget.titles.length == widget.tabs.length) {
      //获取屏幕的宽度
      // final size =MediaQuery.of(context).size;
      // final width = size.width;
      //遍历组件
      for (String item in widget.titles) {
        //字体样式从TabBarNavigator中获取初始化默认值
        Size size = TextUtil.boundingTextSize(item, widget.selectedLabelStyle);
        allDataWidth += size.width;
        //添加边距
        allDataWidth += kTabLabelMiddlePadding * 2;
      }
    }

    //同步初始化的角标信息
    currentIndex = widget.initialPage;

    _pageController = PageController(initialPage: widget.initialPage);

    _pages = widget.pages;
    //初始化的时候将当前page页面作为子组件
    if (widget.keepAlive) {
      _pages = widget.pages
          .map((e) => PageKeepAliveView(
                child: e,
              ))
          .toList();
    }

    //添加适配器
    _tabs = widget.tabs
        .map((e) => Tab(
              height: widget.tabBarHeight,
              child: e,
            ))
        .toList();

    _tabController = TabController(length: widget.tabs.length, vsync: this);

    _tabController!.addListener(() {
      //监听当前滑动页面操作，默认刚刚开始切换回调一次，然后切换成功回调一次
      //切换页面后进行数据处理
      //点击tab时或滑动tab回调一次
      if (_tabController!.index.toDouble() ==
          _tabController!.animation!.value) {}
    });
  }

  @override
  void dispose() {
    super.dispose();

    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (allDataWidth > 0) {
      double screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth < allDataWidth) {
        //需要显示
        _needOcclusion = true;
      }
    }
    return Scaffold(
      backgroundColor: widget.tabBackgroundColor,
      //这里使用PreferredSize+ConstrainedBox双重限制，进行高度的处理。普通使用BoxConstraints即可，这里必须要用PreferredSizeWidget，所以先要是使用PreferredSize，但在某些情况，会出现高度溢出的情况
      //所以这里使用ConstrainedBox限制溢出问题
      appBar: _tabs.length==1?null:PreferredSize(
        //为了在最右侧适配阴影，包裹内容适配，高度为tab的高度+indicator的高度
        preferredSize: Size.fromHeight(
            widget.tabBarHeight + tabBarIndicatorWeight + widget.topViewHeight),
        child: ConstrainedBox(constraints: BoxConstraints(maxHeight:widget.tabBarHeight + tabBarIndicatorWeight + widget.topViewHeight),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.topView,
                CTabBar(
                  padding: widget.tabPadding,
                  unselectedLabelColor: widget.unselectedLabelColor,
                  unselectedLabelStyle: widget.unselectedLabelStyle,
                  labelColor: widget.selectedLabelColor,
                  labelStyle: widget.selectedLabelStyle,
                  indicatorSize: widget.indicatorSize,
                  indicator: widget.indicator,
                  controller: _tabController,
                  isScrollable: widget.isScrollable,
                  tabs: _tabs,
                  middlePadding: widget.middlePadding,
                  physics: CScrollPhysics(
                    //监听隐藏和显示
                      visibleRightPlaceHolderCallBack: (isVisible) {
                        if (!_needOcclusion) {
                          return;
                        }
                        // print("isVisible $isVisible");
                        globalKey.currentState?.setVisibleStatus(
                            moveBodyCheckLastIndex ? false : isVisible);
                      }, overCallBack: (offset) {
                    if (offset > 0) {
                      //手势从左往右滑动，重置底部选择
                      moveBodyCheckLastIndex = false;
                    }
                  }),
                  onTap: (index) {
                    _onJumpTo(index);
                  },
                )
              ],
            ),
            Positioned(
              right: 0,
              child: IgnorePointer(
                child: OffstageView(
                  key: globalKey,
                  isVisible: _needOcclusion,
                  Container(
                    decoration: BoxDecoration(
                      gradient: GradientUtil.whiteLinearGradient(),
                    ),
                    width: widget.tabBarHeight + tabBarIndicatorWeight - 10,
                    height: widget.tabBarHeight + tabBarIndicatorWeight,
                  ),
                ),
              ),
            )
          ],
        ),),
      ),
      body: Container(
        color: widget.backgroundColor,
        child: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (index) {
            _tabController!.animateTo(index);
            _onJumpTo(index, pageChange: true);
          },
        ),
      ),
    );
  }

  //当前切换tab进行角标以及page同步
  _onJumpTo(int index, {pageChange = false}) {
    if (index == currentIndex) {
      //相同的跳转数据
      return;
    }

    //PageView滑动会联动顶部TabBar进行滚动定位锚点，所以这里不用额外处理
    //标识当前滑动到最后一个，没有滑动过上面的数据
    if (index == widget.tabs.length - 1) {
      moveBodyCheckLastIndex = true;
    } else {
      //重置数据
      moveBodyCheckLastIndex = false;
    }

    //当前记录切换的内容，记录当前切换的内容
    if (widget.switchTopTabListener != null) {
      widget.switchTopTabListener!(index, currentIndex);
    }

    currentIndex = index;

    //需要对当前index设置完毕之后再进行切换
    //不然会走两次回调
    if (!pageChange) {
      _pageController.jumpToPage(index);
    }
  }
}
