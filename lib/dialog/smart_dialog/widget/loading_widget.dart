import 'package:flutter/material.dart';

///描述:默认加载loading
///功能介绍:默认loading
///创建者:翁益亨
///创建日期:2022/7/18 18:52
class LoadingView extends StatelessWidget {

  final String msg;

  const LoadingView(this.msg,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.7),
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,//设置高度包裹内容
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //占位动画的loading
            CircularProgressIndicator(strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Colors.white),),
            SizedBox(height: 10,),
            //展示的文本内容
            Text(msg,style: TextStyle(fontSize: 14,color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
