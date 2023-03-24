import 'package:flutter/material.dart';
import 'package:widget/collapse/collapse_status.dart';

///描述:可展开/收起文本配置项
///功能介绍:可展开/收起文本配置项
///如果是图片占位的情况，可以通过计算占位的宽度进行处理，额外限制显示的内容
///创建者:翁益亨
///创建日期:2022/8/15 20:06
class TextCollapseConfig extends CollapseStatus{

  TextCollapseConfig({
    required this.contentText,
    this.contentTextStyle = const TextStyle(color: Colors.black,fontSize: 14),
    this.expandText = '展开咯哈哈哈哈',
    this.collapseText = '收起',
    this.operatorTextStyle = const TextStyle(color: Colors.blueAccent,fontSize: 14),
    this.expandContainer,
    this.collapseContainer,
    this.maxLines = 2,
    bool isExpanded = false,
  }):super(isExpanded: isExpanded);

  ///显示的文本内容，如需换行，在填入的参数中手动添加  \n  即可
  final String contentText;

  ///显示文本样式
  final TextStyle contentTextStyle;

  ///收起时，拼接在最后的文本内容
  final String expandText;

  ///展开时，拼接在最后的文本内容
  final String collapseText;

  ///展开/收起时，文本样式
  final TextStyle operatorTextStyle;

  ///必须要实现的属性是最大尺寸约束，因为在后续会使用对应的尺寸信息
  ///收起时，拼接在最后的图标或自定义信息<与文本内容互斥、优先使用图标>
  final Container? expandContainer;

  ///展开时，拼接在最后的图标或自定义信息<与文本内容互斥、优先使用图标>
  final Container? collapseContainer;

  ///默认情况，最多显示的行数
  final int maxLines;

}
