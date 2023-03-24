import 'package:flutter/material.dart';

///描述:统一管理所有弹窗的展示
///功能介绍:统一管理所有弹窗的展示
///创建者:翁益亨
///创建日期:2022/7/11 10:45

///点击的回调数据返回
typedef SubmitCallBack = void Function(dynamic result);
typedef CancelCallBack = void Function();

///后续自定义展示浮窗在这里声明即可

//显示底部的浮窗
void showModalBottomSheetDialog(BuildContext context,Widget showContent,{maxHeight}) async{
  //isDismissible:false 点击外部区域不可收起
  showModalBottomSheet(context: context, builder: (context){
    return maxHeight!=null?ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight),child: showContent,):showContent;
  });
}