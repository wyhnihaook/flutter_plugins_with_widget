///文本内容带标签显示

import 'package:flutter/material.dart';
import 'package:widget/util/tool_scale.dart';

class RichTextWithTagView extends StatelessWidget {
  ///标签文字
  final String labelText;

  ///标签样式
  final TextStyle? labelTextStyle;

  ///标题文字
  final String titleText;

  ///标题样式
  final TextStyle? titleTextStyle;

  ///最大行数
  final int maxLines;

  ///间距宽度
  final double widthMargin;

  const RichTextWithTagView({Key? key,required this.labelText,required this.titleText , this.labelTextStyle, this.titleTextStyle, this.maxLines = 2, this.widthMargin = 4}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.centerLeft,child: RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          //标签
          //WidgetSpan 占位元素
          WidgetSpan(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.px,vertical: 2.px),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(3.px)),
                child: Text(labelText , style: labelTextStyle ?? TextStyle(fontSize: 11.px, color: Colors.white),),
              )),

          //标签喝标题之前的间距
          WidgetSpan(child: SizedBox(width: widthMargin)),

          //标题
          TextSpan(
            text: titleText,
            style: titleTextStyle ?? TextStyle(fontSize: 15.px,height: 18.px/15.px, color: const Color(0XFF333333),fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),);
  }
}
