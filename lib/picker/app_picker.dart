import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widget/dialog/show_dialog.dart';
import 'package:widget/picker/picker_data_adapter.dart';
import 'package:widget/util/const_util.dart';

import '../custom_widget/picker_overlay_line.dart';
import '../util/gradient_util.dart';
import '../wrap_view/offstage_view.dart';

///描述:选择器
///功能介绍:单/多联动选择器
///创建者:翁益亨
///创建日期:2022/7/7 16:27
enum PickerType {
  primaryPicker, //一级选择器
  secondaryPicker, //二级选择器
  threeStagePicker, //三级选择器
}

enum PickerAdapterType {
  normal,//普通模式，没有任何额外操作
  birthday,//生日模式，额外操作：跟随原有的角标进行适配,一级二级滚动都不会影响后面一级，选择器会默认选中能匹配的数据，不能匹配就选中最后一个
  area,//地区模式，暂无
}

//滚动停止后的回调
typedef OnChangeListener = Function(String date);

class PickerView extends StatefulWidget {
  ///必填参数

  //当前列表内容传递,通过解析内部数据进行多级联动
  final List<dynamic> listData;

  ///非必填参数

  //当前标题是否需要展示，用来兼容app_tab_picker.dart文件的组合使用，默认展示
  final bool isVisibleTitle;

  //当前默认选中的数据结构，使用展示页面的key来匹配
  final List<String> defaultPickerData;

  //回调方法
  final SubmitCallBack? submitCallBack;

  final CancelCallBack? cancelCallBack;

  final OnChangeListener? onChangeListener;

  //是否需要选择器渐变,默认需要
  final bool needOcclusion;

  //当前选择item与默认的放大倍数
  final double magnification;

  //普通文本样式
  final TextStyle textStyle;

  //主题色
  final Color backgroundColor;

  //选中item覆盖的组件信息
  final Widget selectionOverlay;

  //每个数据的行高信息
  final double itemExtent;

  //内容高度
  final double contentHeight;

  //当前操作栏的高度
  final double titleBarHeight;

  //左侧操作文字内容、尺寸、颜色
  final String titleBarLeftContent;

  final double titleBarLeftContentSize;

  final Color titleBarLeftContentColor;

  //右侧操作文字内容、尺寸、颜色
  final String titleBarRightContent;

  final double titleBarRightContentSize;

  final Color titleBarRightContentColor;

  //中间title文字内容、尺寸、颜色
  final String titleBarCenterContent;

  final double titleBarCenterContentSize;

  final Color titleBarCenterContentColor;

  //顶部容器边缘处理
  final BoxDecoration titleBarBoxDecoration;

  //是否需要手动退出
  final bool autoPop;

  //选择适配类型
  final PickerAdapterType pickerAdapterType;

  const PickerView(this.listData,
      {this.contentHeight = 251,
        this.autoPop = true,
        this.pickerAdapterType = PickerAdapterType.normal,
        this.titleBarHeight = 48,
      this.needOcclusion = true,
      this.isVisibleTitle = true,
      this.magnification = 1.2,
      this.defaultPickerData = const [],
      this.submitCallBack,
      this.cancelCallBack,
      this.onChangeListener,
      this.textStyle = const TextStyle(fontSize: 15, color: Color(0XFF323233)),
      this.backgroundColor = Colors.white,
      this.titleBarLeftContent = "取消",
      this.titleBarLeftContentSize = 14,
      this.itemExtent = 38,
      this.titleBarLeftContentColor = const Color(0xFFB3B3B3),
      this.titleBarCenterContent = "",
      this.titleBarCenterContentSize = 16,
      this.titleBarCenterContentColor = const Color(0xFF333333),
      this.titleBarRightContent = "确定",
      this.titleBarRightContentSize = 14,
      this.titleBarRightContentColor = const Color(0xFF776FFF),
      this.selectionOverlay = const PickerOverlayLineView(),
      this.titleBarBoxDecoration = const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      Key? key})
      : super(key: key);

  @override
  State<PickerView> createState() => PickerSelectorViewState();
}

class PickerSelectorViewState extends State<PickerView> {
  //滚动监听器
  late FixedExtentScrollController firstExtentScrollController;
  late FixedExtentScrollController secondExtentScrollController;
  late FixedExtentScrollController thirdExtentScrollController;

  int firstDefaultPickerIndex = 0; //默认第一个角标选中的内容
  int secondDefaultPickerIndex = 0; //默认第二个角标选中的内容
  int thirdDefaultPickerIndex = 0; //默认第三个角标选中的内容

  //默认最高级为三级联动
  List<String> firstList = [];

  //二级通过一级唯一标识码确定刷新
  Map<String, List<String>> secondList = {};

  //三级通过二级唯一标识码确定刷新
  Map<String, List<String>> thirdList = {};

  List<int> linkageLength = [];

  //切换时记录的数据，存储之前角标内容，按需求匹配数据结构
  List<String> switchLinkList = [];

  @override
  void initState() {
    super.initState();
    print("初始化");
    //解析数据源，进行数据处理，默认最多处理三级数据
    //判断当前的列表匹配的key
    _matchShowData("", widget.listData, 0);

    //记录当前选中的默认信息，每次切换的时候，记录选中的结果code数据
    if(firstList.isNotEmpty){
      switchLinkList.add( widget.listData[firstDefaultPickerIndex].primaryCode);
    }

    if(secondList.isNotEmpty){
      switchLinkList.add(widget.listData[firstDefaultPickerIndex].childList[secondDefaultPickerIndex].primaryCode);
    }

    if(thirdList.isNotEmpty){
      switchLinkList.add( widget.listData[firstDefaultPickerIndex].childList[secondDefaultPickerIndex].childList[thirdDefaultPickerIndex].primaryCode);
    }

    firstExtentScrollController =
        FixedExtentScrollController(initialItem: firstDefaultPickerIndex);

    if (secondList.isNotEmpty) {
      secondExtentScrollController =
          FixedExtentScrollController(initialItem: secondDefaultPickerIndex);
    }

    if (thirdList.isNotEmpty) {
      thirdExtentScrollController =
          FixedExtentScrollController(initialItem: thirdDefaultPickerIndex);
    }
  }

  @override
  void dispose() {
    firstExtentScrollController.dispose();

    if (secondList.isNotEmpty) {
      secondExtentScrollController.dispose();
    }

    if (thirdList.isNotEmpty) {
      thirdExtentScrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.isVisibleTitle ? _titleView():const SizedBox(),
          _contentView(),
        ],
      ),
    );
  }

  //顶部操作标题栏
  _titleView() {
    return Container(
      height: widget.titleBarHeight,
      decoration: widget.titleBarBoxDecoration,
      child: Row(
        //居于最左侧和最右侧，中间占位最多
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            highlightColor: Colors.transparent,
            radius: 0.0,
            onTap: () {
              if (widget.cancelCallBack != null) {
                widget.cancelCallBack!();
              }

              if(widget.autoPop){
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding:const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                widget.titleBarLeftContent,
                style: TextStyle(
                    fontSize: widget.titleBarLeftContentSize,
                    color: widget.titleBarLeftContentColor),
              ),
            ),
          ),
          Text(
            widget.titleBarCenterContent,
            style: TextStyle(
                fontSize: widget.titleBarCenterContentSize,
                color: widget.titleBarCenterContentColor),
          ),
          InkWell(
            highlightColor: Colors.transparent,
            radius: 0.0,
            onTap: () {
              //获取当前选择的内容
              PickerResult pickerResult = getResult();

              //返回数据结构

              if (widget.submitCallBack != null) {
                widget.submitCallBack!(pickerResult);
              }

              if(widget.autoPop){
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                widget.titleBarRightContent,
                style: TextStyle(
                    fontSize: widget.titleBarRightContentSize,
                    color: widget.titleBarRightContentColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  //底部显示内容组件
  _contentView() {
    return Container(
      color: widget.backgroundColor,
      height: widget.contentHeight,
      child: Stack(
        children: [
          Row(
            children: linkageLength
                .map((e) => Expanded(child: _childPickerView(e)))
                .toList(),
          ),
          //居中分割线添加
          Center(
            child: widget.selectionOverlay,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            //将手势由下一个接受的组件处理
            child: _gradientOcclusion(true),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            //将手势由下一个接受的组件处理
            child: _gradientOcclusion(false),
          )
        ],
      ),
    );
  }

  //子容器的选择功能
  _childPickerView(int index) {
    return SizedBox(
      child: CupertinoPicker(
        diameterRatio: 3.5,
        //是圆筒直径和主轴渲染窗口的尺寸的比,如果是垂直方向，主轴渲染窗口的尺寸是ListWheelScrollView的高。diameterRatio越小表示圆筒越圆
        squeeze: 1,
        //显示的个数》高度为100，itemExtent每一个控件为20，那么squeeze为1的时候就为平均100/20*1=5等分   2的时候就是 100/20*2=10等分
        looping: false,
        //是否需要循环，默认false
        useMagnifier: true,
        //是否放大镜与否，配合magnification使用
        magnification: widget.magnification,
        //当前选中的item与其他item的放大倍数
        selectionOverlay: const SizedBox(),
        //处理当前的默认占位数据，多级会出现分层现象
        //遮盖再选中字体上的组件样式
        scrollController: index == 0
            ? firstExtentScrollController
            : (index == 1
                ? secondExtentScrollController
                : thirdExtentScrollController),
        itemExtent: widget.itemExtent,
        //中间一行聚焦行高
        onSelectedItemChanged: (int value) {
          //选择器切换之后要将联动的数据重置
          //重置当前需要联动数据
          if (index == 0) {
            switchLinkList[0] = widget.listData[ firstExtentScrollController.selectedItem].primaryCode;

            if (secondList.isNotEmpty) {
              if(widget.pickerAdapterType!=PickerAdapterType.birthday){
                secondExtentScrollController.jumpToItem(0);
              }else{
                //生日时，修改年的时候同步修改月日，匹配
                if(thirdList.isNotEmpty){
                  _dealBirthdayYearRange();
                }
              }
            }
          }

          if (index == 0 || index == 1) {
            if (thirdList.isNotEmpty) {
              if(widget.pickerAdapterType!=PickerAdapterType.birthday) {
                thirdExtentScrollController.jumpToItem(0);
              }else{
                //单独修改月的情况只做数据同步
              }
            }
          }

          if(index == 1){
            switchLinkList[1] = widget.listData[firstExtentScrollController.selectedItem].childList[secondExtentScrollController.selectedItem].primaryCode;
          }

          if(index == 2){
            switchLinkList[2] = widget.listData[firstExtentScrollController.selectedItem].childList[secondExtentScrollController.selectedItem].childList[thirdExtentScrollController.selectedItem].primaryCode;
          }

          setState(() {});

          //滚动停止后的回调
          widget.onChangeListener?.call("${switchLinkList[0]}-${switchLinkList[1]}-${switchLinkList[2]}");
        },
        children: index == 0
            ? firstList.map((e) => _textView(e)).toList()
            : (index == 1
                ? secondList[firstList[
                        firstExtentScrollController.positions.isEmpty
                            ? firstDefaultPickerIndex
                            : firstExtentScrollController.selectedItem]]!
                    .map((e) => _textView(e))
                    .toList()
                :
                //参考_matchShowData中处理的thirdList数据结构的key值，两边统一即可
                thirdList[
                        "${firstList[firstExtentScrollController.positions.isEmpty ? firstDefaultPickerIndex : firstExtentScrollController.selectedItem]} - ${secondList[firstList[firstExtentScrollController.positions.isEmpty ? firstDefaultPickerIndex : firstExtentScrollController.selectedItem]]![secondExtentScrollController.positions.isEmpty ? secondDefaultPickerIndex : secondExtentScrollController.selectedItem]}"]!
                    .map((e) => _textView(e))
                    .toList()),
      ),
    );
  }

  ///处理年份范围
  _dealBirthdayYearRange(){

    //问题，切换到最早的年月日日期，定位到第一个数据，滚动年份之后，开始选择日期信息，选择完毕之后发现可变高度只有之前的高度，导致会走onSelectedItemChanged的回调。保存最大高度能定位的坐标
    //例如要调整到8月19.角标对应7-18，但是之前只显示8-12月 19-31号，不够角标尺寸，只能滚动最大滚动区域5（8到12月五个月角标）月份13（19-31总共13天）号
    //每次切换都是遗留的上一个变动的列表的高度。比如最后只有十条数据，那么高度就为itemExtent*10。这就导致当前的高度无法撑开，致使锚定错误
    //源码解析：先执行list_wheel_scroll_view.dart的413行copyWith方法 再执行重新计算方法 scroll_position.dart的applyContentDimensions方法，最大适配高度重新计算
    //解决思路：由于滚动回调是同步的，这里要在jumpToItem方法执行完毕后，同步switchLinkList真实数据一次，避免在回调中因为高度没有及时同步导致一次错误的数据，只有在生日切换需要保留状态时使用


    //判断月份是否符合
    //从数据结构中获取数据
    String monthCode = switchLinkList[1];//获取原有的年份code，匹配最新年份是否存在对应的月信息

    String dayCode = switchLinkList[2];//获取原有的年份code，匹配最新年份是否存在对应的月信息

    //选中之后的首页信息处理
    int firstIndex = firstExtentScrollController.selectedItem;
    //剩余的数据从对应的列表中获取
    //默认都没有匹配到月日
    bool haveMatchMonth = false;
    int matchMonthIndex = 0;//匹配到月的角标
    bool haveMatchDay = false;

    for(int i = 0;i< widget.listData[firstIndex].childList.length;i++){
      PickerResult secondItem = widget.listData[firstIndex].childList[i];
      if(secondItem.primaryCode  == monthCode){
        //在当前切换后的新年份中匹配显示角标
        matchMonthIndex = i;

        if(secondExtentScrollController.selectedItem!=i){
          //跳转回调方法为同步方法，执行jumpToItem后，先执行对应回调，再往下执行
          //拉到最上层的数据之后，向下调整的时候
          secondExtentScrollController.jumpToItem(matchMonthIndex);

          //兼容上述错误情况，同步一次正确数据
          switchLinkList[1] = widget.listData[firstIndex].childList[i].primaryCode;
        }

        haveMatchMonth = true;
        break;
      }
    }

    if(haveMatchMonth){
      for(int i = 0;i< widget.listData[firstIndex].childList[matchMonthIndex].childList.length;i++){
        PickerResult thirdItem = widget.listData[firstIndex].childList[matchMonthIndex].childList[i];

        if(thirdItem.primaryCode  == dayCode){
          //在当前切换后的新年份中匹配显示角标
          if(thirdExtentScrollController.selectedItem!=i){
            thirdExtentScrollController.jumpToItem(i);

            //兼容上述错误情况，同步一次正确数据
            switchLinkList[2] = widget.listData[firstIndex].childList[matchMonthIndex].childList[i].primaryCode;
          }

          haveMatchDay = true;
          break;
        }
      }
    }else{
      //如果月没有匹配到
      //如果是最前面，定位最前面，如果是最后面，定位到最后面
      if((widget.listData.length-1) == firstIndex){
        //最后一条数据
        secondExtentScrollController.jumpToItem(widget.listData[firstIndex].childList.length-1);
        thirdExtentScrollController.jumpToItem(widget.listData[firstIndex].childList[widget.listData[firstIndex].childList.length-1].childList.length-1);

        switchLinkList[1] = widget.listData[firstIndex].childList[widget.listData[firstIndex].childList.length-1].primaryCode;
        switchLinkList[2] = widget.listData[firstIndex].childList[widget.listData[firstIndex].childList.length-1].childList[
        widget.listData[firstIndex].childList[widget.listData[firstIndex].childList.length-1].childList.length-1].primaryCode;
      }else if(firstIndex == 0){
        //最前一条数据
        secondExtentScrollController.jumpToItem(0);
        thirdExtentScrollController.jumpToItem(0);

        switchLinkList[1] = widget.listData[firstIndex].childList[0].primaryCode;
        switchLinkList[2] = widget.listData[firstIndex].childList[0].childList[0].primaryCode;
      }
    }

    //匹配到月没有匹配到日的情况
    if(!haveMatchDay&&haveMatchMonth){
      //如果日没有匹配到
      if((widget.listData.length-1) == firstIndex){
        //最后一条数据
        thirdExtentScrollController.jumpToItem(widget.listData[firstIndex].childList[matchMonthIndex].childList.length-1);

        switchLinkList[2] = widget.listData[firstIndex].childList[widget.listData[firstIndex].childList.length-1].childList[
        widget.listData[firstIndex].childList[widget.listData[firstIndex].childList.length-1].childList.length-1].primaryCode;
      }else if(firstIndex == 0){
        //最前一条数据
        thirdExtentScrollController.jumpToItem(0);
        switchLinkList[2] = widget.listData[firstIndex].childList[0].childList[0].primaryCode;
      }else{
        //其他情况自适应定位，理论上来说只有第一个和最后一个有范围，其他日期应该是全年的范围
      }
    }

  }

  //遮挡的View
  _gradientOcclusion(bool isTop) {
    return IgnorePointer(
      //将手势由下一个接受的组件处理
      child: OffstageView(
        isVisible: widget.needOcclusion,
        Container(
          decoration: BoxDecoration(
            gradient: GradientUtil.getLinearGradient(
              [const Color(0X00FFFFFF), Colors.white.withOpacity(0.88)],
              begin: isTop
                  ? AlignmentDirectional.bottomCenter
                  : AlignmentDirectional.topCenter,
              end: isTop
                  ? AlignmentDirectional.topCenter
                  : AlignmentDirectional.bottomCenter,
            ),
          ),
          //这里的尺寸是整个高度-中间的内容=剩余内容 （再-10（兼容尺寸不让横线遮挡）） / 2 = 上半/下半部分
          height: (widget.contentHeight - widget.itemExtent) / 2,
        ),
      ),
    );
  }

  //当前显示的内容Text内容
  Widget _textView(String text) {
    return Center(
      child: Text(
        text,
        style: widget.textStyle,
        maxLines: 1,
      ),
    );
  }

  //遍历当前数据，进行展示数据的匹配（这里使用显示名字做标识，如果需要使用唯一code码，需要改造一下数据结构，目前不需要/理论上显示的每级目录都是唯一内容）
  void _matchShowData(String name, List listData, int index) {
    if (!linkageLength.contains(index)) {
      //只是用来记录层级
      linkageLength.add(index);
    }

    for (dynamic item in listData) {
      //这里要使用角标
      if (item is PickerResult) {
        //首先进行当前数据赋值
        if (index == 0) {
          firstList.add(item.primaryName);
        } else if (index == 1) {
          //要使用firstList中的key作为标准处理，其实使用之前的index角标即可
          secondList[name] ??= [];
          secondList[name]!.add(item.primaryName);
        } else {
          //要使用firstList结合secondList中的key作为键处理
          thirdList[name] ??= [];
          thirdList[name]!.add(item.primaryName);
        }

        if (item.childList.isNotEmpty) {
          //这里的存储key，每一级都要添加，避免二级重复导致三级数据结构问题（日历问题）
          _matchShowData(
              index == 0 ? item.primaryName : ("$name - ${item.primaryName}"),
              item.childList,
              index + 1);
        }
      }
    }

    if (index == 0) {
      //这里全部遍历完毕，进行数据匹配
      //判断是否存在默认选中的内容
      if (widget.defaultPickerData.isNotEmpty &&
          (widget.defaultPickerData.length == linkageLength.length)) {
        //不为空的情况，匹配当前选中的内容
        for (int dataIndex = 0;
            dataIndex < widget.defaultPickerData.length;
            dataIndex++) {
          if (dataIndex == 0) {
            for (int firstIndex = 0;
                firstIndex < firstList.length;
                firstIndex++) {
              if (firstList[firstIndex] ==
                  widget.defaultPickerData[dataIndex]) {
                firstDefaultPickerIndex = firstIndex;
                break;
              }
            }
          } else if (dataIndex == 1) {
            List secondListData =
                secondList[firstList[firstDefaultPickerIndex]] ?? [];
            for (int secondIndex = 0;
                secondIndex < secondListData.length;
                secondIndex++) {
              if (secondListData[secondIndex] ==
                  widget.defaultPickerData[dataIndex]) {
                secondDefaultPickerIndex = secondIndex;
                break;
              }
            }
          } else {
            List thirdListData = thirdList[
                    "${firstList[firstDefaultPickerIndex]} - ${secondList[firstList[firstDefaultPickerIndex]]![secondDefaultPickerIndex]}"] ??
                [];
            for (int thirdIndex = 0;
                thirdIndex < thirdListData.length;
                thirdIndex++) {
              if (thirdListData[thirdIndex] ==
                  widget.defaultPickerData[dataIndex]) {
                thirdDefaultPickerIndex = thirdIndex;
                break;
              }
            }
          }
        }
      }
    }
  }

  //外部调用获取当前选项的内容
  PickerResult getResult(){
    PickerResult pickerResult = PickerResult();
    int firstIndex = firstExtentScrollController.selectedItem;

    pickerResult.primaryName =
        widget.listData[firstIndex].primaryName;
    pickerResult.primaryCode =
        widget.listData[firstIndex].primaryCode;

    if (linkageLength.length > 1) {
      int secondIndex = secondExtentScrollController.selectedItem;

      pickerResult.secondaryName = widget
          .listData[firstIndex].childList[secondIndex].primaryName;
      pickerResult.secondaryCode = widget
          .listData[firstIndex].childList[secondIndex].primaryCode;

      if (linkageLength.length > 2) {
        int thirdIndex = thirdExtentScrollController.selectedItem;

        pickerResult.tertiaryName = widget.listData[firstIndex]
            .childList[secondIndex].childList[thirdIndex].primaryName;
        pickerResult.tertiaryCode = widget.listData[firstIndex]
            .childList[secondIndex].childList[thirdIndex].primaryCode;
      }
    }

    return pickerResult;
  }
}
