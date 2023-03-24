///描述:日期处理帮助类
///功能介绍:日期相关处理
///创建者:翁益亨
///创建日期:2022/7/12 9:34

//通过传入年和月得出当前的天数
int getMonth(int y, int m) {
  switch (m) {
    case 2:
      return isRunYear(y) ? 29 : 28;
    case 4:
    case 6:
    case 9:
    case 11:
      return 30;
    default:
      return 31;
  }
}

//匹配是否是闰年
bool isRunYear(int y) {
  return y % 4 == 0 && y % 100 != 0 || y % 400 == 0;
}
