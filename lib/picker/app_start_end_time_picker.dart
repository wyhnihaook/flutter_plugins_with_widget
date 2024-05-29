import 'package:flutter/material.dart';
import 'package:widget/picker/picker_date_data_adapter.dart';

import 'app_picker.dart';

///描述:时间选择器
///功能介绍:开始、结束时间选择返回
///创建者:翁益亨
///创建日期:2022/12/25 13:41
class PickerStartEndTimeView extends StatefulWidget {
  //控制时间选择器的总高度
  final double contentHeight;

  //时间选择器范围 通过Date().getDate(minYear:....)生成
  //开始时间结束时间范围最大最小设定
  final String minYear;
  final String minMonth;
  final String minDay;
  final String maxYear;
  final String maxMonth;
  final String maxDay;

  //默认选择的时间.["2020","1","1"]
  final List<String> defaultPickerData;

  //开始、结束时间设定
  final String startTime;
  final String endTime;

  //默认提示
  final String warnTips;

  //告警提示
  final String errorTips;

  //选择适配类型
  final PickerAdapterType pickerAdapterType;

  const PickerStartEndTimeView(
      {required this.minYear,
      required this.minMonth,
      required this.minDay,
      required this.maxYear,
      required this.maxMonth,
      required this.maxDay,
      required this.defaultPickerData,
      required this.startTime,
      required this.endTime,
        this.pickerAdapterType = PickerAdapterType.normal,
      this.contentHeight = 251,
      this.errorTips = "",
      this.warnTips = "",
      super.key});

  @override
  State<PickerStartEndTimeView> createState() => _PickerStartEndTimeViewState();
}

class _PickerStartEndTimeViewState extends State<PickerStartEndTimeView> {
  //提示对应信息，默认是正常的提示
  bool isError = false;

  //当前选中的角标。默认为0:表示开始时间。1:表示结束时间
  int checkIndex = 0;

  //时间从参数中同步一次.选中的时间同步
  late String startTime;
  late String endTime;

  late List rangeDateInfo;

  //默认选中的内容，初始化时，从外部同步。后续切换由startTime和endTime同步
  late List<String> defaultPickerData;

  @override
  void initState() {
    super.initState();

    rangeDateInfo = Date().getDate(
        minYear: widget.minYear,
        minMonth: widget.minMonth,
        minDay: widget.minDay,
        maxYear: widget.maxYear,
        maxMonth: widget.maxMonth,
        maxDay: widget.maxDay);
    //根据当前的时间范围设定
    //最大最小范围时间

    startTime = widget.startTime;
    endTime = widget.endTime;

    //默认选中的内容由当前是
    defaultPickerData = widget.defaultPickerData;
  }

  convertDate(int type) {
    List<String> time = [];

    if (type == 0) {
      //startTime同步
      time = startTime.split("-");
    } else if (type == 1) {
      //endTime同步
      time = endTime.split("-");
    }

    String year = "${time[0]}年";
    String month =
        "${(time[1].startsWith("0") ? time[1].substring(1) : time[1])}月";
    String day =
        "${(time[2].startsWith("0") ? time[2].substring(1) : time[2])}日";

    setState((){
      defaultPickerData = [year,month,day];
      print("defaultPickerData:$defaultPickerData");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 21,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  //判断当前选中是否是起始时间。如果是就返回。否则将存储的起始时间进行设定初始化
                  if (checkIndex == 0) {
                    return;
                  }

                  setState(() {
                    checkIndex = 0;
                    //根据startTime组合默认选中的内容
                    convertDate(checkIndex);
                  });
                },
                child: Container(
                  width: 154,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0XFFF2F1FF),
                      borderRadius: BorderRadius.circular(2)),
                  child: Text(startTime,
                      style: TextStyle(
                          color:
                              Color(checkIndex == 0 ? 0XFF776FFF : 0XFF333333),
                          fontSize: 14)),
                ),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11),
                  child: Text("至",
                      style:
                          TextStyle(fontSize: 14, color: Color(0XFF666666)))),
              GestureDetector(
                onTap: () {
                  //判断当前选中是否是起始时间。如果是就返回。否则将存储的起始时间进行设定初始化
                  if (checkIndex == 1) {
                    return;
                  }

                  setState(() {
                    checkIndex = 1;
                    //根据endTime组合默认选中的内容
                    convertDate(checkIndex);
                  });
                },
                child: Container(
                  width: 154,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0XFFF2F1FF),
                      borderRadius: BorderRadius.circular(2)),
                  child: Text(endTime,
                      style: TextStyle(
                          color:
                              Color(checkIndex == 1 ? 0XFF776FFF : 0XFF333333),
                          fontSize: 14)),
                ),
              )
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          //中间的提示信息
          Text(
            isError ? widget.errorTips : widget.warnTips,
            style: TextStyle(
                fontSize: 13, color: Color(isError ? 0XFFFF3B30 : 0XFFABABAB)),
          ),

          const SizedBox(
            height: 10,
          ),

          //开始、结束时间显示隐藏
          Offstage(
            offstage: checkIndex == 1,
            child: pickerView(),
          ),

          Offstage(
            offstage: checkIndex == 0,
            child: pickerView(),
          )
        ],
      ),
    );
  }


  pickerView(){
    //由于页面刷新之后，不会出发PickerView内部数据刷新，所以这里就使用两个PickerView。因为操作后不会互相影响
    return PickerView(
      contentHeight: widget.contentHeight,
      rangeDateInfo,
      pickerAdapterType: widget.pickerAdapterType,
      isVisibleTitle: false,
      submitCallBack: (dynamic result) {},
      defaultPickerData: defaultPickerData,
      onChangeListener: (String date) {
        //返回2023-6-8
        //自动补齐0
        List<String> time = date.split("-");
        String year = time[0];
        String month = time[1].length == 1 ? "0${time[1]}" : time[1];
        String day = time[2].length == 1 ? "0${time[2]}" : time[2];

        setState(() {
          if (checkIndex == 0) {
            startTime = "$year-$month-$day";
          } else if (checkIndex == 1) {
            endTime = "$year-$month-$day";
          }
        });
      },
    );
  }
}
