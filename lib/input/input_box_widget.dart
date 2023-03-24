import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget/util/color.dart';

///描述:输入框组件，水平/竖直 输入样式
///功能介绍:输入框组件封装
///创建者:翁益亨
///创建日期:2022/6/17 10:55

//当前不同模式下（水平/竖直）内容差值定义
///不可随便删除键值对，需要对代码完全迭代后才能操作
const modeDiffSizeInfo = {'textSizeDiff': 2, 'marginSizeDiff': 4};

class InputBoxView extends StatefulWidget {
  ///必填界面显示参数

  //设置标题信息
  final String title;

  //设置当前空占位的描述信息
  final String hint;

  ///可缺省参数

  //背景颜色
  final Color backgroundColor;

  //是否是水平输入模式，默认是水平输入  false情况是竖直输入模式
  final bool isHorizontalType;

  //当前输入光标居左还是居右,默认从左侧输入到右侧
  final bool inputGravityLeft;

  //整体的高度由当前内边距+字体高度
  final List<double> containerMargin;

  //当前输入内容监听
  final ValueChanged<String>? onTextChanged;

  //当前输入框焦点监听
  final ValueChanged<bool>? focusChanged;

  //输入框类型定义，默认是全键盘输入方式
  final TextInputType? keyBoardType;

  //是否是密文输入方式，默认不是安全加密输入
  final bool safetyInput;

  //是否显示下划分割线，默认显示
  final bool showSplitLine;

  //底部下划线距左边距，默认0
  final double lineToLeft;

  //底部下划线距右边距，默认0
  final double lineToRight;

  //颜色尺寸等功能设置
  final Color titleColor;
  final Color textColor;
  final Color hintColor;
  final Color lineColor;

  final double titleSize;
  final double hintSize;
  final double textSize; //输入内容的字体大小
  final double lineHeight;

  final bool isNecessary;//是否为必填
  final bool isBold;//是否是加粗状态

  final Map modeDiffSize;//hint和content的尺寸差距

  const InputBoxView(this.title, this.hint,
      {Key? key,
      this.isNecessary = false,
      this.isBold = false,
        this.modeDiffSize=  const {'textSizeDiff': 0, 'marginSizeDiff': 0},
      this.backgroundColor = Colors.white,
      this.isHorizontalType = true,
      this.inputGravityLeft = true,
      this.containerMargin = const [16, 16, 40, 16],
      this.onTextChanged,
      this.focusChanged,
      this.keyBoardType,
      this.safetyInput = false,
      this.showSplitLine = true,
      this.lineToLeft = 16,
      this.lineToRight = 0,
      this.titleColor = const Color(0xFF333333),
      this.textColor = const Color(0xFF333333),
      this.hintColor = const Color(0xFFB3B3B3),
      this.lineColor = const Color(0xFFE9E9E9),
      this.titleSize = 16,
      this.hintSize = 16,
      this.textSize = 16,
      this.lineHeight = 0.5})
      : super(key: key);

  @override
  State<InputBoxView> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBoxView> {
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

  //绘制当前页面效果
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Column(
        children: [
          widget.isHorizontalType
              ? Row(
            children: [
              _inputView(),
              //设置占剩余全部位置
              Expanded(
                child: _input(),
              )
            ],
          )
              : Column(
            //设置次轴居左显示
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputView(),
              _input(),
            ],
          ),
          //设置分割线
          widget.showSplitLine
              ? Divider(
            height: widget.lineHeight,
            color: widget.lineColor,
            indent: widget.lineToLeft,
            endIndent: widget.lineToRight,
            thickness: widget.lineHeight,
          )
              : const SizedBox()
        ],
      ),
    );
  }

  ///当前子容器抽取
  _inputView() {
    return Container(
      margin: EdgeInsets.fromLTRB(
          widget.containerMargin[0],
          widget.containerMargin[1],
          widget.containerMargin[2],
          widget.isHorizontalType ? widget.containerMargin[3] : 0),
      child: RichText(
        text: TextSpan(
            text:widget.title,
            style: TextStyle(
                fontWeight: widget.isHorizontalType ? null : widget.isBold?FontWeight.w800:null,
                fontSize: widget.titleSize,
                color: widget.titleColor),
          children: [
            TextSpan(text:  widget.isNecessary?" *":"",style: TextStyle(fontSize: 14,color: Color(0XFFE13737)))
          ]
        ),
      )
    );
  }

  ///返回当前输入框View
  _input() {
    return Padding(
      //当前间距保持左右一致
      padding: EdgeInsets.only(
          left: widget.isHorizontalType ? 0 : widget.containerMargin[0],
          right: widget.containerMargin[0]),
      child: TextField(
        textAlign: widget.inputGravityLeft ? TextAlign.start : TextAlign.end,
        focusNode: _focusNode,
        onChanged: widget.onTextChanged,
        obscureText: widget.safetyInput,
        keyboardType: widget.keyBoardType,
        //自动聚焦设定
        autofocus: false,
        //当前光标色值设定
        cursorColor: redColor,
        cursorWidth: 1,

        //内部-2/-4可以根据设计图稍作调整，对不同样式设置不同比例的尺寸

        style: TextStyle(
          fontSize: widget.isHorizontalType
              ? widget.textSize
              : (widget.textSize - widget.modeDiffSize["textSizeDiff"]!),
          color: widget.textColor,
        ),

        //输入框样式设定
        decoration: InputDecoration(
            //取消默认内边距必须结合设置 isDense+contentPadding
            isDense: true,
            contentPadding: EdgeInsets.only(
                top: widget.isHorizontalType
                    ? widget.containerMargin[1]
                    : (widget.containerMargin[1] -
                    widget.modeDiffSize["marginSizeDiff"]!),
                bottom: widget.containerMargin[1]),
            //隐藏默认边框
            border: InputBorder.none,
            //取消底部字符计数
            counterText: "",
            //取消当前的边框样式
            hintText: widget.hint,
            //设置背景色，可用于查看当前组件的大小
            // fillColor: Colors.red,
            // filled: true,
            hintStyle: TextStyle(
                fontSize: widget.isHorizontalType
                    ? widget.hintSize
                    : (widget.hintSize - widget.modeDiffSize["textSizeDiff"]!),
                color: widget.hintColor)),
      ),
    );
  }
}
