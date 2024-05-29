import 'package:flutter/material.dart';

///描述:选择/展示框样式
///功能介绍:界面水平排版显示选择框内容。例如：男、女 选择，是、否 选择
///创建者:翁益亨
///创建日期:2024/4/9 15:36

//选择之后的回调，同步内部信息
typedef CheckCallBack = Function(dynamic item); //选中的item回调

class SelectionBoxDisplayWidget extends StatefulWidget {
  //默认组件高度
  final double height;

  //标题相关
  final String title;
  final Color titleColor;
  final double titleFontSize;

  //显示相关
  final List<dynamic> contentList;
  final Color contentColor;
  final double contentFontSize;

  //背景设置
  final Color backgroundColor;

  //设置底部line显示与否,默认显示
  final bool showBottomLine;

  //选中回调
  final CheckCallBack? checkCallBack;

  //默认选择的角标
  final int checkIndex;

  //是否需要锁定当前另一个不可选中，默认可选中。用于当前锁定选项
  final bool isNeedLockOther;

  //是否是必填项。显示选项一般都有默认值并且不能取消，显示必选
  final bool isNecessary ;

  //底部下划线距左边距，默认0
  final double lineToLeft;

  //底部下划线距右边距，默认0
  final double lineToRight;

  //分割线的高度
  final double lineHeight;

  //分割线颜色
  final Color lineColor;

  //整体的高度由当前内边距+字体高度，默认边距信息
  final List<double> containerMargin;

  //标题文本的尺寸
  final double titleSize;

  //选项边框内容相关设置

  //选中的边框和字体颜色
  final Color checkColor;

  //未选中的边框
  final Color unCheckColor;

  //未选中的字体颜色
  final Color unCheckContentColor;

  //尺寸容器宽高
  final double checkContainerWidth;
  final double checkContainerHeight;

  //圆角设置
  final double checkContainerRadius;

  //锁定的背景色
  final Color lockBackgroundColor;
  //锁定的字体颜色
  final Color lockContentColor;

  //选项字体尺寸
  final double checkContentSize;


  const SelectionBoxDisplayWidget({
    super.key,
    required this.title, //设置为必填  = "性别"
    required this.contentList, //设置为必填= const [{'id':'1','title':'男'}, {'id':'2','title':'女'}]
    this.height = 50,
    this.checkColor = const Color(0xFF7C75FF),
    this.unCheckColor = const Color(0xFFDDDDDD),
    this.checkContainerWidth = 60,
    this.checkContainerHeight = 26,
    this.checkContainerRadius = 3,
    this.checkContentSize = 14,
    this.lockContentColor = const Color(0XFFABABAB),
    this.lockBackgroundColor = const Color(0XFFFAFAFA),
    this.unCheckContentColor = const Color(0XFF333333),
    this.titleColor = const Color(0xFF333333),
    this.titleFontSize = 14,
    this.contentColor = const Color(0xFF323233),
    this.contentFontSize = 14,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.showBottomLine = true,
    this.checkCallBack,
    this.checkIndex = 0,
    this.isNeedLockOther = false,
    this.isNecessary = true,
    this.lineToLeft = 0,
    this.lineToRight = 0,
    this.lineHeight = 0.5,
    this.lineColor = const Color(0xFFE9E9E9),
    this.containerMargin = const [16, 16, 40, 16],
    this.titleSize = 14,
  });

  @override
  State<SelectionBoxDisplayWidget> createState() =>
      _SelectionBoxDisplayWidgetState();
}

class _SelectionBoxDisplayWidgetState extends State<SelectionBoxDisplayWidget> {
  //默认选中的角标，当前传递上传的id信息，从contentList中同步
  late String checkId;

  late bool isNeedLockOther;

  @override
  void initState() {
    super.initState();
    checkId = widget.checkIndex == -1 ? '-1': widget.contentList[widget.checkIndex]['id'];

    isNeedLockOther = widget.isNeedLockOther;
  }

  @override
  void didUpdateWidget(SelectionBoxDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    //刷新当前默认选项
    checkId = widget.contentList[widget.checkIndex]['id'];

    isNeedLockOther = widget.isNeedLockOther;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  //存在图片时，居右尺寸减小
                    padding: EdgeInsets.fromLTRB(
                        widget.containerMargin[0],
                        widget.containerMargin[1],
                        widget.containerMargin[2],
                        widget.containerMargin[3]),
                    child: RichText(
                      text: TextSpan(
                          text: widget.title,
                          style: TextStyle(
                              fontSize: widget.titleSize,
                              color: widget.titleColor),
                          children: [
                            TextSpan(text:  widget.isNecessary?" *":"",style: TextStyle(fontSize: 14,color: Color(0XFFE13737)))
                          ]
                      ),
                    )
                ),
                //让中间展开
                const Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      ...widget.contentList
                          .map((e) => _buildContentList(e))
                          .toList()
                    ],
                  ),
                )
              ],
            ),
          ),
          widget.showBottomLine
              ?  Divider(
            height: widget.lineHeight,
            indent: widget.lineToLeft,
            endIndent: widget.lineToRight,
            color: widget.lineColor,
            thickness: widget.lineHeight,
          )
              : const SizedBox(),
        ],
      ),
    );
  }

  //选项卡渲染内容
  Widget _buildContentList(dynamic item) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          if(checkId == '-1'){
            //默认初始化时，还没有网络数据填充时，点击无反应
            return ;
          }
          if (checkId == item['id']) {
            return;
          }

          //当前不是当前选中，并且锁定之前的内容，不处理点击事件
          if(isNeedLockOther){
            return;
          }

          setState(() {
            checkId = item['id'];
          });

          if (widget.checkCallBack != null) {
            widget.checkCallBack!(item);
          }
        },

      // checkId == item['id']
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            width: widget.checkContainerWidth,
            height:widget.checkContainerHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                  color: checkId == item['id'] ? widget.checkColor : widget.unCheckColor,
                  width: 0.5),
              borderRadius: BorderRadius.circular(widget.checkContainerRadius),
              color: checkId != item['id']&&isNeedLockOther?widget.lockBackgroundColor:Colors.transparent,
            ),
            child: Text(
              item['title'],
              style: TextStyle(
                  fontSize: widget.checkContentSize,
                  color:
                  checkId == item['id'] ? widget.checkColor : (checkId != item['id']&&isNeedLockOther?widget.lockContentColor:widget.unCheckContentColor)),
            ),
          ),
        ),
      ),
    );
  }
}
