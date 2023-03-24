import 'package:flutter/material.dart';

///描述:包含输入边款的输入文本框
///功能介绍:包含输入边款的输入文本框
///创建者:翁益亨
///创建日期:2023/3/17 11:32
class InputBoxWithFrameWidget extends StatefulWidget {
  //标题
  final String title;

  //标题样式
  final Color titleColor;
  final double titleSize;

  //间隔
  final double space;

  /// 输入框内容定义

  //输入框默认文本内容
  final String hintText;

  //默认展示样式内容
  final TextStyle? hintTextStyle;

  //输入后文本样式
  final TextStyle? editTextStyle;

  //输入框类型定义，默认是全键盘输入方式
  final TextInputType? keyBoardType;

  //是否是密文输入方式，默认不是安全加密输入
  final bool safetyInput;

  //内边距
  final EdgeInsetsGeometry? contentPadding;

  //文本内容修改时的监听
  final ValueChanged<String>? onTextChanged;

  //边框设定
  final InputBorder? inputBorder;

  //删除按钮
  final String localDeleteImageUrl;

  const InputBoxWithFrameWidget(
      {Key? key,
      this.title = "保单号",
      this.titleColor = const Color(0XFF333333),
      this.titleSize = 14,
      this.space = 10,
      this.hintText = "请输入保单号",
      this.hintTextStyle,
      this.editTextStyle,
      this.keyBoardType,
      this.safetyInput = false,
      this.contentPadding,
      this.inputBorder,
      this.onTextChanged,
      this.localDeleteImageUrl = "ic_delete_person.png"})
      : super(key: key);

  @override
  _InputBoxWithFrameWidgetState createState() =>
      _InputBoxWithFrameWidgetState();
}

class _InputBoxWithFrameWidgetState extends State<InputBoxWithFrameWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: widget.titleSize,
            color: widget.titleColor,
          ),
        ),
        SizedBox(
          width: widget.space,
        ),
        Expanded(
            child: TextField(
          textAlign: TextAlign.start,
          onChanged: widget.onTextChanged,
          obscureText: widget.safetyInput,
          keyboardType: widget.keyBoardType,
          //自动聚焦设定
          autofocus: false,
          //当前光标色值设定
          cursorColor: Colors.black,
          cursorWidth: 1,

          style: widget.editTextStyle,

          //输入框样式设定
          decoration: InputDecoration(
              //取消默认内边距必须结合设置 isDense+contentPadding
              isDense: true,
              contentPadding: widget.contentPadding,
              //隐藏默认边框
              enabledBorder: widget.inputBorder,
              focusedBorder: widget.inputBorder,
              //取消底部字符计数
              counterText: "",
              //取消当前的边框样式
              hintText: widget.hintText,
              //设置背景色，可用于查看当前组件的大小
              // fillColor: Colors.red,
              // filled: true,
              hintStyle: widget.hintTextStyle),
        ))
      ],
    );
  }


  //inputBorder
  // OutlineInputBorder(
  // borderRadius:  BorderRadius.circular( kScale(4)),
  // borderSide: BorderSide(
  // color:kColorHex(0XDDDDDD),width: 0.5
  // ),
  // )
}
