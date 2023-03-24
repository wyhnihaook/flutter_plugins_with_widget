class SmartTag {

  //（默认）不存在tag

  /// DialogRoute setting name 使用系统的showDialog方法展示弹窗
  static const String systemDialog = 'smartSystemDialog';

  ///SmartDialog tag：keepSingle 保持单例模式，从DialogProxy.instance.dialogQueue遍历。如果存在，就直接复用，如果没有就新建
  static const String keepSingle = 'smartKeepSingle';
}
