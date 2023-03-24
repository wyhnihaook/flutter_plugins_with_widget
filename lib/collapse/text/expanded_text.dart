import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:widget/collapse/text/text_collapse_config.dart';
import 'package:widget/util/text_util.dart';

///描述:可扩展文本
///功能介绍:提供展开/收起功能的文本内容
///创建者:翁益亨
///创建日期:2022/8/16 14:46
typedef ExpandCallBack = Function(bool isExpanded);

class ExpandedText extends StatefulWidget {
  ///文本配置项，统一管理内部渲染
  final TextCollapseConfig textCollapseConfig;

  final ExpandCallBack expandCallBack;

  ///默认匹配一个字的尺寸，兼容大多数的字体尺寸，英文、中文等
  final String matchText;

  const ExpandedText(
      {required this.textCollapseConfig,required this.expandCallBack, this.matchText = '是', Key? key})
      : super(key: key);

  @override
  _ExpandedTextState createState() => _ExpandedTextState();
}

class _ExpandedTextState extends State<ExpandedText> {
  late bool isExpanded; //是否已经展开状态

  late String contentText;

  late TextStyle contentTextStyle;

  late String expandText;

  late String collapseText;

  late TextStyle operatorTextStyle;

  late Widget? expandContainer;

  late Widget? collapseContainer;

  late int maxLines;

  late Size singleTextSize;

  int seatLines = 0;

  //限制内容显示的最大宽度
  double maxWidth = 0;

  //固定占位的内容...
  String ellipsis = '.....';

  //用于查找最接近数据的内容
  late int contentLength;

  //预先加载文本内容
  late Size expandSize;

  late Size collapseSize;

  //positioned组件展开后跟随的left属性内容
  late double? followLeft;

  @override
  void initState() {
    super.initState();
    //初始化信息
    contentText = widget.textCollapseConfig.contentText;
    contentTextStyle = widget.textCollapseConfig.contentTextStyle;
    expandText = widget.textCollapseConfig.expandText;
    collapseText = widget.textCollapseConfig.collapseText;
    operatorTextStyle = widget.textCollapseConfig.operatorTextStyle;
    expandContainer = widget.textCollapseConfig.expandContainer;
    collapseContainer = widget.textCollapseConfig.collapseContainer;
    maxLines = widget.textCollapseConfig.maxLines;
    isExpanded = widget.textCollapseConfig.isExpanded;
    contentLength = widget.textCollapseConfig.contentText.length;
    //初始化两个文本尺寸
    if (expandContainer == null || collapseContainer == null) {
      expandSize = TextUtil.boundingTextSize(expandText, operatorTextStyle);
      collapseSize = TextUtil.boundingTextSize(collapseText, operatorTextStyle);
    } else {
      //存在组件，获取组件尺寸,直接通过数据属性进行初始化，理论上不关心高度，保证单行文本高度容器内容
      expandSize = Size(
          (expandContainer as Container).constraints?.maxWidth ?? 0,
          (expandContainer as Container).constraints?.maxHeight ?? 0);
      collapseSize = Size(
          (collapseContainer as Container).constraints?.maxWidth ?? 0,
          (collapseContainer as Container).constraints?.maxHeight ?? 0);
    }
  }

  ///计算文本内容相关
  bool initTextInfo(double maxWidth) {
    ///计算行数
    //1.获取当前容器展示的最大宽度
    this.maxWidth = maxWidth; //当前绘制的宽度设定

    //2.获取一个字符占用的高度
    singleTextSize =
        TextUtil.boundingTextSize(widget.matchText, contentTextStyle);

    //3.通过最大宽度获取对应的高度信息
    Size size = TextUtil.boundingTextSize(contentText, contentTextStyle,
        maxWidth: maxWidth);

    //4.获取当前显示完整需要占用的行数  ~/   ==  / .toInt()
    seatLines = size.height ~/ singleTextSize.height +
        (size.height % singleTextSize.height).toInt();

    //当前显示超过最大限度 返回true:目前超过限制的长度，展示内容/false:没有超过限制长度，应该直接显示完毕
    return seatLines > maxLines;
  }

  ///处理页面上显示的内容，处理超出的字符信息，采用二分法，查询最接近信息的内容
  ///返回默认收起需要截取的位置
  int calculationOverText(int targetIndex) {
    //执行该方法，一定是超出最大高度的文本内容
    //设置最大高度中显示的文本内容，要在文本内容后面留存对应展示的内容宽度
    int head = 0;
    int end = targetIndex;

    //需要将占位空间转化为字符串占位
    String seizeSeatContent = convertString();

    while (head <= end) {
      //获取最中间的数据
      int middle = (head + end) ~/ 2;
      Size size = TextUtil.boundingTextSize(
          contentText.substring(0, middle) + ellipsis + seizeSeatContent,
          contentTextStyle,
          maxWidth: maxWidth);

      if (size.height == maxLines * singleTextSize.height) {
        //当前显示内容填充内容已达最大显示高度
        //需要判断再添加一个字符是否会超出最大行，如果不会就继续向后检索，如果会就截断,说明符合输出内容
        Size sizeMatch = TextUtil.boundingTextSize(
            contentText.substring(0, middle) +
                ellipsis +
                seizeSeatContent +
                widget.matchText,
            contentTextStyle,
            maxWidth: maxWidth);

        if (sizeMatch.height > maxLines * singleTextSize.height) {
          break;
        } else {
          head = middle + 1;
        }
      } else if (size.height > maxLines * singleTextSize.height) {
        //已经超出原有范围，需要往前检索角标
        end = middle - 1;
      } else {
        //说明不足到最大高度，所以要向后检索内容
        head = middle + 1;
      }
    }

    return (head + end) ~/ 2;
  }

  ///判断是否在同一行能显示完全并且拼接收起功能
  bool judgeShowSameLine() {
    String seizeSeatContent = convertString();

    ///计算内容是否会换行
    Size normalSize = TextUtil.boundingTextSize(contentText, contentTextStyle,
        maxWidth: maxWidth);

    Size size = TextUtil.boundingTextSize(
        contentText + seizeSeatContent, contentTextStyle,
        maxWidth: maxWidth);

    if (normalSize.height != size.height) {
      return false;
    }

    //默认拼接后还是同一行
    return true;
  }

  ///宽度转换占位字符串<适配文字以及组件设定的限制宽度>
  String convertString() {
    int seizeSeat = 0;

    //展开时，显示收起标签。收起时，显示展开标签
    seizeSeat = (isExpanded ? collapseSize.width : expandSize.width) ~/
        singleTextSize.width;

    String seizeSeatContent = '';

    //重新定义占位的字符串，模拟空间占位
    for (int i = 0; i < seizeSeat; i++) {
      seizeSeatContent += widget.matchText;
    }

    return seizeSeatContent;
  }


  ///计算通过图标或者自定义占位同一行跟随的绝对定位的Positioned组件的left属性进行匹配
  ///只针组件对跟随的模式下计算内容
  void calcFollowLeft(){

    //获取文本拆分的最后一行和倒数第二行内容，拆出最后一行的全部内容，然后最后一行的宽度就是对应的left数据

    //从最后一个字符开始删除，每次删除之后都要计算一次高度，是否换行了，如果换行了就保留之前的角标开始检索

    //至少一行以上
    int boundaryIndex = 0;
    for(int i = contentLength;i>0;i--){

      Size calcSize = TextUtil.boundingTextSize(contentText.substring(0,i), contentTextStyle,
          maxWidth: maxWidth);

      if(seatLines==(calcSize.height ~/ singleTextSize.height +
          (calcSize.height % singleTextSize.height).toInt()+1)){
        //只有当前数据行数边界时处理
        print('follow = ${contentText.substring(0,i)}');
        boundaryIndex = i;
        break;
      }
    }

    //倒数两行切分的字符串，手动构建最后一行
    Size calcSize = TextUtil.boundingTextSize(contentText.substring(boundaryIndex), contentTextStyle,
        maxWidth: maxWidth);

    followLeft = calcSize.width;
    print("follow = $followLeft");
  }

  ///1.文本内容高度需要包裹内容显示，水平方向默认填充满容器的剩余空间
  ///2.计算当前的文本显示高度，计算出对应的行数
  ///3.判断是否超过显示上线，进行页面内容拼接

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        //获取当前组件的最大宽度尺寸。收到外界其他属性限制，例如：padding/margin

        bool overstep = initTextInfo(constraints.maxWidth);

        int endIndex = contentLength;

        bool haveContainer = (collapseContainer!=null&&expandContainer!=null);

        if (overstep) {

          if(!isExpanded){
            //收起时，才需要计算内容
            endIndex = calculationOverText(contentLength);
          }else{
            //展开后，如果存在组件，需要处理数据,跟随数据
            if(haveContainer){
              calcFollowLeft();
            }
          }
        }

        return overstep
            ? (isExpanded
                ?(haveContainer? _getLimitExpandedWithCollapse(contentText): _getLimitExpandedText(contentText))
                : (haveContainer?_getLimitTextWithExpand(contentText.substring(0, endIndex)):_getLimitText(contentText.substring(0, endIndex))))
            : _getNormalText();
      },
    );
  }

  ///普通全部显示完毕的情况
  Widget _getNormalText() {
    return Text(
      contentText,
      style: contentTextStyle,
    );
  }

  ///不需要显示完毕的情况
  Widget _getLimitText(String content) {
    //richText组装数据
    return RichText(
      text: TextSpan(text: '$content...', style: contentTextStyle, children: [
        TextSpan(
            text: expandText,
            style: operatorTextStyle,
            //设置文本点击事件
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                //点击事件回调
                setState(() {
                  //展开页面内容
                  isExpanded = true;
                  widget.expandCallBack.call(isExpanded);
                });
              })
      ]),
    );
  }

  ///提供收起功能的组件，需要额外判断最后显示的字符能否一次性全部显示下，如果不行，就换行显示
  Widget _getLimitExpandedText(String content) {
    //获取是否显示在同一行
    bool showSameLine = judgeShowSameLine();

    return RichText(
      text: TextSpan(text: content, style: contentTextStyle, children: [
        TextSpan(
            text: '${showSameLine ? '' : '\n'}$collapseText',
            style: operatorTextStyle,
            //设置文本点击事件
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                //点击事件回调
                setState(() {
                  //展开页面内容
                  isExpanded = false;
                  widget.expandCallBack.call(isExpanded);
                });
              })
      ]),
    );
  }

  ///如果存在组件信息，就使用stack结合Position绝对定位，设置到右下方位
  ///要换行的情况，就使用Column组件直接布局即可

  Widget _getLimitTextWithExpand(String content) {
    //richText组装数据
    return Stack(
      children: [
        Text('$content...', style: contentTextStyle),
        Positioned(
            right: 8,//默认跟随到最后
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  //展开页面内容
                  isExpanded = true;
                  widget.expandCallBack.call(isExpanded);
                });
              },
              child: expandContainer,
            )),
      ],
    );
  }

  Widget _getLimitExpandedWithCollapse(String content) {
    //获取是否显示在同一行
    bool showSameLine = judgeShowSameLine();

    return showSameLine?Stack(
      children: [
        Text(content, style: contentTextStyle),
        //同一行，需要跟随最后的宽度，计算出Positioned组件的left
        Positioned(
            left: followLeft??0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  //展开页面内容
                  isExpanded = false;
                  widget.expandCallBack.call(isExpanded);
                });
              },
              child: collapseContainer,
            )),
      ],
    ):Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(content, style: contentTextStyle),
        GestureDetector(
          onTap: () {
            setState(() {
              //展开页面内容
              isExpanded = false;
              widget.expandCallBack.call(isExpanded);
            });
          },
          child: collapseContainer,
        )
      ],
    );
  }
}
