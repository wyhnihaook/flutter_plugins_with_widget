import 'package:widget/dialog/smart_dialog/config/smart_config_attach.dart';
import 'package:widget/dialog/smart_dialog/config/smart_config_dialog.dart';
import 'package:widget/dialog/smart_dialog/config/smart_config_loading.dart';
import 'package:widget/dialog/smart_dialog/config/smart_config_toast.dart';

///描述:外部统一调用展示类的配置信息
///功能介绍:全局配置统一在这里处理
///创建者:翁益亨
///创建日期:2022/7/13 14:18
class SmartConfig{

  /// showToast(): toast全局配置项
  SmartConfigToast toast = SmartConfigToast();

  /// showLoading(): loading全局配置项
  SmartConfigLoading loading = SmartConfigLoading();

  /// show():  dialog全局配置项
  SmartConfigDialog dialog = SmartConfigDialog();

  /// showAttach(): attach dialog全局配置项
  SmartConfigAttach attach = SmartConfigAttach();

  /// 自定义dialog，attach或loading，是否存在在界面上
  bool get isExist => dialog.isExist  || loading.isExist || attach.isExist;

  // /// 自定义dialog是否存在在界面上
  bool get isExistDialog => dialog.isExist || attach.isExist;

  /// toast是否存在在界面上
  bool get isExistToast => toast.isExist;

  /// loading是否存在界面上
  bool get isExistLoading => loading.isExist;

}