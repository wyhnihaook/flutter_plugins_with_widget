library widget;

///导出可直接使用的文件，用于使用库的项目中，能直接快捷import引入，一次性引入使用的全部组件信息。也可以不声明以下内容，在使用时，直接通过绝对路径单一引入

/// 轮播模块
export 'swiper/swiper.dart';
export 'swiper/swiper_config.dart';

///选择器模块
export 'picker/app_picker.dart';
export 'picker/app_tab_picker.dart';
export 'picker/picker_data_adapter.dart';

///顶部、底部导航栏模块
export 'nav_bar/app_bottom_navigator.dart';
export 'nav_bar/app_nav_bar.dart';
export 'nav_bar/app_search_bar.dart';
export 'nav_bar/app_top_navigator.dart';

///文本+图片展示类模块
export 'input/input_box_timer_widget.dart';
export 'input/input_box_widget.dart';
export 'input/selection_box_widget.dart';
export 'input/text_input_box_widget.dart';
export 'input/selection_box_display_widget.dart';

///展开类模块
export 'collapse/text/expanded_text.dart';
export 'collapse/text/text_collapse_config.dart';
export 'collapse/collapse.dart';
export 'collapse/collapse_config.dart';
export 'collapse/collapse_status.dart';

///dialog+popWindow模块
export 'dialog/show_dialog.dart';
export 'dialog/smart_dialog/smart_dialog.dart';
export 'dialog/smart_dialog/init_dialog.dart';
export 'dialog/smart_dialog/config/enum_config.dart';
export 'dialog/smart_dialog/widget/popwindow_helper.dart';

///普通标签文本
export 'wrap_view/rich_text_with_tag_view.dart';
