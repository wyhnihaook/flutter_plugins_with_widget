import 'package:flutter/material.dart';
import 'package:widget/collapse/collapse_config.dart';

///描述:折叠面板容器
///功能介绍:折叠面板容器
///创建者:翁益亨
///创建日期:2022/8/11 10:57
class Collapse extends StatefulWidget {
  ///容器配置项同步
  final CollapseConfig collapseConfig;

  const Collapse({required this.collapseConfig, Key? key})
      : super(key: key);

  @override
  _CollapseState createState() => _CollapseState();
}

class _CollapseState extends State<Collapse> with SingleTickerProviderStateMixin{
  //标识是否当前为展开模式

  //动画控制器
  late AnimationController _animationController;

  //设置过渡速率
  late CurvedAnimation _curvedAnimation;

  //真正的过渡动画对象，用来指定过滤线性变化内容.其中泛型可以指定任意可识别过渡类型，例如：double、Decoration
  //使用的动画内容：Animation = AnimationController动画控制器 + Tween过渡的数据(可缺省) + CurvedAnimation曲线过渡模式设置(可缺省)
  late Animation<double> _animation;

  //滑动位置处理
  late  Animation<double> _slideAnimation;

  //当前控制的高度，用来显示展示的动画
  late double controllerWidgetHeight = 27;

  @override
  void initState() {
    super.initState();


    if(widget.collapseConfig.animType == AnimType.none){

    }else{
      //默认情况下，AnimationController使用对象的范围从0.0到1.0
      _animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 300));

      //curve属性设置
      //linear	匀速的
      // decelerate	匀减速
      // ease	开始加速，后面减速
      // easeIn	开始慢，后面快
      // easeOut	开始快，后面慢
      // easeInOut	开始慢，然后加速，最后再减速
      _curvedAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

      //创建线性变化的Animation对象
      //普通动画需要手动监听动画状态，刷新UI
      if(widget.collapseConfig.animType == AnimType.fade){
        //重新调整动画使用对象的范围，从0.0到1.0
        //动画效果，在1000毫秒内，从0.0到1.0变化（渐变透明）
        _animation = Tween(begin: 0.0,end:1.0).animate(_curvedAnimation);
        //监听动画过渡进度，从0.0到1.0每次渲染都会走回调，没有用动画组件包裹的时候，可以在回调中通过setState方法一直刷新界面状态
        _animationController.addStatusListener((status) {
          //这里要区分forward对应completed   reverse对应dismissed
          if(status == AnimationStatus.dismissed){
            //动画完成之后，设置对应状态
            setState(() {});
          }
        });

      }else if(widget.collapseConfig.animType == AnimType.translate){
        //Tween对象的evaluate方法，不断的从动画中获取数值并返回 (0,-1)
        //拓展：DecorationTween可以修饰被背景渐变
        _slideAnimation = Tween<double>(begin:0, end:1).animate(_animationController);
        _animationController.addStatusListener((status) {
          if(status == AnimationStatus.dismissed){
            setState(() {

            });
          }
        });
      }

      if(widget.collapseConfig.isExpanded){
        //默认是否设置展开
        _animationController.forward();
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    //高度由子组件撑开
    return Container(
      decoration: widget.collapseConfig.boxDecoration,
      margin: widget.collapseConfig.containerMargin,
      child: Column(
        //设置包裹内容
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            //默认只有存在子组件的区域能响应，设置behavior属性，使其包裹内容的所有区域都能响应点击事件
            behavior: HitTestBehavior.translucent,
            onTap: () {
              widget.collapseConfig.operatorExpandStatus();
              widget.collapseConfig.operatorCollapseCallBack?.call(widget.collapseConfig.isExpanded );

              if(widget.collapseConfig.animType == AnimType.none){
                setState(() {
                });
              }else{
                if(widget.collapseConfig.animType == AnimType.fade){
                  if(widget.collapseConfig.isExpanded ){
                    //正向执行0-1
                    setState(() {
                    });
                    _animationController.forward(from: _animationController.value);

                  }else{
                    //反向执行1-0，完成后设置隐藏
                    _animationController.reverse(from: _animationController.value);
                  }
                }else if(widget.collapseConfig.animType == AnimType.translate){
                  if(widget.collapseConfig.isExpanded ){
                    setState(() {
                    });
                    _animationController.forward(from: _animationController.value);
                  }else{
                    //收起的情况，要收起完毕才设置重新设置界面刷新隐藏
                    _animationController.reverse(from: _animationController.value);
                  }
                }
              }

            },
            child: widget.collapseConfig.collapseItemBuilder,
          ),
          Offstage(
            offstage: !widget.collapseConfig.isExpanded ,
            child:childWidget(widget.collapseConfig.expandChildItemBuilder),
          )
        ],
      ),
    );
  }

  ///展开收起动画实现
  //1.controller对象用来控制动画周期
  //2.过渡模式设置CurvedAnimation
  //3.选择动画模式，缩放/渐变/移动...


  //开启动画controller.forward  逆向执行动画controller.repeat
  //注意：在页面销毁时，必须在super.dispose()方法上使用controller.dispose()释放资源


  ///渐变显示/隐藏
  FadeTransition fadeAnimContainer(Widget child){
    return FadeTransition(
      opacity: _animation,
      child: child,
    );
  }

  SizeTransition sizeTransitionContainer(Widget child){
    return SizeTransition(
      sizeFactor: _slideAnimation,
      axis: Axis.vertical,
      //vertical 竖直切入点设置/AlignmentDirectional(-1.0, axisAlignment),设置y轴开始位置
      //表示动画出现的原始位置偏移量，如果是在垂直方向指的是y，如果是横轴方向指的是x
      //1.跟随页面比例收起和展开（偏移量是整个页面的内容）。0.居中显示收起和展开过渡效果（偏移量是原来的一半）。-1.直接显示完毕，内容不跟随页面有滑动效果(没有偏移量)
      //1标识底部，中心为0，-1为顶部
      //示例：竖直方向-1的情况，
      axisAlignment: -1,
      child: child,
    );
  }


  Widget childWidget(Widget child){
    switch(widget.collapseConfig.animType){
      case AnimType.fade:
        return fadeAnimContainer(child);
      case AnimType.translate:
        return sizeTransitionContainer(child);
    }

    return child;
  }

  @override
  void dispose(){
    if(widget.collapseConfig.animType!=AnimType.none){
      if(_animationController.isAnimating){
        _animationController.stop();
      }
      _animationController.dispose();
    }
    super.dispose();
  }

  ///AnimatedWidget创建一个可重用动画的widget。要从widget中分离出动画过渡，使用AnimatedBuilder。
  ///参考：AnimatedBuilder、AnimatedModalBarrier、DecoratedBoxTransition、FadeTransition、
  ///PositionedTransition、RelativePositionedTransition、RotationTransition、ScaleTransition、SizeTransition、SlideTransition
  ///AnimatedWidget(基类)中会自动调用addListener()和setState()
}
