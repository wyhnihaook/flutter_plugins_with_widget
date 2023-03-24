///描述:全局类型配置
///功能介绍:类型
///创建者:翁益亨
///创建日期:2022/7/13 10:45

///toast展示类型
enum SmartToastType{
  /// 每一条toast都会显示，当前toast消失之后，后一条toast才会显示
  normal,

  /// 连续调用toast，在第一条toast存在界面的期间内，调用的其它toast都将无效
  first,

  /// 连续调用toast，后一条toast会顶掉前一条toast
  last,

  /// 连续调用toast，第一条toast正常显示，其显示期间产生的所有toast，仅最后一条toast有效
  firstAndLast,
}


///弹窗展示的动画类型
enum SmartAnimationType{
  /// 全部位置都为渐隐动画
  fade,

  /// 全部位置都为缩放动画
  scale,

  /// 中间位置的为渐隐动画, 其他位置为位移动画
  centerFade_otherSlide,

  /// 中间位置的为缩放, 其他位置为位移动画
  centerScale_otherSlide,
}

/// 弹窗await结束的类型
enum SmartAwaitOverType {
  /// dialog完全关闭的时刻
  dialogDismiss,

  /// 弹窗完全出现时刻(弹窗出现的开始动画结束时)
  dialogAppear,

  /// await 10毫秒后结束
  none
}

enum DialogType {
  //普通页面上的弹窗
  dialog,
  //关联页面具体坐标显示弹窗
  attach,
  //所有普通弹窗
  allDialog,
  //所有关联具体坐标的弹窗
  allAttach,
}

enum SmartStatus {

  /// 关闭单个dialog：loading（showLoading），custom（show）或 attach（showAttach）
  /// 这里有一个严重缺陷，不是loading就是Dialog，如果Dialog已经通过返回键取消了。延时之后调用loading的dismiss就会又对Dialog进行Dismiss，导致又退出一级路由
  /// 所以loading要使用具体的SmartStatus.loading进行关闭
  smart,

  /// 关闭toast（showToast）
  toast,

  /// 关闭所有toast（showToast）
  allToast,

  /// 关闭loading（showLoading）
  loading,

  /// 关闭单个custom dialog（show）
  custom,

  /// 关闭单个attach dialog（showAttach）
  attach,

  /// 关闭单个dialog（attach或custom）
  dialog,

  /// 关闭打开的所有custom dialog，但是不关闭toast，loading和attach dialog
  allCustom,

  /// 关闭打开的所有attach dialog，但是不关闭toast，loading和custom dialog
  allAttach,

  /// 关闭打开的所有dialog（attach和custom），但是不关闭toast和loading
  allDialog,
}