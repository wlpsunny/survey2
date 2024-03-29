//现场情况
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensoro_survey/model/electrical_fire_model.dart';
import 'package:sensoro_survey/views/survey/common/data_transfer_manager.dart';
import 'package:sensoro_survey/views/survey/common/save_data_manager.dart';
import 'package:sensoro_survey/views/survey/const.dart' as prefix0;

import '../../../pic_swiper.dart';

class SurvayElectricalFireDetailPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<SurvayElectricalFireDetailPage> {
  BasicMessageChannel<String> _basicMessageChannel =
      BasicMessageChannel("BasicMessageChannelPluginPickImage", StringCodec());
  BasicMessageChannel<String> _locationBasicMessageChannel =
      BasicMessageChannel("BasicMessageChannelPlugin", StringCodec());
  static PageController _pageController = new PageController();
  ElectricalFireModel fireModel = DataTransferManager.shared.fireCreatModel;
  ElectricalFireModel fireCreatModel =
      DataTransferManager.shared.fireCreatModel;
  var isCheack = false;

//  var remark = "";
  var imgPath;
  var _groupValue = 0;
  int picImageIndex = 0;
  int editIndex = -1;

  var hisoryKey = "isNeedPresent";

  var currentValue = 1;
  TextEditingController step1remarkController = TextEditingController();
  TextEditingController step3remarkController = TextEditingController();
  TextEditingController step4remarkController = TextEditingController();

  @override
  void initState() {
    _basicMessageChannel.setMessageHandler((message) => Future<String>(() {
          print(message);
          //message为native传递的数据
          _resentpics(message);
          //给Android端的返回值
          return "========================收到Native消息：" + message;
        }));
    _locationBasicMessageChannel
        .setMessageHandler((message) => Future<String>(() {
              print(message);
              //message为native传递的数据
              if (message != null && message.isNotEmpty) {
                List list = message.split(",");
                if (list.length == 3) {
                  setState(() {
                    fireModel.editLongitudeLatitude = list[0] + "," + list[1];
                    fireModel.editPosition = list[2];
                  });
                }
              }
              //给Android端的返回值
              return "========================收到Native消息：" + message;
            }));
    _getIsNeedShowPresent();
    step1remarkController.text = fireCreatModel.step1Remak;
    step3remarkController.text = fireCreatModel.step3Remak;
    step4remarkController.text = fireCreatModel.step4Remak;
    updateNextButton();
    super.initState();
  }

  _getIsNeedShowPresent() async {
    List tags = await SaveDataManger.getHistory(hisoryKey);

    if (tags.length > 0) {
      String isNeedDate = tags[0];

      DateTime date = DateTime.parse(isNeedDate);
      var difference = date.difference(DateTime.now());

      if (difference.inDays >= 1) {
        _groupValue = 0;
      } else {
        _groupValue = 1;
      }
    } else {
      _groupValue = 0;
    }
  }

  _resentpics(String urlString) {
    if (urlString.isNotEmpty) {
      setState(() {
        switch (picImageIndex) {
          case 0:
            fireCreatModel.editpic1 = urlString;
            break;
          case 1:
            fireCreatModel.editpic2 = urlString;
            break;
          case 2:
            fireCreatModel.editpic3 = urlString;
            break;
          case 3:
            fireCreatModel.editpic4 = urlString;
            break;
          case 4:
            fireCreatModel.editpic5 = urlString;
            break;
          case 5:
            fireCreatModel.editenvironmentpic1 = urlString;
            break;
          case 6:
            fireCreatModel.editenvironmentpic2 = urlString;
            break;
          case 7:
            fireCreatModel.editenvironmentpic3 = urlString;
            break;
          case 8:
            fireCreatModel.editenvironmentpic4 = urlString;
            break;
          case 9:
            fireCreatModel.editenvironmentpic5 = urlString;
            break;
          case 10:
            fireCreatModel.editOutsinPic = urlString;
            break;
        }
      });
    }
  }

  void _locationSendToNative() {
    if (this.fireModel.editPosition.length > 0) {
      var location =
          "1," + fireModel.editLongitudeLatitude + "," + fireModel.editAddress;

      Future<String> future = _locationBasicMessageChannel.send(location);
      future.then((message) {
        print("========================" + message);
      });
    }
  }

  //向native发送消息
  void _sendToNative() {
    Future<String> future = _basicMessageChannel.send("");
    future.then((message) {
      print("========================" + message);
    });

//    super.initState();
  }

  editAddress() async {}

  editDangerous() async {}

  editCurrent() async {}

  editPurpose() async {}

  updateNextButton() {
    if (fireCreatModel.page2editAddress.length > 0 &&
        fireCreatModel.editpic1.length > 0 &&
        fireCreatModel.editpic2.length > 0 &&
        fireCreatModel.editenvironmentpic1.length > 0 &&
        fireCreatModel.current.length > 0) {
      setState(() {
        isCheack = true;
      });
    }
  }

  showPicDialog() {
//    if (_groupValue == 1) {
//      openGallery();
//    } else {
////        showPicDialog2();
//      showPicDialognew();
//    }
  }

  showPicDialognew() {
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text(
              '电箱环境拍照示例',
              textAlign: TextAlign.center,
            ),
            content:
                new StatefulBuilder(builder: (context, StateSetter setState) {
              return Container(
                  height: 380,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: new EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: new Text("需看到电箱四周墙面情况及离地高度"),
                      ),
                      Image.asset(
                        "assets/images/take_photo_prompt.png",
                        width: 150,
                        height: 150,
                      ),
                      Padding(
                        padding: new EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: new Row(
                          children: <Widget>[
                            Radio(
                                value: 1,
                                groupValue: _groupValue,
                                onChanged: (int e) {}),
                            Text("今日不再提示"),
                          ],
                        ),
                      ),
                      new SimpleDialogOption(
                        child: Padding(
                          padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: GestureDetector(
                            onTap: null, //写入方法名称就可以了，但是是无参的
                            child: Container(
                                color: prefix0.TITLE_TEXT_COLOR,
                                alignment: Alignment.center,
                                height: 50,
                                child: new Text(
                                  "拍照",
                                  style: new TextStyle(color: Colors.white),
                                )),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (_groupValue == 1) {
                            SaveDataManger.saveHistory(
                                [DateTime.now().toString()], hisoryKey);
                          }
                          openGallery();
                        },
                      ),
                    ],
                  ));
            }),
          );
        });
  }

  /*拍照*/
  takePhoto1() async {
    picImageIndex = 0;

    openGallery();
  }

  /*拍照*/
  takePhoto2() async {
    picImageIndex = 1;
    openGallery();
  }

  /*拍照*/
  takePhoto3() async {
    picImageIndex = 2;
    openGallery();
  }

  /*拍照*/
  takePhoto4() async {
    picImageIndex = 3;
    openGallery();
  }

  /*拍照*/
  takePhoto5() async {
    picImageIndex = 4;
    openGallery();
  }

  /*拍照*/
  takePhoto6() async {
    picImageIndex = 5;
    openGallery();
  }

  /*拍照*/
  takePhoto7() async {
    picImageIndex = 6;
    openGallery();
  }

  /*拍照*/
  takePhoto8() async {
    picImageIndex = 7;
    openGallery();
  }

  /*拍照*/
  takePhoto9() async {
    picImageIndex = 8;
    openGallery();
  }

  /*拍照*/
  takePhoto10() async {
    picImageIndex = 9;
    openGallery();
  }

  /*拍照*/
  takePhoto11() async {
    picImageIndex = 10;
    openGallery();
  }

  Widget buildButton(
    String text,
    Function onPressed, {
    Color color = Colors.white,
  }) {
    return FlatButton(
      color: prefix0.TITLE_TEXT_COLOR,
      child: Text(text),
      onPressed: onPressed,
    );
  }

  /*相册*/
  openGallery() async {
    List<PicSwiperItem> list = new List();
    PicSwiperItem picSwiperItem = PicSwiperItem("");
    list.clear();

    switch (picImageIndex) {
      case 0:
        picSwiperItem.picUrl = fireCreatModel.editpic1;

        break;
      case 1:
        picSwiperItem.picUrl = fireCreatModel.editpic2;

        break;
      case 2:
        picSwiperItem.picUrl = fireCreatModel.editpic3;

        break;
      case 3:
        picSwiperItem.picUrl = fireCreatModel.editpic4;

        break;
      case 4:
        picSwiperItem.picUrl = fireCreatModel.editpic5;

        break;
      case 5:
        picSwiperItem.picUrl = fireCreatModel.editenvironmentpic1;

        break;
      case 6:
        picSwiperItem.picUrl = fireCreatModel.editenvironmentpic2;

        break;
      case 7:
        picSwiperItem.picUrl = fireCreatModel.editenvironmentpic3;

        break;
      case 8:
        picSwiperItem.picUrl = fireCreatModel.editenvironmentpic4;

        break;
      case 9:
        picSwiperItem.picUrl = fireCreatModel.editenvironmentpic5;

        break;
      case 10:
        picSwiperItem.picUrl = fireCreatModel.editOutsinPic;

        break;
    }

    list.add(picSwiperItem);
    if (picSwiperItem.picUrl.isNotEmpty) {
      final result = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new PicSwiper(index: 0, pics: list)),
      );
    }

//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    setState(() {
//      imgPath = image;
//    });
//    _sendToNative();
//    var image = await ImagePicker.pickImage(source: ImageSource.camera);
//    if(null!=image){
//
//      _resentpics(image.uri.path.toString());
//
////    setState(() {
////
////      imgPath = image;
////    });
//    }
  }

  @override
  Widget build(BuildContext context) {
    Widget NavBar = AppBar(
      elevation: 1.0,
      centerTitle: true,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text(
        "电器火灾安装点勘察详情",
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Image.asset(
          "assets/images/back.png",
          // height: 20,
        ),
        onPressed: () {
          // SendEvent();
          Navigator.pop(context);
        },
      ),
    );

    Widget bottomButton = Container(
      color: prefix0.LIGHT_LINE_COLOR,
      height: 60,
      width: prefix0.screen_width,
      child: new MaterialButton(
        color: this.isCheack ? prefix0.GREEN_COLOR : Colors.grey,
        textColor: Colors.white,
        child: new Text('完成',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 20)),
        onPressed: () {
          if (this.isCheack) {
            if (DataTransferManager.shared.isEditModel) {
              for (int i = 0;
                  i < DataTransferManager.shared.project.subList.length;
                  i++) {
                Map map = DataTransferManager.shared.project.subList[i];

                ElectricalFireModel model = ElectricalFireModel.fromJson(map);
                if (model.electricalFireId ==
                    DataTransferManager
                        .shared.fireCreatModel.electricalFireId) {
                  DataTransferManager.shared.project.subList.remove(map);
                  break;
                }
              }
              DataTransferManager.shared.project.subList
                  .add(DataTransferManager.shared.fireCreatModel.toJson());
            } else {
              DataTransferManager.shared.project.subList
                  .add(DataTransferManager.shared.fireCreatModel.toJson());
            }

            DataTransferManager.shared.saveProject();

            Navigator.of(context).pop("1");
          }
        },
      ),
    );

    Widget container = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: editAddress, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("电箱位置",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fireCreatModel.page2editAddress.length > 0
                          ? fireCreatModel.page2editAddress
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: editPurpose, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("电箱用途",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fireCreatModel.page2editPurpose.length > 0
                          ? fireCreatModel.page2editPurpose
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editAddress,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("备注",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            enabled: false,
            controller: step1remarkController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.0),
                  borderSide: BorderSide(color: Colors.transparent)),
//                  labelText: '备注',
              hintText: '无',
            ),
            maxLines: 5,
            autofocus: false,
            onChanged: (val) {
              fireCreatModel.step1Remak = val;
              setState(() {});
            },
          ),
        ],
      ),
    );

    Widget step1 = Container(
        color: prefix0.LIGHT_LINE_COLOR,
        child: new Column(
          children: <Widget>[
            new Row(children: <Widget>[
              Padding(
                child: new Text(
                  electricalItems[0],
                  style: TextStyle(color: Colors.grey,
                      fontSize: 18

                  ),
                ),
                padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
              )
            ]),
            container,
          ],
        ));

    Widget takepice1 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 150,
      child: new ListView(
//           mainAxisAlignment: MainAxisAlignment.start,
        scrollDirection: Axis.horizontal,

        children: <Widget>[
          GestureDetector(
              onTap: takePhoto1,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 1;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editpic1.length == 0
                          ? Text('电箱整体照片',
                        style: new TextStyle(
                            fontSize: prefix0.fontsSize
                        ),
                      )
                          : Image.file(File(fireCreatModel.editpic1)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 1
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
            onTap: takePhoto2,
            //写入方法名称就可以了，但是是无参的
            onTapUp: (_) {
              setState(() {
                editIndex = -1;
              });
            },
            onTapCancel: () {
              setState(() {
                editIndex = -1;
              });
            },
            onTapDown: (_) {
              setState(() {
                editIndex = 2;
              });
            },
            child: Stack(
              alignment: const Alignment(0.9, -1.1),
              children: <Widget>[
                new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: fireCreatModel.editpic2.length == 0
                              ? Text('总开关照片')
                              : Image.file(File(fireCreatModel.editpic2)),
                          decoration: new BoxDecoration(
                            border: new Border.all(
                                width: 1.0,
                                color: (editIndex == 2
                                    ? Colors.green
                                    : prefix0.LINE_COLOR)),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          width: 150,
                          height: 150,
                        ),
                      ],
                    )),
              ],
            ),
          ),
          GestureDetector(
              onTap: takePhoto3,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 3;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editpic3.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(File(fireCreatModel.editpic3)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 3
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
              onTap: takePhoto4,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 4;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(10, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editpic4.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(File(fireCreatModel.editpic4)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 4
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
              onTap: takePhoto5,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 5;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(10, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editpic5.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(File(fireCreatModel.editpic5)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 5
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );

    Widget takepice2 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 150,
      child: new ListView(
//           mainAxisAlignment: MainAxisAlignment.start,
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
              onTap: takePhoto6,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 6;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editenvironmentpic1.length == 0
                          ? Text('环境照片')
                          : Image.file(
                              File(fireCreatModel.editenvironmentpic1)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 6
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
              onTap: takePhoto7,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 7;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editenvironmentpic2.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(
                              File(fireCreatModel.editenvironmentpic2)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 7
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
              onTap: takePhoto8,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 8;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editenvironmentpic3.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(
                              File(fireCreatModel.editenvironmentpic3)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 8
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
              onTap: takePhoto9,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 9;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editenvironmentpic4.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(
                              File(fireCreatModel.editenvironmentpic4)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 9
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
          GestureDetector(
              onTap: takePhoto10,
              //写入方法名称就可以了，但是是无参的
              onTapUp: (_) {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapCancel: () {
                setState(() {
                  editIndex = -1;
                });
              },
              onTapDown: (_) {
                setState(() {
                  editIndex = 10;
                });
              },
              child: Stack(
                alignment: const Alignment(0.9, -1.1),
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.fromLTRB(0, 10, 20, 0),
                    child: Container(
                      alignment: Alignment.center,
                      child: fireCreatModel.editenvironmentpic5.length == 0
                          ? Text(
                              '+',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.w100),
                            )
                          : Image.file(
                              File(fireCreatModel.editenvironmentpic5)),
                      decoration: new BoxDecoration(
                        border: new Border.all(
                            width: 1.0,
                            color: (editIndex == 10
                                ? Colors.green
                                : prefix0.LINE_COLOR)),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(5.0)),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );

    Widget takePhones = Container(
      color: Colors.white,
      child: Column(
//        scrollDirection: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.fromLTRB(20, 20, 0, 20),
                child: Text(
                  "电箱照片",
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontSize: prefix0.fontsSize
                  ),
                ),
              ),
            ],
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[takepice1],
          ),
          new Padding(
            padding: new EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Text("至少拍摄2张清晰的电箱及空开照片，能看清空开上的数字及信息。"),
          ),
          Row(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.fromLTRB(20, 20, 0, 20),
                child: Text(
                  "环境照片",
                  style: new TextStyle(
                      fontSize: prefix0.fontsSize
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[takepice2],
          ),
          new Padding(
            padding: new EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Text("至少拍摄1张环境照片，可以清楚的看到电箱周围的墙面情况和离地高度。"),
          ),
        ],
      ),
    );

    ScrollController _controller2 = TrackingScrollController();

    bool dataNotification(ScrollNotification notification) {
      if (notification.metrics.axis == Axis.horizontal) {
        return false;
      }
      if (Platform.isIOS) {
        double height = notification.metrics.maxScrollExtent; //step2的高度
        height = height + 80;
        if (notification.metrics.extentBefore > height) {
          //下滑到最底部
          _pageController.animateToPage(2,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        } //滑动到最顶部
        if (notification.metrics.extentAfter > height) {
          _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      } else if (Platform.isAndroid) {
        //android相关代码
        if (notification is ScrollEndNotification) {
          if (notification.metrics.extentAfter == 0) {
            //下滑到最底部
            _pageController.animateToPage(2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          } //滑动到最顶部
          if (notification.metrics.extentBefore == 0) {
            _pageController.animateToPage(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        }
      }
      return true;
    }

    Widget step2 = Container(
        color: prefix0.LIGHT_LINE_COLOR,
        padding: new EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: new NotificationListener(
            onNotification: dataNotification,
            child: new Column(
//          physics: NeverScrollableScrollPhysics(),
//          shrinkWrap: true,

//              controller: _controller2,
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Row(children: <Widget>[
                      Padding(
                        child: new Text(
                          electricalItems[1],
                          style: TextStyle(color: Colors.grey,
                              fontSize: 18

                          ),
                        ),
                        padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
                      )
                    ]),
                    takePhones,
                  ],
                )
              ],
            )));

    Widget installationEnvironment = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
//            onTap: editName,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("配备外箱",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: new Radio(
                        value: 0,
                        groupValue: fireCreatModel.isNeedCarton,
                        onChanged: (int e) {}),
                  ),
                  Text("不需要\n(电箱空间足够)",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: new Radio(
                        value: 1,
                        groupValue: fireCreatModel.isNeedCarton,
                        onChanged: (int e) {}),
                  ),
                  Text("需要\n(电箱空间不够)",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("电箱位置",
                    style: new TextStyle(
                      fontSize: prefix0.fontsSize
                  ),),
                  new Radio(
                      value: 1,
                      groupValue: fireCreatModel.isOutSide,
                      onChanged: (int e) {}),
                  Text("户外",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.isOutSide,
                      onChanged: (int e) {}),
                  Text("户内",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("是否需要梯子",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.isNeedLadder,
                      onChanged: (int e) {}),
                  Text("不需要",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 1,
                      groupValue: fireCreatModel.isNeedLadder,
                      onChanged: (int e) {}),
                  Text("需要",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: takePhoto11,
            //写入方法名称就可以了，但是是无参的
            onTapUp: (_) {
              setState(() {
                editIndex = -1;
              });
            },
            onTapCancel: () {
              setState(() {
                editIndex = -1;
              });
            },

            onTapDown: (_) {
              setState(() {
                editIndex = 11;
              });
            },
            child: new Padding(
              padding: new EdgeInsets.fromLTRB(10, 20, 20, 0),
              child: Container(
                alignment: Alignment.center,
                child: fireCreatModel.editOutsinPic.length == 0
                    ? Text('+外箱安装位置图片')
                    : Image.file(File(fireCreatModel.editOutsinPic)),
                decoration: new BoxDecoration(
                  border: new Border.all(
                      width: 1.0,
                      color: (editIndex == 11
                          ? Colors.green
                          : prefix0.LINE_COLOR)),
                  borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                ),
                width: 150,
                height: 150,
              ),
            ),
          ),
          GestureDetector(
//            onTap: editAddress,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("备注",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            enabled: false,
            controller: step3remarkController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.0),
                  borderSide: BorderSide(color: Colors.transparent)),
//                  labelText: '备注',
              hintText: '无',
            ),
            maxLines: 5,
            autofocus: false,
            onChanged: (val) {
              fireCreatModel.step3Remak = val;
              setState(() {});
            },
          ),
          Padding(
            padding: new EdgeInsets.fromLTRB(0, 0, 0, 100),
          )
        ],
      ),
    );

    ScrollController _controller3 = TrackingScrollController();

    bool dataNotification3(ScrollNotification notification) {
      if (Platform.isIOS) {
        double height = notification.metrics.maxScrollExtent; //step2的高度
        height = height + 80;
        if (notification.metrics.extentBefore > height) {
          //下滑到最底部
          _pageController.animateToPage(3,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        } //滑动到最顶部
        if (notification.metrics.extentAfter > height) {
          _pageController.animateToPage(1,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      } else if (Platform.isAndroid) {
        //android相关代码
        if (notification is ScrollEndNotification) {
          if (notification.metrics.extentAfter == 0) {
            //下滑到最底部
            _pageController.animateToPage(3,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          } //滑动到最顶部
          if (notification.metrics.extentBefore == 0) {
            _pageController.animateToPage(1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        }
      }
      return true;
    }

    Widget step3 = Container(
        color: prefix0.LIGHT_LINE_COLOR,
        padding: new EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: new NotificationListener(
            onNotification: dataNotification3,
            child: new Column(
//          physics: NeverScrollableScrollPhysics(),
//          shrinkWrap: true,

              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Row(children: <Widget>[
                      Padding(
                        child: new Text(
                          electricalItems[2],
                          style: TextStyle(color: Colors.grey,
                              fontSize: 18

                          ),
                        ),
                        padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
                      )
                    ]),
                    installationEnvironment,
                  ],
                )
              ],
            )));

    int _getProbeCount() {
      if (fireCreatModel.isSingle == 1) {
        if (fireCreatModel.isZhiHui == 1) {
          fireCreatModel.probeNumber = "0";
          return 0;
        } else {
          fireCreatModel.probeNumber = "2";
          return 2;
        }
      } else {
        fireCreatModel.probeNumber = "4";
        return 4;
      }
    }

    String _getRatedCurrent() {
      if (fireCreatModel.isSingle == 1) {
        if (fireCreatModel.isZhiHui == 1) {
          fireCreatModel.currentSelect = "63A";
          return "63A";
        } else {
          fireCreatModel.currentSelect = "63A";
          return "60A";
        }
      } else {
        if (currentValue == 0) {
          fireCreatModel.currentSelect = "250A";
        } else {
          fireCreatModel.currentSelect = "400A";
        }
        return "";
      }
    }

    String _getLeakageCurrent() {
      if (fireCreatModel.isSingle == 1) {
        if (fireCreatModel.isZhiHui == 1) {
          fireCreatModel.recommendedTransformer = "";
          return "";
        } else {
          fireCreatModel.recommendedTransformer = "L16K";
          return "L16K";
        }
      } else {
        if (fireCreatModel.isMolded == 1) {
          fireCreatModel.recommendedTransformer = "L45K";
          return "L45K";
        } else {
          fireCreatModel.recommendedTransformer = "L80K";
          return "L80K";
        }
      }
    }

    Widget installationEnvironment2 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
//            onTap: editName,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("报警音可否有效传播",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: new Radio(
                        value: 1,
                        groupValue: fireCreatModel.isEffectiveTransmission,
                        onChanged: (int e) {}),
                  ),
                  Text("是",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: new Radio(
                        value: 0,
                        groupValue: fireCreatModel.isEffectiveTransmission,
                        onChanged: (int e) {}),
                  ),
                  Text("否",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("报警是否扰民",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 1,
                      groupValue: fireCreatModel.isNuisance,
                      onChanged: (int e) {}),
                  Text("是",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.isNuisance,
                      onChanged: (int e) {}),
                  Text("否",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("是否有专人消音",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 1,
                      groupValue: fireCreatModel.isNoiseReduction,
                      onChanged: (int e) {}),
                  Text("是",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.isNoiseReduction,
                      onChanged: (int e) {}),
                  Text("否",

                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editAddress,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("备注",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            enabled: false,
            controller: step4remarkController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.0),
                  borderSide: BorderSide(color: Colors.transparent)),
//                  labelText: '备注',
              hintText: '无',
            ),
            maxLines: 5,
            autofocus: false,
            onChanged: (val) {
              fireCreatModel.step4Remak = val;
              setState(() {});
            },
          ),
          Padding(
            padding: new EdgeInsets.fromLTRB(0, 0, 0, 100),
          )
        ],
      ),
    );

    Widget perationEnvironment = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
//            onTap: editName,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("空开层级",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 1,
                      groupValue: fireCreatModel.allOpenValue,
                      onChanged: (int e) {}),
                  Text("总空开",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.allOpenValue,
                      onChanged: (int e) {}),
                  Text("分空开",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("空开类型",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 1,
                      groupValue: fireCreatModel.isSingle,
                      onChanged: (int e) {}),
                  Text("单相电",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.isSingle,
                      onChanged: (int e) {}),
                  Text("三相电",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                ],
              ),
            ),
          ),
          new Offstage(
            offstage: (fireCreatModel.isSingle == 1) ? true : false,
            child: Container(
              padding: new EdgeInsets.fromLTRB(72, 0, 0, 0),
              child: Container(
                color: prefix0.LINE_COLOR,
                height: 1,
              ),
            ),
          ),
          new Offstage(
            offstage: (fireCreatModel.isSingle == 1) ? true : false,
            child: GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
              child: Container(
                alignment: Alignment.center,
                height: 60,
                child: new Row(
                  children: <Widget>[
                    Text("              "),
                    new Radio(
                        value: 1,
                        groupValue: fireCreatModel.isMolded,
                        onChanged: (int e) {}),
                    Text("微断",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                    new Radio(
                        value: 0,
                        groupValue: fireCreatModel.isMolded,
                        onChanged: (int e) {}),
                    Text("塑壳",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: editCurrent, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("额定电流",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fireCreatModel.current.length > 0
                          ? (fireCreatModel.current + "A")
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: editDangerous, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("危险线路数"),
                  Expanded(
                    child: Text(
                      fireCreatModel.dangerous.length > 0
                          ? (fireCreatModel.dangerous + "条")
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget perationEnvironment2 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("适用类型",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  new Radio(
                    value: 1,
                    groupValue: fireCreatModel.isZhiHui,
                    onChanged: (int e) {},
                  ),
                  Expanded(
                    child: Text(
                      "智慧空开\n(支持通断)",
                      style: new TextStyle(
                          color: fireCreatModel.isSingle == 1
                              ? Colors.black
                              : Colors.grey,

                            fontSize: 14

                      ),
                    ),
                  ),
                  new Radio(
                      value: 0,
                      groupValue: fireCreatModel.isZhiHui,
                      onChanged: (int e) {}),
                  Expanded(
                    child: Text("电气火灾\n(不支持通断)",
                      style: new TextStyle(
                          fontSize: 14
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("温度探头数",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _getProbeCount().toString() + "个",
                      textAlign: TextAlign.right,

                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          new Offstage(
            offstage: (fireCreatModel.isSingle == 0) ? true : false,
            child: GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
              child: Container(
                alignment: Alignment.center,
                height: 60,
                child: new Row(
                  children: <Widget>[
                    Text("额定电流",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getRatedCurrent(),
                        textAlign: TextAlign.right,
                        style: new TextStyle(
                            fontSize: prefix0.fontsSize
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          new Offstage(
            offstage: (fireCreatModel.isSingle == 1) ? true : false,
            child: GestureDetector(
//            onTap: editName,//写入方法名称就可以了，但是是无参的
              child: Container(
                alignment: Alignment.center,
                height: 60,
                child: new Row(
                  children: <Widget>[
                    Text("额定电流",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                    Expanded(
                      child: new Radio(
                          value: 1,
                          groupValue: currentValue,
                          onChanged: (int e) {}),
                    ),
                    Text("250A",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                    Expanded(
                      child: new Radio(
                          value: 0,
                          groupValue: currentValue,
                          onChanged: (int e) {}),
                    ),
                    Text("400A",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          new Offstage(
            offstage:
                (fireCreatModel.isSingle == 1 && fireCreatModel.isZhiHui == 1)
                    ? true
                    : false,
            child: GestureDetector(
//            onTap: editPurpose,//写入方法名称就可以了，但是是无参的
              child: Container(
                alignment: Alignment.center,
                height: 60,
                child: new Row(
                  children: <Widget>[
                    Text("漏电互感器规格",
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _getLeakageCurrent(),
                        textAlign: TextAlign.right,
                        style: new TextStyle(
                            fontSize: prefix0.fontsSize
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    ScrollController _controller4 = TrackingScrollController();

    bool dataNotification4(ScrollNotification notification) {
      if (Platform.isIOS) {
        double height = notification.metrics.maxScrollExtent; //step2的高度
        height = height + 80;
        if (notification.metrics.extentBefore > height) {
          //下滑到最底部
          _pageController.animateToPage(4,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        } //滑动到最顶部
        if (notification.metrics.extentAfter > height) {
          _pageController.animateToPage(2,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      } else if (Platform.isAndroid) {
        //android相关代码
        if (notification is ScrollEndNotification) {
          if (notification.metrics.extentAfter == 0) {
            //下滑到最底部
            _pageController.animateToPage(4,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          } //滑动到最顶部
          if (notification.metrics.extentBefore == 0) {
            _pageController.animateToPage(2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        }
      }
      return true;
    }

    Widget step4 = Container(
        color: prefix0.LIGHT_LINE_COLOR,
        padding: new EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: new NotificationListener(
            onNotification: dataNotification4,
            child: new Column(
//          physics: NeverScrollableScrollPhysics(),
//          shrinkWrap: true,
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Row(children: <Widget>[
                      Padding(
                        child: new Text(
                          electricalItems[3],
                          style: TextStyle(color: Colors.grey,
                              fontSize: 18

                          ),
                        ),
                        padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
                      )
                    ]),
                    installationEnvironment2,
                  ],
                )
              ],
            )));

    ScrollController _controller5 = TrackingScrollController();

    bool dataNotification5(ScrollNotification notification) {
      if (Platform.isIOS) {
        double height = notification.metrics.maxScrollExtent; //step2的高度
        height = height + 80;
        if (notification.metrics.extentAfter > height) {
          _pageController.animateToPage(3,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      } else if (Platform.isAndroid) {
        //android相关代码
        if (notification is ScrollEndNotification) {
          if (notification.metrics.extentBefore == 0) {
            _pageController.animateToPage(3,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
          }
        }
      }
      return true;
    }

    Widget step5 = Container(
        color: prefix0.LIGHT_LINE_COLOR,
        padding: new EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: new NotificationListener(
            onNotification: dataNotification5,
            child: new Column(
//          physics: NeverScrollableScrollPhysics(),
//          shrinkWrap: true,
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Row(children: <Widget>[
                      Padding(
                        child: new Text(
                          electricalItems[4],
                          style: TextStyle(color: Colors.grey,
                              fontSize: 18

                          ),
                        ),
                        padding: new EdgeInsets.fromLTRB(20, 20, 20, 20),
                      )
                    ]),
                    perationEnvironment,
                    new Padding(padding: new EdgeInsets.fromLTRB(0, 0, 0, 20)),
                    perationEnvironment2,
                  ],
                )
              ],
            )));

    Widget container11 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("勘察点名称",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.editName.length > 0
                          ? this.fireModel.editName
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: editPurpose, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("勘察点用途",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.editPurpose.length > 0
                          ? this.fireModel.editPurpose
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: editAddress, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("具体地址",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.editAddress.length > 0
                          ? this.fireModel.editAddress
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: _locationSendToNative, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("定位地址",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.editPosition.length > 0
                          ? this.fireModel.editPosition
                          : "未定位",
                      textAlign: TextAlign.right,

                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                  new Offstage(
                      offstage: (this.fireModel.editPosition.length > 0)
                          ? false
                          : true,
                      child: Image.asset(
                        "assets/images/right_arrar.png",
                        width: 20,
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget container12 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("勘察点结构",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.editPointStructure.length > 0
                          ? this.fireModel.editPointStructure
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("勘察点面积(㎡)",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.editPointArea.length > 0
                          ? this.fireModel.editPointArea
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget container13 = Container(
      color: Colors.white,
      padding: new EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("现场负责人姓名",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.headPerson.length > 0
                          ? this.fireModel.headPerson
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("现场负责人电话",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.headPhone.length > 0
                          ? this.fireModel.headPhone
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("老板姓名",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.bossName.length > 0
                          ? this.fireModel.bossName
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: prefix0.LINE_COLOR,
            height: 1,
          ),
          GestureDetector(
            onTap: null, //写入方法名称就可以了，但是是无参的
            child: Container(
              alignment: Alignment.center,
              height: 60,
              child: new Row(
                children: <Widget>[
                  Text("老板电话",
                    style: new TextStyle(
                        fontSize: prefix0.fontsSize
                    ),
                  ),
                  Expanded(
                    child: Text(
                      this.fireModel.bossPhone.length > 0
                          ? this.fireModel.bossPhone
                          : "",
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                          fontSize: prefix0.fontsSize
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget bigContainer2 = Container(
      color: prefix0.LIGHT_LINE_COLOR,
      padding: new EdgeInsets.fromLTRB(0, 0, 0, 60),
      child: new Column(
//        scrollDirection: Axis.vertical,
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: container11,
          ),
          new Padding(
            padding: new EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: container12,
          ),
          new Padding(
            padding: new EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: container13,
          ),
        ],
      ),
    );

    Widget bigContainer = Container(
        color: prefix0.LIGHT_LINE_COLOR,
//        padding: new EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: new ListView(
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
//            Container(
//              child: step1,
//            ),
            bigContainer2,
            step1,

            step2,

            step3,
            step4,
            step5,
          ],
        ));

    return Scaffold(
      appBar: NavBar,
      body: bigContainer,
//      bottomSheet: bottomButton,
    );
  }
}

const electricalItems = [
  "1.电箱信息",
  "2.电箱照片",
  "3.安装环境",
  "4.运作环境",
  "5.设备预选",
];
