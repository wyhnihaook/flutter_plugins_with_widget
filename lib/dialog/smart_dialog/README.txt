//参考第三方flutter sdk：flutter_smart_dialog  参考链接：https://juejin.cn/post/7026150456673959943#heading-17
//API解释：https://www.jianshu.com/p/760cfd922bb3?u_atoken=02b80bd9-eb19-48ea-9adf-b01f3562c44b&u_asession=01Q3M_uocwMwcQjjNXsCLvgZVsEEkBZ5tN5nwPA4UBfZbxmuaForRGWMc--PHV97_8X0KNBwm7Lovlpxjd_P_q4JsKWYrT3W_NKPr8w6oU7K_DHDYy3ceirFqrGS5vRFRrPpcarp92QKzyJKyYjREPlmBkFo3NEHBv0PZUm6pbxQU&u_asig=05GK_J6a25ce9sXtA6ObOh7Ott4inmttnbwgmpOhnPO_hIrugVswUWxTBgY-fkpFozp6HNvJQoVX1Dp_LYx0EdFYUYggwyjV3sZDOv__XjtaG0fP1wxQK02GNG4NG6PO8sciQwWRNLFcgAZ8MBQl9VY69XkGRnZNlwC-fTQZJh6Cv9JS7q8ZD7Xtz2Ly-b0kmuyAKRFSVJkkdwVUnyHAIJzQp2jeEZ-oOS8PQ52Yibwij1j3Z2aZjM07DGKoxI8PJdWPRPQyB_SKrj-61LB_f61u3h9VXwMyh6PgyDIVSG1W_Sut_4JedTvhlr2DLOyJckRuWSBte70yVF-VuwV1s-7QjFi2sjozkPd9IRSxLAP1NuRCFfMFGpeHlagDy53tj1mWspDxyAEEo4kbsryBKb9Q&u_aref=V4bc7DTFrPHVkolPCxfTlx8F%2BdU%3D
前言：使用Overlay浮层组件构建Loading/Toast/Dialog
拓展：Dialog是通过Navigator.of(...).push添加透明的页面到路由栈中，所以Navigator.pop能退出Dialog

知识点：
1.Overlay：是一个Stack的Widget，可以将overlay entry（OverlayEntry中返回需要展示的child）插入到overlay中，使独立的child窗口悬浮于其他widget之上
<Toast实现依赖的组件>
使用方式，参考链接：https://www.jianshu.com/p/93e12eac85bc

