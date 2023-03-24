import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;

///描述:重写TabBar 中的ScrollPhysics
///功能介绍:用于监听滑动到边界处理
///从scroll_physics.dart文件中拷贝ClampingScrollPhysics类进行额外回调参数的添加即可
///applyPhysicsToUserOffset里面返回的offset，因为这个offset滑动超出边界的时候，返回的值为负数，当offset为负值的时候，我们只需要判断当前的页面的pageIndex，就能确定是左边活动到边界，还是右边滑动到边界
///创建者:翁益亨
///创建日期:2022/7/5 17:01
typedef OverCallBack = Function(double offset);

///居于最右侧回调
typedef VisibleRightPlaceHolderCallBack = Function(bool isVisible);

class CScrollPhysics extends ScrollPhysics {
  final OverCallBack? overCallBack;
  final VisibleRightPlaceHolderCallBack? visibleRightPlaceHolderCallBack;

  const CScrollPhysics(
      { this.overCallBack,
      this.visibleRightPlaceHolderCallBack,
      ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CScrollPhysics(
        overCallBack: this.overCallBack,
        visibleRightPlaceHolderCallBack: this.visibleRightPlaceHolderCallBack,
        parent: buildParent(ancestor));
  }

  /// [position] 当前的位置, [offset] 用户拖拽距离，相对的位置，往左滑动为负数，往右滑动为正数；从刚刚开始滑动的位置为零点
  /// 将用户拖拽距离 offset 转为需要移动的 pixels
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    //print('applyPhysicsToUserOffset: ' + offset.toString());
    if (overCallBack != null) {
      overCallBack!(offset);
    }

    return super.applyPhysicsToUserOffset(position, offset);
  }

  /// 返回 overscroll ，如果返回 0 ，overscroll 就一直是0
  /// 返回边界条件
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
              'The proposed new position, $value, is exactly equal to the current position of the '
              'given ${position.runtimeType}, ${position.pixels}.\n'
              'The applyBoundaryConditions method should only be called when the value is '
              'going to actually change the pixels, otherwise it is redundant.'),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty)
        ]);
      }
      return true;
    }());

    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) // underscroll，到达左边界
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) // overscroll，到达右边界
    {
      if (visibleRightPlaceHolderCallBack != null) {
        visibleRightPlaceHolderCallBack!(false);
      }
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent <
            position
                .pixels) // hit top edge，滑动到最左侧（相对的最顶侧）(tab栏滑动的时候会触发，联动底部页面滑动时无法触发)
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent <
            value) // hit bottom edge，滑动到最右侧（相对的最底侧）(tab栏滑动的时候会触发，联动底部页面滑动时无法触发)
    {
      if (visibleRightPlaceHolderCallBack != null) {
        visibleRightPlaceHolderCallBack!(false);
      }
      return value - position.maxScrollExtent;
    }

    if (visibleRightPlaceHolderCallBack != null) {
      visibleRightPlaceHolderCallBack!(true);
    }
    return 0.0; //标识当前正在移动
  }

  ///创建一个滚动的模拟器
  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double? end;
      if (position.pixels > position.maxScrollExtent)
        end = position.maxScrollExtent;
      if (position.pixels < position.minScrollExtent)
        end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end!,
        math.min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) return null;
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent)
      return null;
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent)
      return null;
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}
