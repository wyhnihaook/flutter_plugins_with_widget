import 'package:flutter/material.dart';

import '../wrap_view/page_with_keep_alive.dart';

///描述:底部导航栏
///功能介绍:基本只用于首页定义不同类型页面的切换
///创建者:翁益亨
///创建日期:2022/6/21 10:45

// 当前需要切换传递的接口信息声明
// 主要是用来处理生命周期的同步
typedef SwitchBottomTabListener = Function(int currentIndex,int preIndex);

class BottomNavigator extends StatefulWidget {
  ///必填参数

  //底部导航栏的图片，高亮模式
  final List<Widget> lightIcons;

  //底部导航栏图片，普通模式
  final List<Widget> normalIcons;

  //底部导航文字
  final List<String> navTitles;

  //当前容器中展示的页面
  final List<Widget> pages;

  ///可缺省参数

  //选中的文本颜色
  final Color lightTextColor;

  //普通的文本颜色
  final Color normalTextColor;

  //选中的文本字体
  final double lightTextSize;

  //普通的文本字体
  final double normalTextSize;

  //打开页面时默认选中的模块
  final int initialPage;

  //当前切换tab的时候回调添加
  final SwitchBottomTabListener? switchBottomTabListener;

  //是否需要缓存，默认需要
  final bool keepAlive;

  //背景颜色
  final Color backgroundColor;

  const BottomNavigator({
    Key? key,
    required this.lightIcons,
    required this.normalIcons,
    required this.navTitles,
    required this.pages,
    this.lightTextColor = const Color(0XFF222222),
    this.normalTextColor = const Color(0XFF999999),
    this.lightTextSize = 10,
    this.normalTextSize = 10,
    this.initialPage = 0,
    this.switchBottomTabListener,
    this.keepAlive = true,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  late PageController _controller;

  late int currentIndex;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    //初始化当前控制器
    _controller = PageController(initialPage: widget.initialPage);

    //同步初始化的角标信息
    currentIndex = widget.initialPage;

    //初始化的时候将当前page页面作为子组件
    if(widget.keepAlive){
      _pages = widget.pages.map((e) => PageKeepAliveView(child: e,)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        //控制器添加
        controller: _controller,
        //切换Page时不允许滚动
        physics: const NeverScrollableScrollPhysics(),
        //监听切换页面回调
        onPageChanged: (index) {
          _onJumpTo(index,pageChange: true);
        },
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        //去掉水波纹效果，当然可以全局设定
        data: ThemeData(
          brightness: Brightness.light,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        //如果要采用自定义的底部导航栏，可使用BottomAppBar组件，因为内部的信息通过child重新定义展示，可最大程度适配（shape属性制造缺口，FloatingActionButton适配位置）
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: widget.backgroundColor,
          selectedItemColor: widget.lightTextColor,
          unselectedItemColor: widget.normalTextColor,
          type: BottomNavigationBarType.fixed,//默认固定均分
          selectedLabelStyle: TextStyle(
            fontSize: widget.lightTextSize,
            // color: widget.lightTextColor,//有设置主题或unselectedItemColor时,无作用（直接采用单独设置selectedItemColor）
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: widget.normalTextSize,
            // color: widget.normalTextColor,//有设置主题或unselectedItemColor时,无作用（直接采用单独设置unselectedItemColor）
          ),
          //底部导航栏点击
          onTap: (index){
            _onJumpTo(index);
          },
          //底部渲染的组件内容，必须是BottomNavigationBarItem
          items: _bottomItems(),
        ),
      ),
    );
  }

  _bottomItems() {
    List<BottomNavigationBarItem> list = [];
    //根据数据遍历填充
    for (int i = 0; i < widget.lightIcons.length; i++) {
      Widget icon = widget.normalIcons[i];
      Widget activeIcon = widget.lightIcons[i];

      String label = widget.navTitles[i];

      list.add(BottomNavigationBarItem(
          icon: icon,
          activeIcon: activeIcon,
          label: label));
    }

    return list;
  }


  //当前切换tab进行角标以及page同步
  _onJumpTo(int index,{pageChange = false}){
    if(index == currentIndex){
      //相同的跳转数据
      return ;
    }

    //当前记录切换的内容，记录当前切换的内容
    if(widget.switchBottomTabListener!=null){
      widget.switchBottomTabListener!(index,currentIndex);
    }

    setState((){
      currentIndex = index;
    });

    //需要对当前index设置完毕之后再进行切换
    //不然会走两次回调
    if(!pageChange){
      _controller.jumpToPage(index);
    }

  }
}
