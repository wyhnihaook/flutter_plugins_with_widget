import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget/util/color.dart';

///描述:输入文本样式，纯输入模式，所以必须监听返回数据信息做外部内容同步
///功能介绍:固定文本输入模式
///创建者:翁益亨
///创建日期:2022/6/17 17:27
class TextInputBoxView extends StatefulWidget {
  ///必填参数

  //容器高度需要提前确定
  final double primaryHeight;

  final int limitLength; //当前输入上线

  final String hintText;


  ///缺省参数

  //当前输入框焦点监听
  final ValueChanged<bool>? focusChanged;

  //当前主背景颜色
  final Color primaryColor;

  //当前主背景的内边距
  final List<double> primaryPadding;

  //次背景颜色
  final Color secondaryColor;

  //当前次背景的内边距
  final List<double> secondaryPadding;

  //当前内容颜色
  final Color inputTextColor;

  //默认提示输入色值
  final Color inputHintColor;

  //当前输入内容上线文本颜色
  final Color tipColor;

  //尺寸数据
  final double inputTextSize;
  final double inputHintSize;
  final double tipSize;

  //当前输入内容监听
  final ValueChanged<String>? onTextChanged;

  const TextInputBoxView(this.primaryHeight, this.limitLength,this.hintText,
      {Key? key,
        this.focusChanged,
        this.primaryColor = Colors.white,
        this.primaryPadding = const [12, 12, 12, 12],
        this.secondaryColor = const Color(0xFFF6F7F9),
        this.secondaryPadding = const [8, 8, 8, 8],
        this.inputTextColor = const Color(0xFF333333),
        this.inputHintColor = const Color(0xFFBFBFBF),
        this.tipColor = const Color(0xFF999999),
        this.inputTextSize = 14,
        this.inputHintSize = 14,
        this.tipSize = 12,
        this.onTextChanged,
       })
      : super(key: key);

  @override
  State<TextInputBoxView> createState() => _TextInputBoxViewState();
}

class _TextInputBoxViewState extends State<TextInputBoxView> {

  //当前输入监听内容
  int _inputCount = 0;

  //判断当前输入框是否获取到光标
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      //变更聚焦状态之后，会进行回调
      bool hasFocus = _focusNode.hasFocus;
      if(!hasFocus){
        //失去焦点的时候需要关闭软键盘，避免切换到其他的输入框时，还是当前软键盘的输入模式
        //当前方法是全局收起软键盘的作用
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }

      //添加到外部的回调
      if (widget.focusChanged != null) {
        widget.focusChanged!(hasFocus);
      }
    });
  }

  @override
  void dispose() {
    //回收监听
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      //使Container容器自动撑满整行
      alignment: Alignment.topLeft,

      color: widget.primaryColor,
      height: widget.primaryHeight,
      padding: EdgeInsets.fromLTRB(
          widget.primaryPadding[0], widget.primaryPadding[1],
          widget.primaryPadding[2], widget.primaryPadding[3]),
      child: Container(
        alignment: Alignment.topLeft,

        padding: EdgeInsets.fromLTRB(
            widget.secondaryPadding[0], widget.secondaryPadding[1],
            widget.secondaryPadding[2], widget.secondaryPadding[3]),

        //设置圆角
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: widget.secondaryColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _input(),
            ),
            Text(
              "$_inputCount/${widget.limitLength}",
              style: TextStyle(
                fontSize: widget.tipSize,
                color: widget.tipColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  //当前可以输入的区域
  _input() {
    return TextField(
      onChanged: (item) {
        if(widget.onTextChanged!=null){
          widget.onTextChanged!(item);
        }

        setState(() {
          _inputCount = item.length;
        });
      },
      focusNode: _focusNode,
      //自动聚焦设定
      autofocus: false,
      //当前光标色值设定
      cursorColor: redColor,
      cursorWidth: 1,
      //设置输入的最大字符长度
      maxLength: widget.limitLength,

      style: TextStyle(
        fontSize: widget.inputTextSize,
        color: widget.inputTextColor,
      ),

      decoration: InputDecoration(
          isDense: true,
          contentPadding:const EdgeInsets.all(0),
          //隐藏默认边框
          border: InputBorder.none,
          //取消底部字符计数
          counterText: "",
          hintText: widget.hintText,
          //设置背景色，可用于查看当前组件的大小
          // fillColor: Colors.red,
          // filled: true,
          hintStyle: TextStyle(
              fontSize:widget.inputHintSize,
              color: widget.inputHintColor)),

    );
  }
}
