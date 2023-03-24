

import 'package:widget/picker/picker_data_adapter.dart';
import 'package:widget/util/date_util.dart';

///描述:生日适配器
///功能介绍:生日适配器
///创建者:翁益亨
///创建日期:2022/8/4 17:06
class Date extends PickerDataAdapter {

  late int minYear;
  late int maxYear;

  late int minMonth;
  late int minDay;

  late int maxMonth;
  late int maxDay;

  //可以设置最大最小的年份
  List getDate(
      {String minYear = '1960',String minMonth = '12',String minDay = '31',String maxYear = '2050',String maxMonth = '12',String maxDay = '11',}) {

    //传递的参数为分割之后的字符串类型,所以这里需要首先做一次转化


    this.minYear = int.parse(minYear);
    this.maxYear = int.parse(maxYear);
    this.minMonth = int.parse(minMonth.startsWith('0')?minMonth.substring(1):minMonth);
    this.minDay =  int.parse(minDay.startsWith('0')?minDay.substring(1):minDay);
    this.maxMonth = int.parse(maxMonth.startsWith('0')?maxMonth.substring(1):maxMonth);
    this.maxDay = int.parse(maxDay.startsWith('0')?maxDay.substring(1):maxDay);

    List<int> date = [];
    //可以获取本地数据进行匹配
    //这里只需要统计年份区间即可，月日基本
    for (int i = this.minYear; i <= this.maxYear; i++) {
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
      if (item == minYear) {
        //最小年份起始遍历数据
        for (int i = minMonth; i <= 12; i++) {
          PickerResult pickerResultMonth = PickerResult();
          pickerResultMonth.primaryName = "$i月";
          pickerResultMonth.primaryCode = "$i";

          List listDay = [];

          if (i == minMonth) {
            //起始的日期匹配
            for (int j = (getMonth(item, i) < minDay
                ? getMonth(item, i)
                : minDay); j <= getMonth(item, i); j++) {
              PickerResult pickerResultDay = PickerResult();
              pickerResultDay.primaryName = "$j日";
              pickerResultDay.primaryCode = "$j";

              listDay.add(pickerResultDay);
            }
          } else {
            for (int j = 1; j <= getMonth(item, i); j++) {
              PickerResult pickerResultDay = PickerResult();
              pickerResultDay.primaryName = "$j日";
              pickerResultDay.primaryCode = "$j";

              listDay.add(pickerResultDay);
            }
          }

          pickerResultMonth.childList = listDay;

          listMonth.add(pickerResultMonth);
        }
      } else if (item == maxYear) {
        //最大月份终止月份
        for (int i = 1; i <= maxMonth; i++) {
          PickerResult pickerResultMonth = PickerResult();
          pickerResultMonth.primaryName = "$i月";
          pickerResultMonth.primaryCode = "$i";

          List listDay = [];
          if (i == maxMonth) {
            print("${(getMonth(item, i) < maxDay
                ? getMonth(item, i)
                : maxDay)} 最高日期");
            for (int j = 1; j <= (getMonth(item, i) < maxDay
                ? getMonth(item, i)
                : maxDay); j++) {
              PickerResult pickerResultDay = PickerResult();
              pickerResultDay.primaryName = "$j日";
              pickerResultDay.primaryCode = "$j";

              listDay.add(pickerResultDay);
            }
          } else {
            for (int j = 1; j <= getMonth(item, i); j++) {
              PickerResult pickerResultDay = PickerResult();
              pickerResultDay.primaryName = "$j日";
              pickerResultDay.primaryCode = "$j";

              listDay.add(pickerResultDay);
            }
          }
          pickerResultMonth.childList = listDay;

          listMonth.add(pickerResultMonth);
        }
      } else {
        for (int i = 1; i <= 12; i++) {
          PickerResult pickerResultMonth = PickerResult();
          pickerResultMonth.primaryName = "$i月";
          pickerResultMonth.primaryCode = "$i";

          List listDay = [];
          for (int j = 1; j <= getMonth(item, i); j++) {
            PickerResult pickerResultDay = PickerResult();
            pickerResultDay.primaryName = "$j日";
            pickerResultDay.primaryCode = "$j";

            listDay.add(pickerResultDay);
          }
          pickerResultMonth.childList = listDay;

          listMonth.add(pickerResultMonth);
        }
      }


      pickerResultYear.childList = listMonth;
      list.add(pickerResultYear);
    }

    return list;
  }
}