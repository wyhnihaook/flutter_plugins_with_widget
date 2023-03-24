import 'package:flutter/material.dart';

///描述:自定义导航栏（使用该自定义功能要确定，当前导航栏必须为偶数，再添加一个公用组件）
///功能介绍:底部自定义凹槽导航栏
///
///匹配当前BottomAppBarView使用示例：
///floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
///       floatingActionButton: FloatingActionButton(
///         onPressed: () {  },
///         child: Icon(Icons.add,color: Colors.red,),
///       ),
///       bottomNavigationBar: BottomAppBarView(
///         containerHeight:55,//根据情况设定
///         lightIcons: widget.lightIcons,
///         normalIcons: widget.normalIcons,
///         navTitles: widget.navTitles,
///         onTap:(index){
///           _onJumpTo(index);
///         } ,
///
///创建者:翁益亨
///创建日期:2022/6/21 14:19
class BottomAppBarView extends StatefulWidget {
  ///必填参数

  //底部导航栏的图片，高亮模式
  final List<Widget> lightIcons;

  //底部导航栏图片，普通模式
  final List<Widget> normalIcons;

  //底部导航文字
  final List<String> navTitles;

  //由于是内容自适应，所以这里应该对其初始化进行设定
  final double containerHeight;

  ///缺省参数

  //选中的文本颜色
  final Color lightTextColor;

  //普通的文本颜色
  final Color normalTextColor;

  //选中的文本字体
  final double lightTextSize;

  //普通的文本字体
  final double normalTextSize;

  //当前默认选中的角标
  final int initialPage;

  //导航栏背景颜色
  final Color backgroundColor;

  //中间占位组件
  final Widget? centerWidget;

  //当前点击回调
  final ValueChanged<int>? onTap;

  const BottomAppBarView({
    Key? key,
    required this.lightIcons,
    required this.normalIcons,
    required this.navTitles,
    required this.containerHeight,
    this.lightTextColor = const Color(0XFF222222),
    this.normalTextColor = const Color(0XFF999999),
    this.lightTextSize = 10,
    this.normalTextSize = 10,
    this.initialPage = 0,
    this.backgroundColor = Colors.white,
    this.centerWidget,
    this.onTap,
  }) : super(key: key);

  @override
  State<BottomAppBarView> createState() => _BottomAppBarViewState();
}

class _BottomAppBarViewState extends State<BottomAppBarView> {
  int _selectIndex = 0;

  late int middleIndex;

  late List<Widget> listIcon;

  @override
  void initState() {
    super.initState();

    _selectIndex = widget.initialPage;

    //取中间的角标 ~/整除，结果为int类型
    middleIndex = (widget.lightIcons.length ~/ 2);

  }

  //CircularNotchedRectangle 凹 / AutomaticNotchedShape
  @override
  Widget build(BuildContext context) {
    //这里如果不用SizeBox包裹，默认会占据整个高度
    return SizedBox(
      height: widget.containerHeight,
      child: BottomAppBar(
        //进行匹配当前中间内容，设置中间和导航栏的边距情况
        notchMargin: 5,
        clipBehavior: Clip.antiAlias,
        color: widget.backgroundColor,
        shape: const CircularNotchedRectangle(),
        child: Row(
          //水平分布空间
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _initChildren(),
        ),
      ),
    );
  }

  _initChildren(){
    //初始化当前列表相关数据
    listIcon = [];
    //初始化当前数据
    for (int i = 0; i < widget.lightIcons.length; i++) {
      if (i == middleIndex) {
        //缺省添加的数据
        listIcon.add(const SizedBox());
      }

      listIcon
          .add(_bottomBarItem(i, widget.lightIcons[i], widget.normalIcons[i]));
    }

    return listIcon;
  }

  _bottomBarItem(int index, Widget lightIcon, Widget normalIcon) {
    return Expanded(flex: 1,child: GestureDetector(
      onTap: (){
        _selectIndex = index;

        //点击后回调到上级界面
        if (widget.onTap != null) {
          widget.onTap!(index);
        }
      },
      //使用container包裹，使其宽度撑满当前内容
      child: Container(
        color: widget.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _selectIndex == index ? lightIcon : normalIcon,
            widget.navTitles.length == widget.lightIcons.length
                ? Text(
              widget.navTitles[index],
              style: TextStyle(
                color:_selectIndex == index ?widget.lightTextColor:widget.normalTextColor,
                fontSize: _selectIndex == index?widget.lightTextSize:widget.normalTextSize,
              ),
            )
                : const SizedBox(),
          ],
        ),
      ),
    ),);
  }
}
