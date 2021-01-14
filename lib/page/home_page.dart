import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_softkey/model/queue_model.dart';
import 'package:flutter_softkey/page/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController ctrlQueue = TextEditingController();
  Socket socketClient;
  String queueType = 'ทั้งหมด';
  var ip;
  var port;
  var channel;
  List<QueueModel> waits = [];
  List<QueueModel> holds = [];
  Timer reset;

  @override
  void initState() {
    // TODO: implement initState
    _getSetting();
    _handleAppLifecycleState();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    socketDisconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SoftKey'),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                var response =
                    await Navigator.of(context).pushNamed('/setting');
                if (response != null) {
                  await socketDisconnect();
                  setState(() {
                    waits = [];
                  });
                  ctrlQueue.text = '';
                  _getSetting();
                }
              })
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'Queue Types',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: DropdownButton(
              value: queueType,
              items: <String>[
                'ทั้งหมด',
                '1 ท่าน',
                '2 ท่าน',
                '3 ท่าน',
                '4 ท่าน',
                '5 ท่าน',
                '6 ท่านขึ้นไป'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String value) {
                setState(() {
                  queueType = value;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Container(
                color: Color.fromRGBO(39, 39, 37, 1),
                child: Builder(
                    builder: (context) {
                      if (queueType == '1 ท่าน') {
                        return customListView(waits.where((element) => element.group == 1).toList());
                      } else if (queueType == '2 ท่าน') {
                        return customListView(waits.where((element) => element.group == 2).toList());
                      } else if (queueType == '3 ท่าน') {
                        return customListView(waits.where((element) => element.group == 3).toList());
                      } else if (queueType == '4 ท่าน') {
                        return customListView(waits.where((element) => element.group == 4).toList());
                      } else if (queueType == '5 ท่าน') {
                        return customListView(waits.where((element) => element.group == 5).toList());
                      } else if (queueType == '6 ท่านขึ้นไป') {
                        return customListView(waits.where((element) => element.group == 6).toList());
                      } else {
                        return customListView(waits);
                      }
                    }
                )
              ),
            ),
          ),
          Container(
            height: 73,
            child: Card(
              color: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 100,
                    child: TextFormField(
                      controller: ctrlQueue,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'QUEUE',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(left: 10),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: Color.fromRGBO(39, 39, 37, 1),
                    onPressed: () {
                      FocusManager.instance.primaryFocus.unfocus();
                      String number = ctrlQueue.text.trim();
                      if (number.length > 0 && number.length < 5) {
                        _callQueue(number);
                      } else {
                        BotToast.showText(
                            text: 'กรุณาระบุหมายเลขคิว 1-4 หลัก',
                            duration: Duration(seconds: 2),
                            contentColor: Colors.red);
                      }
                    },
                    child: Text('CALL',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  RaisedButton(
                    color: Color.fromRGBO(39, 39, 37, 1),
                    onPressed: () {
                      FocusManager.instance.primaryFocus.unfocus();
                      String number = ctrlQueue.text.trim();
                      if (number.length > 0 && number.length < 5) {
                        _holdQueue(number);
                      } else {
                        BotToast.showText(
                            text: 'กรุณาระบุหมายเลขคิว 1-4 หลัก',
                            duration: Duration(seconds: 2),
                            contentColor: Colors.red);
                      }
                    },
                    child: Text('HOLD',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  RaisedButton(
                    color: Color.fromRGBO(39, 39, 37, 1),
                    onPressed: () {
                      FocusManager.instance.primaryFocus.unfocus();
                      String number = ctrlQueue.text.trim();
                      if (number.length > 0 && number.length < 5) {
                        _endQueue(number);
                      } else {
                        BotToast.showText(
                            text: 'กรุณาระบุหมายเลขคิว 1-4 หลัก',
                            duration: Duration(seconds: 2),
                            contentColor: Colors.red);
                      }
                    },
                    child: Text('END',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Color.fromRGBO(39, 39, 37, 1),
        child: Row(
          children: [
            Expanded(
                child: FlatButton(
              onPressed: () {
                holdDialog();
              },
              child: Text(
                'HOLD LIST',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget customListView(List data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
            const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: Card(
                color: Color.fromRGBO(159, 145, 89, 1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '${data[index].number}',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(39, 39, 37, 1)),
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(39, 39, 37, 1),
                        onPressed: () {
                          FocusManager.instance.primaryFocus.unfocus();
                          _callQueue(data[index].number);
                        },
                        child: Text(
                          'CALL',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(39, 39, 37, 1),
                        onPressed: () {
                          FocusManager.instance.primaryFocus.unfocus();
                          _holdQueue(data[index].number);
                        },
                        child: Text(
                          'HOLD',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(39, 39, 37, 1),
                        onPressed: () {
                          FocusManager.instance.primaryFocus.unfocus();
                          _endQueue(data[index].number);
                        },
                        child: Text(
                          'END',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      )
                    ],
                  ),
                )),
          );
        });
  }

  Widget setupAlertDialogContainer() {
    return Container(
      height: 314,
      width: 300,
      color: Color.fromRGBO(39, 39, 37, 1),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: holds.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding:
            const EdgeInsets.only(left: 5, right: 5, top: 5),
            child: Card(
                color: Color.fromRGBO(159, 145, 89, 1),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        holds[index].number,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(39, 39, 37, 1)),
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(39, 39, 37, 1),
                        onPressed: () {
                          FocusManager.instance.primaryFocus.unfocus();
                          _callQueue(holds[index].number);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'CALL',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(39, 39, 37, 1),
                        onPressed: () {
                          FocusManager.instance.primaryFocus.unfocus();
                          _endQueue(holds[index].number);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'END',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      )
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }

  Future holdDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('HOLD LIST', style: TextStyle(fontWeight: FontWeight.bold),),
          content: setupAlertDialogContainer(),
          actions: [
            FlatButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: Text('Close'))
          ],
        );
    });
  }

  Future _getSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _ip = await prefs.get('ip');
    var _port = await prefs.get('port');
    var _channel = await prefs.get('channel');

    if (_ip == null || _port == null || _channel == null) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => SettingsPage(false)));
      _getSetting();
    }

    try {
      ip = _ip;
      port = int.parse(_port);
      channel = int.parse(_channel);
      await socketConnect();
    } catch (ex) {

    }
  }

  Future _callQueue(String number) async {
    if (socketClient == null) {
      await socketConnect();
      Timer(Duration(seconds: 2), () {
        _callQueue(number);
      });
    } else {
      socketClient.write('CALL,A5,$number,256,$channel,256,\r\n');
      reset = Timer(Duration(seconds: 2), () => socketDisconnect());
    }
  }

  Future _holdQueue(String number) async {
    if (socketClient == null) {
      await socketConnect();
      Timer(Duration(seconds: 2), () {
        _holdQueue(number);
      });
    } else {
      socketClient.write('HOLD,A5,$number,1,1,$channel,\r\n');
      reset = Timer(Duration(seconds: 2), () => socketDisconnect());
    }
  }

  Future _endQueue(String number) async {
    if (socketClient == null) {
      await socketConnect();
      Timer(Duration(seconds: 2), () {
        _endQueue(number);
      });
    } else {
      socketClient.write('ENDQ,A5,$number,256,$channel,0,0,0,1,\r\n');
      reset = Timer(Duration(seconds: 2), () => socketDisconnect());
    }
  }

  Future resetTimer() async {
    if (reset != null) {
      reset.cancel();
      reset = null;
    }
  }

  Future socketConnect() async {
    print('socket connect to server at $ip');
    socketClient = await Socket.connect(ip, port, timeout: Duration(seconds: 5))
        .catchError((error) {
      BotToast.showSimpleNotification(
          title: 'ไม่สามารถเชื่อมต่อไปยัง $ip ได้',
          duration: Duration(seconds: 5));
    });
    if (socketClient != null) {
      socketClient.write('SYNC,A5,$channel,\r\n');
      listen();
    }
  }

  Future socketDisconnect() async {
    if (socketClient != null) {
      await socketClient.close();
    }
  }

  listen() {
    if (socketClient != null) {
      socketClient.listen(
        (data) {
          String dataStr = String.fromCharCodes(data).trim();
          print(dataStr);
          List<String> result = dataStr.split('\r\n');
          for (var i=0; i<result.length; i++) {
            String tempCommand = result[i];
            List<String> tempList = tempCommand.split(',');

            if (tempList[0] == 'GNUM') {
              int group = int.parse(tempList[1]) + 1;
              setState(() {
                waits.removeWhere((element) => element.group == group);
              });
              int startIndex = tempCommand.indexOf('{');
              int endIndex = tempCommand.indexOf('}');
              String _queue = tempCommand.substring(startIndex, endIndex+1);
              Map _queueJson = json.decode(_queue);
              _queueJson.forEach((key, value) {
                int id = int.parse(key.split('+')[0]);
                String number = value;
                setState(() {
                  waits.add(QueueModel(id, number, group));
                  waits.sort((a, b) => a.id.compareTo(b.id));
                });
              });
            }

            if (tempList[0] == 'QHOL') {
              int group = int.parse(tempList[1]) + 1;
              setState(() {
                holds.removeWhere((element) => element.group == group);
              });
              int startIndex = tempCommand.indexOf('{');
              int endIndex = tempCommand.indexOf('}');
              String _queue = tempCommand.substring(startIndex, endIndex+1);
              Map _queueJson = json.decode(_queue);
              _queueJson.forEach((key, value) {
                int id = int.parse(key);
                String number = value;
                setState(() {
                  holds.add(QueueModel(id, number, group));
                  holds.sort((a, b) => a.id.compareTo(b.id));
                });
              });
            }

            if (tempList[0] == 'CALL') {
              resetTimer();
              if (tempList[1] == '00') {
                ctrlQueue.text = tempList[2].trim();
                BotToast.showText(
                    text: 'กำลังเรียกคิว ${tempList[2].trim()}',
                    duration: Duration(seconds: 2),
                    contentColor: Colors.red,
                    align: Alignment(0, 0.55),
                    contentPadding: const EdgeInsets.all(10.0),
                    textStyle: TextStyle(fontSize: 18, color: Colors.white)
                );
              }
              if (tempList[1] == '02') {
                BotToast.showText(
                    text: 'โปรดรอสักครู่ กำลังเรียกคิวอื่นอยู่',
                    duration: Duration(seconds: 2),
                    contentColor: Colors.red,
                    align: Alignment(0, 0.55),
                    contentPadding: const EdgeInsets.all(10.0),
                    textStyle: TextStyle(fontSize: 18, color: Colors.white)
                );
              }
            }

            if (tempList[0] == 'HOLD') {
              resetTimer();
              if (tempList[1] == '00') {
                ctrlQueue.text = '';
                BotToast.showText(
                    text: 'โฮลด์คิว ${tempList[3].trim()} แล้ว',
                    duration: Duration(seconds: 2),
                    contentColor: Colors.red,
                    align: Alignment(0, 0.55),
                    contentPadding: const EdgeInsets.all(10.0),
                    textStyle: TextStyle(fontSize: 18, color: Colors.white)
                );
              }
            }

            if (tempList[0] == 'ENDQ') {
              resetTimer();
              if (tempList[1] == '00') {
                ctrlQueue.text = '';
                BotToast.showText(
                    text: 'จบคิว ${tempList[2].trim()} แล้ว',
                    duration: Duration(seconds: 2),
                    contentColor: Colors.red,
                    align: Alignment(0, 0.55),
                    contentPadding: const EdgeInsets.all(10.0),
                    textStyle: TextStyle(fontSize: 18, color: Colors.white)
                );
              }
            }
          }
        },
        onDone: () {
          print('client socket has terminated.');
          if (socketClient != null) {
            socketClient.destroy();
            socketClient = null;
          }
        },
        onError: (err) {
          print('client socket error message = $err');
          if (socketClient != null) {
            socketClient.destroy();
            socketClient = null;
          }
        },
      );
    }
  }

  _handleAppLifecycleState() {
    SystemChannels.lifecycle.setMessageHandler((String msg) {
      print('SystemChannels> $msg');
      try {
        if (msg == 'AppLifecycleState.paused') {
          if (socketClient != null) {
            socketDisconnect();
          }
        }
        if (msg == 'AppLifecycleState.resumed') {
          _getSetting();
        }
      } catch (ex) {
        print(ex);
      }
      return;
    });
  }
}
