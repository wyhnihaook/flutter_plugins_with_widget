///描述:选择器数据转换器
///功能介绍:将外部数据转化为自身的数据结构，默认所有的key都对应一个value（code）
///创建者:翁益亨
///创建日期:2022/7/8 15:26

//抽象类实现，用于解耦当前适配选择器数据
abstract class PickerDataAdapter {
  List<dynamic> convertData(List<dynamic> listData);
}

//返回的数据内容处理
class PickerResult {
  //当前选择的内容选择，目前最多三级，后续按需处理
  String primaryName = '';

  String secondaryName = '';

  String tertiaryName = '';

  //每一个数据对应的value/code
  String primaryCode = '';

  String secondaryCode = '';

  String tertiaryCode = '';

  //当前是否存在子容器数据，多级联动所需
  List childList = [];

  PickerResult({
    this.primaryName = '',
    this.secondaryName = '',
    this.tertiaryName = '',
    this.primaryCode = '',
    this.secondaryCode = '',
    this.tertiaryCode = '',
    this.childList = const [],
  });

  //从数据结构进行解析，从数据源中同步数据
  PickerResult.fromJson(Map<String, dynamic> json,List<String> keys,List<String> values) {
    primaryName = json[keys[0]];
    if(keys.length>1){
      secondaryName = json[keys[1]];
    }
    if(keys.length>2){
      tertiaryName = json[keys[2]];
    }

    primaryCode = json[values[0]];
    if(values.length>1){
      secondaryCode = json[values[1]];
    }
    if(values.length>2){
      tertiaryCode = json[values[2]];
    }
  }

  @override
  toString(){
    return "$primaryName : $primaryCode ,$secondaryName : $secondaryCode,$tertiaryName : $tertiaryCode childLength :${childList.length}";
  }

}
