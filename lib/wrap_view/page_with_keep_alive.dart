import 'package:flutter/material.dart';

///描述:保存缓存数据
///功能介绍:当前在多个页面切换时，保存当前页面的缓存信息
///创建者:翁益亨
///创建日期:2022/6/21 13:50
class PageKeepAliveView extends StatefulWidget {
  final Widget child;

  const PageKeepAliveView({Key? key, required this.child}) : super(key: key);

  @override
  State<PageKeepAliveView> createState() => _PageKeepAliveViewState();
}

class _PageKeepAliveViewState extends State<PageKeepAliveView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  //需要保存缓存状态必须设置AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true;
}
