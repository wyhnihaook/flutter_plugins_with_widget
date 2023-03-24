import 'dart:ui';

/// SmartDialog Controller
class SmartDialogController {
  VoidCallback? callback;

  /// 刷新dialog
  void refresh() {
    callback?.call();
  }

  void setListener(VoidCallback? voidCallback) {
    callback = voidCallback;
  }

  void dismiss() {
    callback = null;
  }
}
