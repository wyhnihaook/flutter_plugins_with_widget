import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///描述:顶部导航栏封装
///功能介绍:顶部导航栏
///创建者:翁益亨
///创建日期:2022/6/20 15:17

//头部状态栏透明化
//在main.dart入口文件的main函数最后执行即可  SystemChrome.setSystemUIOverlayStyle(systemUiLightOverlayStyle);
//图标白色/亮色
SystemUiOverlayStyle systemUiLightOverlayStyle =
const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,//状态栏
  systemNavigationBarColor:Color(0xffffffff),//虚拟按键背景色
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,//虚拟按键图标色
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.light,
);

//图标暗色
SystemUiOverlayStyle systemUiDarkOverlayStyle =
const SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,//状态栏
  systemNavigationBarColor:Color(0xffffffff),//虚拟按键背景色
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,//虚拟按键图标色
  statusBarIconBrightness: Brightness.dark,//状态栏图标颜色类型设置
  statusBarBrightness: Brightness.dark,
);


//封装当前响应的头部标题
//由于当前头部标题全局统一使用，所以这里直接统一修改标准即可
appBarView(
  String title, {
  //标题的字号
  titleSize = 18.0,
  //标题的颜色
  titleColor = const Color(0XFF333333),
  //右侧可能存在的组件控制显示与否
  rightTitle,
  rightTitleSize = 14.0,
  rightTitleColor = const Color(0XFF776FFF),

  //右侧A模块的图片
  rightAImage,
  rightBImage,

  //点击响应（最多2个，图文结合，从左到右的顺序A->B设置）
  rightAClickEvent,
  rightBClickEvent,
  //左侧图标展示，默认是返回按钮，这里只做简单处理，展示即可
  leftIcon = const BackButton(),
}) {

  return AppBar(
    //左侧图片
    leading: leftIcon,
    //标题文本设置居中显示
    centerTitle: true,
    //标题文本显示
    title: Text(
      title,
      //加粗标准定位w600
      style: TextStyle(
          fontSize: titleSize, color: titleColor, fontWeight: FontWeight.w600),
    ),
    //右侧显示内容集合
    actions: [
      //highlightColor:Colors.transparent,radius: 0.0,  取消水波纹效果
      //图标信息展示
      rightAImage != null
          ? InkWell(
              highlightColor: Colors.transparent,
              radius: 0.0,
              onTap: rightAClickEvent,
              child: rightAImage,
            )
          : const SizedBox(),

      rightBImage != null
          ? InkWell(
              highlightColor: Colors.transparent,
              radius: 0.0,
              onTap: rightBClickEvent,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: rightBImage,
              ),
            )
          : const SizedBox(),

      //文本展示，默认文本内容是在最右边，所以选择B
      rightTitle != null
          ? InkWell(
              highlightColor: Colors.transparent,
              radius: 0.0,
              onTap: rightBClickEvent,
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                alignment: Alignment.center,
                child: Text(rightTitle,
                    style: TextStyle(
                        fontSize: rightTitleSize, color: rightTitleColor)),
              ),
            )
          : const SizedBox(),
    ],
  );
}
