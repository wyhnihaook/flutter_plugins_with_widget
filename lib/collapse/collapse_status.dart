///描述:是否展开的内容处理
///功能介绍:记录当前的内容展开/收起状态
///创建者:翁益亨
///创建日期:2022/8/16 14:53
class CollapseStatus {
  CollapseStatus({
    //默认是否展开数据初始化
    required this.isExpanded,
  });

  ///是否展开。true:展开 / false:收起
  bool isExpanded = false;

  ///操作展开收起的状态
  void operatorExpandStatus() {
    isExpanded = !isExpanded;
  }
}
