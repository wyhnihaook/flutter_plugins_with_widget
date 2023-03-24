import 'package:flutter/material.dart';

import '../config/enum_config.dart';
import '../data/base_controller.dart';
import '../data/location.dart';
import '../util/view_util.dart';
import 'dialog_scope.dart';

///描述:真正承载显示在界面上的组件<定点显示组件>
///功能介绍:真正承载显示在界面上的组件，最终渲染的组件
///创建者:翁益亨
///创建日期:2022/7/26 15:00

typedef HighlightBuilder = Positioned Function(
    Offset targetOffset,
    Size targetSize,
    );

typedef TargetBuilder = Offset Function(
    Offset targetOffset,
    Size targetSize,
    );

typedef ReplaceBuilder = Widget Function(
    Offset targetOffset,
    Size targetSize,
    Offset selfOffset,
    Size selfSize,
    );

typedef ScalePointBuilder = Offset Function(Size selfSize);

class AttachDialogWidget extends StatefulWidget {
  const AttachDialogWidget({
    Key? key,
    required this.child,
    required this.targetContext,
    required this.targetBuilder,
    required this.replaceBuilder,
    required this.controller,
    required this.animationTime,
    required this.useAnimation,
    required this.onMask,
    required this.alignment,
    required this.usePenetrate,
    required this.animationType,
    required this.scalePointBuilder,
    required this.maskColor,
    required this.highlightBuilder,
    required this.maskWidget,
  }) : super(key: key);

  ///触发浮层的组件，在该组件上进行对应位置的展示
  final BuildContext? targetContext;

  /// 自定义坐标点
  final TargetBuilder? targetBuilder;

  final ReplaceBuilder? replaceBuilder;

  /// 是否使用动画
  final bool useAnimation;

  ///动画时间
  final Duration animationTime;

  ///自定义的显示的主体布局
  final Widget child;

  ///widget controller
  final AttachDialogController controller;

  /// 点击背景
  final VoidCallback onMask;

  /// 内容控件方向
  final AlignmentGeometry alignment;

  /// 是否穿透背景,交互背景之后控件
  final bool usePenetrate;

  /// 是否使用Loading情况；true:内容体使用渐隐动画  false：内容体使用缩放动画
  /// 仅仅针对中间位置的控件
  final SmartAnimationType animationType;

  /// 缩放动画的缩放点
  final ScalePointBuilder? scalePointBuilder;

  /// 遮罩颜色
  final Color maskColor;

  /// 自定义遮罩Widget
  final Widget? maskWidget;

  /// 溶解遮罩,设置高亮位置
  final HighlightBuilder highlightBuilder;

  @override
  _AttachDialogWidgetState createState() => _AttachDialogWidgetState();
}

class _AttachDialogWidgetState extends State<AttachDialogWidget>
    with TickerProviderStateMixin {
  AnimationController? _ctrlBg;
  late AnimationController _ctrlBody;

  //target info
  RectInfo? _targetRect;
  BuildContext? _childContext;
  Alignment? _scaleAlignment;
  late Axis _axis;
  late double _postFrameOpacity;//不透明度设置

  //offset size
  late Offset targetOffset;
  late Size targetSize;

  late Widget _child;

  @override
  void initState() {
    _child = widget.child;

    _resetState();

    super.initState();
  }

  void _resetState() {
    //动画信息初始化
    var duration = widget.animationTime;
    if (_ctrlBg == null) {
      _ctrlBg = AnimationController(vsync: this, duration: duration);
      _ctrlBody = AnimationController(vsync: this, duration: duration);
      _ctrlBg?.forward();
      _ctrlBody.forward();
    } else {
      _ctrlBg!.duration = duration;
      _ctrlBody.duration = duration;

      _ctrlBody.value = 0;
      _ctrlBody.forward();
    }

    //不透明度设置，默认0为不显示
    _postFrameOpacity = 0;

    if (widget.targetContext != null) {
      //根据点击事件的上下文，获取widget的信息
      final renderBox = widget.targetContext!.findRenderObject() as RenderBox;
      targetOffset = renderBox.localToGlobal(Offset.zero);//组件坐标
      //renderBox.localToGlobal(Offset(0.0, renderBox.size.height)); //组件下方坐标
      targetSize = renderBox.size;//组件尺寸获取
    }

    //将点击触发的组件，如果存在对应方法，将点击目标的信息进行二次处理，处理成需要的数据，例如：往下边距添加20
    if (widget.targetBuilder != null) {
      targetOffset = widget.targetContext != null
          ? widget.targetBuilder!(
        targetOffset,
        Size(targetSize.width, targetSize.height),
      )
          : widget.targetBuilder!(Offset.zero, Size.zero);
      //容错处理，避免计算的时候对象为null
      targetSize = widget.targetContext != null ? targetSize : Size.zero;
    }

    ViewUtil.addPostFrameCallback((timeStamp) {
      //判断是否挂载完毕，挂载完毕后才能进行浮层的动画展示
      if (mounted) _handleAnimatedAndLocation();
    });

    //设置默认值，从竖直方向切入
    _axis = Axis.vertical;

    //绑定事件，对外提供当前上下文
    widget.controller._bind(this);
  }

  @override
  void didUpdateWidget(covariant AttachDialogWidget oldWidget) {
    if (oldWidget.child != _child) _resetState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {

    //CustomSingleChildLayout 和 SizeTransition 占位面积冲突
    //使用SizeTransition位移动画，不适合使用CustomSingleChildLayout
    //也可使用该方式获取子控件大小
    var child = AdaptBuilder(builder: (context) {
      _childContext = context;
      return Opacity(opacity: _postFrameOpacity, child: _child);
    });

    return Stack(children: [
      //暗色背景widget动画
      _buildBgAnimation(
        onPointerUp: widget.onMask,
        child: (widget.maskWidget != null && !widget.usePenetrate)
            ? widget.maskWidget
            : widget.usePenetrate
            ? Container()
            : ColorFiltered(
          colorFilter: ColorFilter.mode(
            // mask color
            widget.maskColor,
            BlendMode.srcOut,
          ),
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                // any color
                color: Colors.white,
                backgroundBlendMode: BlendMode.dstOut,
              ),
            ),

            //dissolve mask, highlight location
            widget.highlightBuilder(targetOffset, targetSize)
          ]),
        ),
      ),

      //内容Widget动画
      Positioned(
        left: _targetRect?.left,
        right: _targetRect?.right,
        top: _targetRect?.top,
        bottom: _targetRect?.bottom,
        child: widget.useAnimation ? _buildBodyAnimation(child) : child,
      ),
    ]);
  }

  //背景动画效果组件封装，提供点击回调方法
  //这里背景统一使用渐变显示/隐藏的方式
  Widget _buildBgAnimation({
    required void Function()? onPointerUp,
    required Widget? child,
  }) {
    return FadeTransition(
      //CurvedAnimation：线形动画对象（curve字段设置动画模式），默认值范围为0.0到1.0，可以用来控制不透明度（开始动画的不透明度为0，即隐藏状态，动画结束后完全显示）
      //对于背景动画执行方法   forward：显示  reserve：隐藏
      opacity: CurvedAnimation(parent: _ctrlBg!, curve: Curves.linear),
      //Listener处理触摸事件
      child: Listener(
        //事件是否由当前组件消化（默认由本身消化/deferToChild），当前使点击事件下发
        behavior: HitTestBehavior.translucent,
        //这里处理焦点抬起的情况
        onPointerUp: (event) => onPointerUp?.call(),
        child: child,
      ),
    );
  }

  //最终显示组件动画包裹封装
  Widget _buildBodyAnimation(Widget child) {
    //这里设置animation，所有动画都可使用，注意这里使用的默认范围为0-1
    var animation = CurvedAnimation(parent: _ctrlBody, curve: Curves.linear);
    var type = widget.animationType;
    Widget animationWidget = FadeTransition(opacity: animation, child: child);

    //匹配显示过渡对应的动画效果
    if (type == SmartAnimationType.fade) {
      animationWidget = FadeTransition(opacity: animation, child: child);
    } else if (type == SmartAnimationType.scale) {
      animationWidget = ScaleTransition(
        //比例尺所在坐标系原点的对齐。例如：要将比例原点设置为底部中间（x,y），可以使用（0.0，1.0）等同于Alignment.bottomCenter
        //以组件渲染最中心为原点（0，0）  左上角（-1，-1）  右上角（1，-1） 左下角（-1，1） 右小角（1，1）
        //定义从哪个方向开始缩放
        alignment: _scaleAlignment ?? Alignment(0, 0),
        scale: animation,//缩放范围从0-1
        child: child,
      );
    } else if (type == SmartAnimationType.centerFade_otherSlide) {
      //设置其他方位的锁
      if (widget.alignment == Alignment.center) {
        animationWidget = FadeTransition(opacity: animation, child: child);
      } else {
        //尺寸动画，从某个位置开始切入，这里要注意，横向切入，高度是完整显示，宽度逐渐变到对应尺寸。竖直切入，宽度完整显示，高度组件变道对应尺寸
        animationWidget = SizeTransition(
          axis: _axis,
          sizeFactor: _ctrlBody,//动画控制信息: AnimationController
          child: child,//显示组件
        );
      }
    } else if (type == SmartAnimationType.centerScale_otherSlide) {
      if (widget.alignment == Alignment.center) {
        animationWidget = ScaleTransition(
          alignment: _scaleAlignment ?? Alignment(0, 0),
          scale: animation,
          child: child,
        );
      } else {
        animationWidget = SizeTransition(
          axis: _axis,
          sizeFactor: _ctrlBody,
          child: child,
        );
      }
    }

    return animationWidget;
  }

  /// 处理: 动画方向及其位置, 缩放动画的缩放点
  void _handleAnimatedAndLocation() {
    //获取显示的组件的尺寸
    final selfSize = (_childContext!.findRenderObject() as RenderBox).size;
    //获取屏幕尺寸
    final screen = MediaQuery.of(context).size;

    //动画方向及其位置
    _axis = Axis.vertical;
    final alignment = widget.alignment;

    //这里对显示的模式，竖直展开/水平展开做了固定操作。如果右需要修改，可自行实现全新类型进行匹配后再设置对应展开模式
    //根据设定的模式，在对应点击组件的对应位置显示。例如：左上，左中，左下等
    //当前屏幕尺寸结合点击组件的基础数据，实现显示的组件的位置,_targetRect中的数据在Positioned组件中体现
    //targetOffset：当前点击组件的坐标值，以左上角坐标为标准
    //_targetRect构建上下取一，左右取一即可。这里取距底部高度，距左侧宽度来绝对定位

    if (alignment == Alignment.topLeft) {
      _targetRect = _adjustReactInfo(
        //距离屏幕底部的高度。屏幕高度-当前组件的左上角的高度
        bottom: screen.height - targetOffset.dy,
        //距离屏幕左边的宽度。显示左边缘的坐标：点击组件x坐标-显示组件的一半宽度
        left: targetOffset.dx - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.topCenter) {
      _targetRect = _adjustReactInfo(
        bottom: screen.height - targetOffset.dy,
        left: targetOffset.dx + targetSize.width / 2 - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.topRight) {
      _targetRect = _adjustReactInfo(
        bottom: screen.height - targetOffset.dy,
        left: targetOffset.dx + targetSize.width - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.centerLeft) {
      _axis = Axis.horizontal;
      _targetRect = _adjustReactInfo(
        right: screen.width - targetOffset.dx,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.center) {
      _targetRect = _adjustReactInfo(
        left: targetOffset.dx + targetSize.width / 2 - selfSize.width / 2,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.centerRight) {
      _axis = Axis.horizontal;
      _targetRect = _adjustReactInfo(
        left: targetOffset.dx + targetSize.width,
        top: targetOffset.dy + targetSize.height / 2 - selfSize.height / 2,
        fixedHorizontal: true,
      );
    } else if (alignment == Alignment.bottomLeft) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.bottomCenter) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx + targetSize.width / 2 - selfSize.width / 2,
        fixedVertical: true,
      );
    } else if (alignment == Alignment.bottomRight) {
      _targetRect = _adjustReactInfo(
        top: targetOffset.dy + targetSize.height,
        left: targetOffset.dx + targetSize.width - selfSize.width / 2,
        fixedVertical: true,
      );
    }

    //替换控件builder，替换的组件尺寸和被替换组件一致
    if (widget.replaceBuilder != null) {
      Widget replaceChildBuilder() {
        return widget.replaceBuilder!(
          targetOffset,
          targetSize,
          Offset(
            _targetRect?.left != null
                ? _targetRect!.left!
                : screen.width - ((_targetRect?.right ?? 0) + selfSize.width),
            _targetRect?.top != null
                ? _targetRect!.top!
                : screen.height -
                ((_targetRect?.bottom ?? 0) + selfSize.height),
          ),
          selfSize,
        );
      }

      //必须要写在DialogScope的builder之外,保证在scalePointBuilder之前触发replaceBuilder
      _child = replaceChildBuilder();
      //保证controller能刷新replaceBuilder
      if (widget.child is DialogScope) {
        //同步控制器
        _child = DialogScope(
          controller: (widget.child as DialogScope).controller,
          builder: (context) => replaceChildBuilder(),
        );
      }
    }

    //缩放动画的缩放点匹配
    if (widget.scalePointBuilder != null) {
      //获取显示组件的尺寸，获取中间尺寸
      var halfWidth = selfSize.width / 2;
      var halfHeight = selfSize.height / 2;
      //获取需要聚焦的尺寸。实例：Offset(0,0)左上角 (selfSize.width,0)右上角
      var scalePoint = widget.scalePointBuilder!(selfSize);
      //获取处理完毕想要以某点缩放的x/y
      var scaleDx = scalePoint.dx;
      var scaleDy = scalePoint.dy;
      //缩放的位置区间[-1,1]x/y相同，从左到右，从上到下
      //（当前生产的scalePoint的坐标-中间尺寸）/中间尺寸 = [-1,1]区间
      var rateX = (scaleDx - halfWidth) / halfWidth;
      var rateY = (scaleDy - halfHeight) / halfHeight;
      //设置缩放适配的对齐坐标
      _scaleAlignment = Alignment(rateX, rateY);
      //如果没有匹配的转化坐标，默认从(0,0)组件显示中心开始缩放
    }

    //第一帧后恢复透明度,同时重置位置信息
    _postFrameOpacity = 1;
    setState(() {});
  }

  //边界处理逻辑，超出边界后，重置为0
  //左上角坐标为(0,0)
  RectInfo _adjustReactInfo({
    double? left,
    double? right,
    double? top,
    double? bottom,
    bool fixedHorizontal = false,
    bool fixedVertical = false,
  }) {
    final childSize = (_childContext!.findRenderObject() as RenderBox).size;
    final screen = MediaQuery.of(context).size;
    var rectInfo = RectInfo(left: left, right: right, top: top, bottom: bottom);

    //处理左右边界问题
    if (!fixedHorizontal && left != null) {
      if (left < 0) {
        //超出左边界
        rectInfo.left = 0;
        rectInfo.right = null;
      } else {
        var rightEdge = screen.width - left - childSize.width;
        if (rightEdge < 0) {
          //超出右边界
          rectInfo.left = null;
          rectInfo.right = 0;
        }
      }
    }

    //处理上下边界问题
    if (!fixedVertical && top != null) {
      if (top < 0) {
        //超出上边界
        rectInfo.top = 0;
        rectInfo.bottom = null;
      } else {
        var bottomEdge = screen.height - top - childSize.height;
        if (bottomEdge < 0) {
          //超出下边界
          rectInfo.top = null;
          rectInfo.bottom = 0;
        }
      }
    }

    return rectInfo;
  }

  ///等待动画结束,关闭动画资源
  Future<void> dismiss() async {
    if (_ctrlBg == null) return;
    //重置动画状态，重置到最初状态（这里指使界面隐藏）
    _ctrlBg!.reverse();
    _ctrlBody.reverse();

    //
    if (widget.useAnimation) {
      await Future.delayed(widget.animationTime);
    }
  }

  @override
  void dispose() {
    //释放背景/内容动画器
    _ctrlBg?.dispose();
    _ctrlBg = null;
    _ctrlBody.dispose();
    super.dispose();
  }
}

class AdaptBuilder extends StatelessWidget {
  const AdaptBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    //设置包裹内容模式，水平/竖直方向尽可能的包裹内容
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Column(mainAxisSize: MainAxisSize.min, children: [builder(context)])
    ]);
  }
}

class AttachDialogController extends BaseController {
  _AttachDialogWidgetState? _state;

  void _bind(_AttachDialogWidgetState _state) {
    this._state = _state;
  }

  @override
  Future<void> dismiss() async {
    try {
      await _state?.dismiss();
    } catch (e) {
      print("-------------------------------------------------------------");
      print("SmartDialog error: ${e.toString()}");
      print("-------------------------------------------------------------");
    }
    _state = null;
  }
}
