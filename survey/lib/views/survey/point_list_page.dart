/// @Author: zyg
/// @Date: 2019-07-23
/// @Last Modified by: zyg
/// @Last Modified time: 2019-07-23
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';

import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/services.dart';
import 'package:sensoro_survey/widgets/component.dart';
import 'package:sensoro_survey/model/component_configure_model.dart';
import 'package:sensoro_survey/model/electrical_fire_model.dart';
import 'package:sensoro_survey/views/survey/const.dart' as prefix0;
import 'package:sensoro_survey/views/survey/const.dart';
import 'package:sensoro_survey/widgets/progress_hud.dart';
import 'package:sensoro_survey/generated/customCalendar/multi_select_style_page.dart';
import 'package:sensoro_survey/generated/easyRefresh/easy_refresh.dart';
import 'package:sensoro_survey/generated/customCalendar/lib/flutter_custom_calendar.dart';
import 'package:sensoro_survey/generated/customCalendar/lib/model/date_model.dart';
import 'package:sensoro_survey/model/project_info_model.dart';
import 'package:sensoro_survey/views/survey/common/save_data_manager.dart';
import 'package:sensoro_survey/views/survey/survey_type_page.dart';
import 'package:sensoro_survey/views/survey/add_all_type_page.dart';
import 'package:sensoro_survey/views/survey/add_point_page.dart';

import 'SurveyPointInformation/summary_construction_page.dart';
import 'SurveyPointInformation/survay_electrical_fire_detail.dart';
import 'SurveyPointInformation/survay_electrical_fire_edit.dart';
import 'common/data_transfer_manager.dart';
import 'package:sensoro_survey/net/api/app_api.dart';
import 'package:sensoro_survey/net/api/net_config.dart';

class PointListPage extends StatefulWidget {
  projectInfoModel input;
  PointListPage({Key key, @required this.input}) : super(key: key);

  @override
  _PointListPageState createState() => _PointListPageState(input: this.input);
}

class _PointListPageState extends State<PointListPage> {
  projectInfoModel input;
  _PointListPageState({this.input});

  static List dataList = new List(); //static才能在build里使用
  static int listTotalCount = 0;
  static const EventChannel eventChannel =
      const EventChannel("App/Event/Channel", const StandardMethodCodec());
  bool calendaring = false;
  String beginTimeStr = "";
  String endTimeStr = "";
  int beginTime = 0;
  int endTime = 0;
  FocusNode _focusNode = FocusNode();
  bool isFrist = true;
  String searchStr = "";
  TextEditingController searchController = TextEditingController();
  String dateFilterStr = "";
  List<String> dateFilterList = new List();
  FocusNode blankNode = FocusNode();

  static bool isLeftSelect = false;
  static bool isRightSelect = true;

  static Map<String, dynamic> headers = {};
  // 创建一个给native的channel (类似iOS的通知）
  static const methodChannel =
      const MethodChannel('com.pages.your/project_list');

  Timer _changeTimer;
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();

  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();

  bool loading = false;
  bool loadMore = false;
  TimeOfDay _time = TimeOfDay.now();

  //组件即将销毁时调用
  @override
  void dispose() {
//    dataList.clear();
    super.dispose();
  }

  // 创建一个给native的channel (类似iOS的通知）
  // static const methodChannel = const MethodChannel('com.pages.your/task_test');
  @override
  void initState() {
    super.initState();
    dataList = input.subList;
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {}
    });

    // getConfigureListNetCall();
    getConfigureValueListNetCall();
    // initDetailList();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        //or set color with: Color(0xFF0000FF)
        // statusBarColor: Colors.blue,
        ));
  }

  void initDetailList() {
    for (int index = 0; index < 1000; index++) {
      var name = "测试设备 $index";
      name = "FAGJKJVXOE63S";
      if (index % 3 == 0) name = "项目1118888";
      if (index % 3 == 1) name = "项目222";
      if (index % 3 == 2) name = "项目333";

      var des = "状态 $index 常";
      des = "11:04:12";
      if (index == 1) des = "2019-07-03 10:54";
      if (index == 2) des = "2019-07-06 15:24";
      if (index == 3) des = "2019-07-22 02:14:09";

      // projectInfoModel model = projectInfoModel(name, des, index, "备注11", []);
      // dataList.add(model);
      // var a = 'dd';
      // a = cityDetailArrays[index].name;
    }
  }

  void getConfigureListNetCall() async {
    String urlStr = NetConfig.riskUrl;
    Map<String, dynamic> headers = {};
    Map<String, dynamic> params = {};

    ResultData resultData = await AppApi.getInstance()
        .getListNetCall(context, true, urlStr, headers, params);
    if (resultData.isSuccess()) {
      // _stopLoading();
      int code = resultData.response["code"].toInt();
      if (code == 200) {
        isFrist = false;
        if (resultData.response["data"] is List) {
          List resultList = resultData.response["data"];
          if (resultList.length > 0) {
            setState(() {
              dataList.addAll(resultList);
            });
          }
        }

        if (resultData.response["data"] is Map) {
          Map resultMap = resultData.response["data"];
          if (resultMap["records"] is List) {
            List<dynamic> configureList = resultMap["records"];
            ComponentConfig.confiureList = configureList;
            //本地化存储
          }
        }
      }
    }
  }

  void getConfigureValueListNetCall() async {
    String urlStr = NetConfig.riskValueUrl;
    Map<String, dynamic> headers = {};
    Map<String, dynamic> params = {};

    ResultData resultData = await AppApi.getInstance()
        .getListNetCall(context, true, urlStr, headers, params);
    if (resultData.isSuccess()) {
      // _stopLoading();
      int code = resultData.response["code"].toInt();
      if (code == 200) {
        isFrist = false;
        if (resultData.response["data"] is List) {
          List resultList = resultData.response["data"];
          if (resultList.length > 0) {
            setState(() {
              dataList.addAll(resultList);
            });
          }
        }

        if (resultData.response["data"] is Map) {
          Map resultMap = resultData.response["data"];
          if (resultMap["records"] is List) {
            List<dynamic> configureList = resultMap["records"];
            ComponentConfig.confiureList = configureList;
            //本地化存储
          }
        }
      }
    }
  }

  void _onEvent(Object value) {
    if (value is Map) {
      Map dic = value;
      var name = dic["name"];

      if (name == "showCalendar") {
        dataList.clear();
        // _startLoading();
        setState(() {
          calendaring = true;
          beginTime = dic["beginTime"].toInt();
          endTime = dic["endTime"].toInt();
          if (beginTime > 10000 && endTime > 10000) {
            DateTime date1 = new DateTime.fromMillisecondsSinceEpoch(beginTime);
            beginTimeStr = date1.toString();
            if (beginTimeStr.length > 11) {
              beginTimeStr = beginTimeStr.substring(0, 11);
            }

            DateTime date2 = new DateTime.fromMillisecondsSinceEpoch(endTime);
            endTimeStr = date2.toString();
            if (endTimeStr.length > 11) {
              endTimeStr = endTimeStr.substring(0, 11);
            }
          }
        });
      }

      setState(() {});
      return;
    }
  }

  // 错误处理
  void _onError(dynamic) {}

  _gotoSurveyType() async {
    final result = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => SummaryConstructionPage()),
    );

    if (result != null) {
      String name = result as String;

      if (name == "1") {
        setState(() {});
      }
    }
  }

  _gotoAddAllPage() async {
    List<dynamic> input = ComponentConfig.confiureList;

    final result = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => AddAllPage1(input: input)),
    );

    if (result != null) {
      String name = result as String;

      if (name == "1") {
        setState(() {});
      }
    }
  }

  void _addPoint() async {
    projectInfoModel model = projectInfoModel("", "", "", "", "", "", "", []);

    final result = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(builder: (BuildContext context) {
      return new AddPointPage(input: model);
    }));

    if (result != null) {
      String name = result as String;
      if (name == "refreshList") {
        dataList.clear();

        // loadLocalData();
      }
      // this.name = name;
      setState(() {});
    }
  }

  _navBack() async {
    Map<String, dynamic> map = {
      "code": "200",
      "data": [0, 0, 0]
    };
    await methodChannel.invokeMethod('navBack', map);
  }

  _showCalendar() async {
    //调用flutter日历控件
    final result = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new MultiSelectStylePage()),
    );

    if (result != null) {
      if (result is List) {
        dateFilterList.clear();

        for (int i = 0; i < result.length; i++) {
          DateModel model = result[i];
          int year = model.year;
          int month = model.month;
          int day = model.day;
          String monthStr = month < 10 ? "0${month}" : "${month}";
          String dayStr = day < 10 ? "0${day}" : "${day}";
          String dateFilterStr = "${year}.${monthStr}.${dayStr}";
          dateFilterList.add(dateFilterStr);
          year = model.year;
        }
        if (dateFilterList.length == 1) {
          dateFilterStr = dateFilterList[0];
        } else {
          dateFilterStr =
              "${dateFilterList[0]}~${dateFilterList[dateFilterList.length - 1]}";
        }
        calendaring = true;
        setState(() {});
      }
    }
    return;
    Map<String, dynamic> map = {
      "beginTime": beginTime > 10000 ? beginTime / 1000 : 0,
      "endTime": endTime > 10000 ? endTime / 1000 : 0,
    };
    await methodChannel.invokeMethod('showCalendar', map);
  }

  @override
  Widget build(BuildContext context) {
    Widget emptyContainer = Container(
      height: 0,
      width: 0,
    );

    Widget searchbar = TextField(
      onChanged: (val) {
        searchStr = val;
        setState(() {});
      },
      controller: searchController,
      cursorWidth: 0,
      cursorColor: Colors.white,
      keyboardType: TextInputType.text, //设置输入框文本类型
      textAlign: TextAlign.left,
      //设置内容显示位置是否居中等
      style: new TextStyle(
        fontSize: 13.0,
        color: prefix0.BLACK_TEXT_COLOR,
      ),
      autofocus: false, //自动获取焦点
      decoration: new InputDecoration(
        border: InputBorder.none,
        hintText: "勘察点名称",
        icon: new Container(
          padding: EdgeInsets.all(0.0),
          child: new Image(
            image: new AssetImage("assets/images/search.png"),
            width: 20,
            height: 20,
            // fit: BoxFit.fitWidth,
          ),
        ),

        suffixIcon: new IconButton(
            icon: Image.asset(
              "assets/images/close_black.png",
              // height: 20,
            ),
            tooltip: '消除',
            onPressed: () {
              searchController.clear();
              searchStr = "";
              setState(() {});
            }),

        contentPadding:
            EdgeInsets.fromLTRB(3.0, 20.0, 3.0, 10.0), //设置显示文本的一个内边距
        // //                border: InputBorder.none,//取消默认的下划线边框
      ),
    );

    Widget navBar = AppBar(
      elevation: 1.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Container(
        height: 40,
        width: 200,
        // color: prefix0.LIGHT_LINE_COLOR,
        decoration: BoxDecoration(
          color: prefix0.FENGE_LINE_COLOR,
          borderRadius: BorderRadius.circular(20.0),
        ),
        // height: 140, //高度不填会自适应
        padding:
            const EdgeInsets.only(top: 0.0, bottom: 0, left: 20, right: 10),
        child: searchbar,
        // Row(
        //     //Row 中mainAxisAlignment是水平的，Column中是垂直的
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     //表示所有的子控件都是从左到右序排列，这是默认值
        //     textDirection: TextDirection.ltr,
        //     children: <Widget>[
        //       searchbar,
        //     ]),
      ),
      leading: IconButton(
        icon: Image.asset(
          "assets/images/back.png",
          // height: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      // actions: <Widget>[
      //   IconButton(
      //       // icon: Icon(Icons.date_range, color: Colors.black),
      //       icon: Image.asset(
      //         "assets/images/calendar_black.png",
      //         // height: 20,
      //       ),
      //       tooltip: '日期筛选',
      //       onPressed: () {
      //         _showCalendar();
      //         eventChannel
      //             .receiveBroadcastStream("showCalendar")
      //             .listen(_onEvent, onError: _onError);
      //         // do nothing
      //       }),
      // ],
    );

    Widget bottomButton = Container(
      color: prefix0.LIGHT_LINE_COLOR,
      height: 60,
      width: prefix0.screen_width,
      child: Column(
          //这行决定了左对齐
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 60,
              width: prefix0.screen_width,
              child: new MaterialButton(
                color: prefix0.GREEN_COLOR,
                textColor: Colors.white,
                child: new Text('新建安装点',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 20)),
                onPressed: () {
                  DataTransferManager.shared.project = input;
                  DataTransferManager.shared.creatModel();
                  _gotoSurveyType();
                  // _gotoAddAllPage();
                },
              ),
            ),
            //分割线
            // Container(
            //     width: prefix0.screen_width - 40,
            //     height: 1.0,
            //     color: FENGE_LINE_COLOR),
          ]),
    );

    String _getFireModelCreateDate(int timeId) {
      DateTime _dateTime = DateTime.fromMillisecondsSinceEpoch(timeId);
      String monthStr =
          _dateTime.month < 10 ? "0${_dateTime.month}" : "${_dateTime.month}";
      String dayStr =
          _dateTime.day < 10 ? "0${_dateTime.day}" : "${_dateTime.day}";
      String hourStr =
          _dateTime.hour < 10 ? "0${_dateTime.hour}" : "${_dateTime.hour}";
      String minuteStr = _dateTime.minute < 10
          ? "0${_dateTime.minute}"
          : "${_dateTime.minute}";

      return "${_dateTime.year}-${monthStr}-${dayStr} ${hourStr}:${minuteStr}";
    }

    editSurvey() async {
      final result = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new SurvayElectricalFireEditPage()),
      );

      if (result != null) {
        String name = result as String;

        if (name == "1") {
          setState(() {});
        }
      }
    }

    surveyDetail() async {
      final result = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new SurvayElectricalFireDetailPage()),
      );

      if (result != null) {
        String name = result as String;

        if (name == "1") {
          setState(() {});
        }
      }
    }

    Widget myListView = new ListView.builder(
        physics: new AlwaysScrollableScrollPhysics()
            .applyTo(new BouncingScrollPhysics()), // 这个是用来控制能否在不满屏的状态下滚动的属性
        itemCount: dataList.length == 0 ? 1 : dataList.length,
        // separatorBuilder: (BuildContext context, int index) =>
        // Divider(height: 1.0, color: Colors.grey, indent: 20), // 添加分割线
        itemBuilder: (BuildContext context, int index) {
          // print("rebuild index =$index");
          if (dataList.length == 0) {
            return new Container(
              padding: const EdgeInsets.only(
                  top: 150.0, bottom: 0, left: 0, right: 0),
              child: new Column(children: <Widget>[
                new Image(
                  image: new AssetImage("assets/images/nocontent.png"),
                  width: 120,
                  height: 120,
                  // fit: BoxFit.fitWidth,
                ),
                Text("没有已创建的安装点，请创建安装点",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: prefix0.LIGHT_TEXT_COLOR,
                        fontWeight: FontWeight.normal,
                        fontSize: 17)),
              ]),
            );
          }

          Map modelMap = dataList[index];

          ElectricalFireModel model = ElectricalFireModel.fromJson(modelMap);
          if (!model.editName.contains(searchStr) && searchStr.length > 0) {
            return emptyContainer;
          }

          String time = _getFireModelCreateDate(model.electricalFireId);
          String time1 = time.substring(0, 11);
          time1 = time1.replaceAll('-', '.');

          bool flag = false;
          if (dateFilterList.length > 0) {
            for (String dateStr in dateFilterList) {
              if (time1.contains(dateStr)) {
                flag = true;
              }
            }
          } else {
            flag = true;
          }

          if (!flag) {
            return emptyContainer;
          }

          return new GestureDetector(
              onTap: () {
                DataTransferManager.shared.project = input;
                DataTransferManager.shared.fireCreatModel = model;
                DataTransferManager.shared.isEditModel = true;
                surveyDetail();
              },
              child: new Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    top: 0.0, bottom: 0, left: 0, right: 0),
                child: new Column(

                    //这行决定了左对齐
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        color: LIGHT_LINE_COLOR,
                        height: 12,
                        width: prefix0.screen_width,
                      ),

                      Container(
                        // height: 80,
                        padding: const EdgeInsets.only(
                            top: 0.0, bottom: 0, left: 20, right: 20),
                        child: Row(
                            //Row 中mainAxisAlignment是水平的，Column中是垂直的
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //表示所有的子控件都是从左到右顺序排列，这是默认值
                            textDirection: TextDirection.ltr,
                            children: <Widget>[
                              new Image(
                                image: new AssetImage("assets/images/电气火灾.png"),
                                width: 20,
                                height: 20,
                                // fit: BoxFit.fitWidth,
                              ),
                              //这行决定了左对齐
                              new Padding(
                                padding: new EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    //这个位置用ListTile就会报错
                                    Text(model.editName,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: prefix0.BLACK_TEXT_COLOR,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 17)),
                                    Text(
                                        _getFireModelCreateDate(
                                            model.electricalFireId),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: prefix0.BLACK_TEXT_COLOR,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 17)),
                                  ],
                                ),
                              ),

                              new SizedBox(
                                width: 10,
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  new RaisedButton(
                                    color: Colors.orange,
                                    textColor: Colors.white,
                                    child: new Text('编辑'),
                                    onPressed: () {
                                      DataTransferManager.shared.project =
                                          input;
                                      DataTransferManager
                                          .shared.fireCreatModel = model;
                                      DataTransferManager.shared.isEditModel =
                                          true;

//                                  Navigator.push(
//                                    context,
//                                    new MaterialPageRoute(
//                                        builder: (context) => new SummaryConstructionPage()),
//                                  );
                                      editSurvey();
                                    },
                                  ),
                                  // new RaisedButton(
                                  //   color: prefix0.LIGHT_TEXT_COLOR,
                                  //   textColor: Colors.white,
                                  //   child: new Text('导出'),
                                  //   onPressed: () {},
                                  // ),
                                ],
                              ),
                            ]),
                      ),
                      //分割线
                      Container(
                          width: prefix0.screen_width,
                          height: 1.0,
                          color: FENGE_LINE_COLOR),
                    ]),
              ));
        });

    Widget myRefreshListView = ProgressDialog(
      loading: loading,
      msg: '正在加载...',
      child: EasyRefresh(
        key: _easyRefreshKey,
        behavior: ScrollOverBehavior(),
        refreshHeader: ClassicsHeader(
          key: _headerKey,
          refreshText: pullToRefresh_localString,
          // refreshReadyText: Translations.of(context).txt("releaseToRefresh"),
          refreshReadyText: pullToRefresh_localString,
          refreshingText: pullToRefresh_localString,
          refreshedText: refreshed_localString,
          moreInfo: "",
          bgColor: LIGHT_LINE_COLOR,
          textColor: Colors.black87,
          moreInfoColor: Colors.black54,
          showMore: true,
        ),
        refreshFooter: ClassicsFooter(
          key: _footerKey,
          loadText: pushToLoad_localString,
          loadReadyText: releaseToLoad_localString,
          loadingText: pushToLoad_localString,
          loadedText: loadFinish_localString,
          noMoreText: loadFinish_localString,
          moreInfo: "",
          bgColor: LIGHT_LINE_COLOR,
          textColor: Colors.black87,
          moreInfoColor: Colors.black54,
          showMore: true,
        ),
        child: myListView,
        onRefresh: () async {
          await new Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _easyRefreshKey.currentState.waitState(() {
                dataList.clear();
                setState(() {
                  loadMore = true;
                });
              });
            });
          });
        },
        loadMore: () async {
          await new Future.delayed(const Duration(milliseconds: 600), () {
            _easyRefreshKey.currentState.waitState(() {
              setState(() {
                loadMore = false;
                if (dataList.length >= listTotalCount && listTotalCount > 0) {
                  return;
                }
                //延时调用
                // _changeTimer = new Timer(Duration(milliseconds: 600), () {
                //   //监听信息传
                //   SendEvent();
                //   // setState(() {});
                // });
              });
            });
          });
        },
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: Text("Flutter Layout Demo"),
      title: "Flutter Layout Demo",
      home: Scaffold(
//          appBar: navBar,
          body: GestureDetector(
            onTap: () {
              // 点击空白页面关闭键盘
              FocusScope.of(context).requestFocus(blankNode);
            },
            child: Container(
              color: Colors.white,
              // height: 140, //高不填会自适应
              padding:
                  const EdgeInsets.only(top: 0.0, bottom: 0, left: 0, right: 0),
              child: Column(
                //这行决定了左对齐
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  !calendaring
                      ? emptyContainer
                      : Container(
                          color: Colors.white,
                          // height: 140, //高度不填会自适应
                          padding: const EdgeInsets.only(
                              top: 3.0, bottom: 3, left: 20, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                // "$beginTimeStr ~ $endTimeStr",
                                dateFilterStr.length > 0 ? dateFilterStr : "",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: prefix0.BLACK_TEXT_COLOR,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12),
                              ),
                              IconButton(
                                icon: Image.asset(
                                  "assets/images/close_black.png",
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  calendaring = false;
                                  this.dateFilterList.clear();
                                  this.dateFilterStr = "";
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                  //分割线
                  Container(
                      width: prefix0.screen_width,
                      height: 1.0,
                      color: FENGE_LINE_COLOR),
                  Expanded(
                    child: myListView,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: bottomButton,
          )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
