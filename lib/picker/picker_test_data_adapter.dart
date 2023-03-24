import 'package:widget/picker/picker_data_adapter.dart';
import 'package:widget/util/date_util.dart';

///描述:当前模拟数据结构
///功能介绍:一级/二级/三级列表展示
///创建者:翁益亨
///创建日期:2022/7/8 16:31
class TestData extends PickerDataAdapter {
  List getAge() {
    List<String> ageList = [];
    for (int i = 0; i < 100; i++) {
      ageList.add("$i");
    }
    return convertData(ageList);
  }

  //当前返回的就是一个普通数据，这里做一次封装，用于后续统一处理
  //处理当前的数据结构并返回
  @override
  List convertData(List<dynamic> listData) {
    List list = [];
    for (String item in listData) {
      //处理完毕当前的内容之后进行返回
      list.add(PickerResult(primaryName: item, primaryCode: item + item));
    }

    return list;
  }
}

class TestData2 extends PickerDataAdapter {
  List getArea() {
    List<InsureAreaInfo> date = [];
    for (int i = 0; i < 20; i++) {
      InsureAreaInfo info = InsureAreaInfo(
          insureProvince: "$i 0000",
          insureProvinceName: "浙江省$i",
          cityList: i != 0
              ? [
                  CityListBean(insureCity: "120100 $i", insureCityName: "天津城区$i",areaList: [AreaListBean(insureArea: "666 $i",insureAreaName:  "$i 大门台"),
                    AreaListBean(insureArea: "888 $i",insureAreaName:  "$i 小门台")]),
                  CityListBean(insureCity: "220100 $i", insureCityName: "杭州城区$i")
                ]
              : []);

      date.add(info);
    }

    return convertData(date);
  }

  //当前返回的就是一个普通数据，这里做一次封装，用于后续统一处理
  //处理当前的数据结构并返回
  @override
  List convertData(List<dynamic> listData) {
    List list = [];
    for (InsureAreaInfo item in listData) {
      //处理完毕当前的内容之后进行返回

      if (item.cityList.isNotEmpty) {
        List<PickerResult> childResult = [];
        for (int i = 0; i < item.cityList.length; i++) {
          CityListBean cityListBean = item.cityList[i];

          List areaList = [];
          if(cityListBean.areaList.isEmpty){
            areaList.add(PickerResult(primaryCode: cityListBean.insureCity,primaryName: cityListBean.insureCityName));
          }else{
            for(AreaListBean areaListBean in cityListBean.areaList){
              areaList.add(PickerResult(primaryCode: areaListBean.insureArea,primaryName: areaListBean.insureAreaName));
            }
          }

          childResult.add(PickerResult(
              primaryName: cityListBean.insureCityName,
              primaryCode: cityListBean.insureCity,childList: areaList));
        }

        list.add(PickerResult(
            primaryName: item.insureProvinceName,
            primaryCode: item.insureProvince,
            childList: childResult));
      } else {
        list.add(PickerResult(
            primaryName: item.insureProvinceName,
            primaryCode: item.insureProvince,
            childList: [
              PickerResult(
                  primaryName: item.insureProvinceName,
                  primaryCode: item.insureProvince,childList: [PickerResult(primaryCode: item.insureProvince,primaryName: item.insureProvinceName)])
            ]));
      }
    }
    

    return list;
  }
}

//地区处理
class InsureAreaInfo {
  /**
   * insureProvince : 330000
   * insureProvinceName : 浙江省
   * cityList : [{"cityId":330000,"cityName":"浙江省"}]
   */

  String insureProvince = "";
  String insureProvinceName = "";
  List<CityListBean> cityList = [];

  InsureAreaInfo({
    this.insureProvince = '',
    this.insureProvinceName = '',
    this.cityList = const [],
  });
}

class CityListBean {
  /**
   * insureCity : 120100
   * insureCityName : 天津城区
   */

  String insureCity = "";
  String insureCityName = "";
  List<AreaListBean> areaList = [];

  CityListBean({this.insureCity = '', this.insureCityName = '',this.areaList = const [],});
}

class AreaListBean {
  /**
   * insureArea : 666666
   * insureAreaName : 大门台
   */

  String insureArea = "";
  String insureAreaName = "";

  AreaListBean({this.insureArea = '', this.insureAreaName = ''});
}

///年月日展示
class TestData3 extends PickerDataAdapter{

  List getDate() {
    List<int> date = [];
    //可以获取本地数据进行匹配
    //这里只需要统计年份区间即可，月日基本
    for (int i = 1960; i < 2050; i++) {
      date.add(i);
    }

    return convertData(date);
  }

  @override
  List convertData(List<dynamic> listData) {
    List list = [];
    for (int item in listData) {
      PickerResult pickerResultYear = PickerResult();
      pickerResultYear.primaryName = "$item年";
      pickerResultYear.primaryCode = "$item";

      //遍历子容器
      //每年都有12月份
      List listMonth = [];
      for(int i = 1;i<=12;i++){
        PickerResult pickerResultMonth = PickerResult();
        pickerResultMonth.primaryName = "$i月";
        pickerResultMonth.primaryCode = "$i";

        // List listDay = [];
        // for(int j = 1;j<= getMonth(item, i);j++){
        //   PickerResult pickerResultDay = PickerResult();
        //   pickerResultDay.primaryName = "$j日";
        //   pickerResultDay.primaryCode = "$j";
        //
        //   listDay.add(pickerResultDay);
        // }
        // pickerResultMonth.childList = listDay;

        listMonth.add(pickerResultMonth);
      }

      pickerResultYear.childList = listMonth;
      list.add(pickerResultYear);
    }

    return list;
  }



}
