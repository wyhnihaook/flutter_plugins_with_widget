import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; //timer库
import 'package:widget/util/color.dart';

///描述:输入框带倒计时
///功能介绍:当前输入框带倒计时限制功能
///创建者:翁益亨
///创建日期:2022/6/20 10:02

class InputTimerView extends StatefulWidget {
  ///必填参数

  //当前未输入时的提示信息
  final String hint;

  //当前输入的上线
  final int limitLength;

  ///可缺省参数

  //当前输入框焦点监听
  final ValueChanged<bool>? focusChanged;

  //输入内容的边距，其实只用考虑左右边距即可
  final List<double> inputMargin;

  //当前倒计时不同状态下的显示文案信息 例如：["获取验证码","秒","重新发送"]  中间属性是用来启动倒计时拼接参数，根据业务需求设定
  final List<String> statusText;

  //当前倒计时的总时长
  final int countdownTime;

  //当前输入类型设定
  final TextInputType? textInputType;

  //当前颜色尺寸设置
  final Color hintColor;
  final Color contentColor;
  final Color statusColor;

  final double hintSize;
  final double contentSize;
  final double statusSize;

  //当卡内容其的背景色
  final Color backgroundColor;

  //当前分割线的颜色
  final Color splitLineColor;

  //分割线高度
  final double splitHeight;

  //状态管理器的宽度
  final double statusWidth;

  //当前容器圆角
  final double radius;

  //监听当前输入内容
  final ValueChanged<String>? onTextChanged;

  //当前是否需要匹配当前的内容
  final Function? validateData;

  //触发点击处理的外部事件
  final Function? triggerClickEvent;

  const InputTimerView(
    this.hint,
    this.limitLength, {
    Key? key,
    this.focusChanged,
    this.inputMargin = const [16, 16, 16, 16],
    this.statusText = const ["获取验证码", "s", "重新发送"],
    this.countdownTime = 60,
    this.textInputType,
    this.hintColor = const Color(0xFFC7C7C7),
    this.contentColor = const Color(0xFF333333),
    this.statusColor = const Color(0xFF7C75FF),
    this.hintSize = 16,
    this.contentSize = 16,
    this.statusSize = 14,
    this.backgroundColor = Colors.white,
    this.splitLineColor = const Color(0xFFE9E9E9),
    this.splitHeight = 18,
    this.statusWidth = 102,
    this.radius = 0,
    this.onTextChanged,
    this.validateData,
    this.triggerClickEvent,
  }) : super(key: key);

  @override
  State<InputTimerView> createState() => _InputTimerViewState();
}

class _InputTimerViewState extends State<InputTimerView> {
  //倒计时监听

  //当前状态处理
  Timer? _timer;
  int _countdownTime = 0;

  //默认是没有触发当前计时器的
  bool triggerTimer = false;

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
    super.dispose();
    _focusNode.dispose();
    _timer?.cancel();
  }

  //点击后倒计时的方法
  void startCountdownTimer() {
    //说明当前正在倒计时，不允许再次触发
    if (_countdownTime != 0) {
      return;
    }

    //当前是否需要校验输入内容
    //当前是否匹配为有效数据,默认是true，匹配
    bool validateStatus =
        widget.validateData == null ? true : widget.validateData!();

    if (!validateStatus) {
      //当前不匹配，后续可衔接对应提示信息
      return;
    }

    if (widget.triggerClickEvent != null) {
      widget.triggerClickEvent!();
    }
    //触发过计时器信息
    triggerTimer = true;

    //当前开始设置内容后，开始倒计时，并且刷新当前的界面
    setState(() {
      _countdownTime = widget.countdownTime;
    });

    const oneSec = Duration(seconds: 1);

    //启动倒计时
    _timer = Timer.periodic(
        oneSec,
        (timer) => {
              setState(() {
                if (_countdownTime < 1) {
                  _timer?.cancel();
                } else {
                  _countdownTime = _countdownTime - 1;
                }
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _input()),
          SizedBox(
            width: 0.5,
            height: widget.splitHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(color: widget.splitLineColor),
            ),
          ),
          GestureDetector(
            onTap: startCountdownTimer,
            child: SizedBox(
              width: widget.statusWidth,
              child: Center(
                child: Text(
                  _countdownTime > 0
                      ? '$_countdownTime${widget.statusText[1]}'
                      : (triggerTimer
                          ? widget.statusText[2]
                          : widget.statusText[0]),
                  style: TextStyle(
                    fontSize: widget.statusSize,
                    color: widget.statusColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  //输入框
  _input() {
    return TextField(
      focusNode: _focusNode,
      maxLength: widget.limitLength,
      onChanged: widget.onTextChanged,
      keyboardType: widget.textInputType,
      //当前光标色值设定
      cursorColor: redColor,
      cursorWidth: 1,
      style:
      TextStyle(color: widget.contentColor, fontSize: widget.contentSize),
      decoration: InputDecoration(
        //取消默认内边距必须结合设置 isDense+contentPadding
          isDense: true,
          contentPadding:  EdgeInsets.only(
              right: widget.inputMargin[2],
              left: widget.inputMargin[0],
              top: widget.inputMargin[1],
              bottom: widget.inputMargin[3]),
          border: InputBorder.none,
          counterText: "",
          hintText: widget.hint,
          // fillColor: Colors.red,
          // filled: true,
          hintStyle: TextStyle(
            fontSize: widget.hintSize,
            color: widget.hintColor,
          )),
    );
  }
}
