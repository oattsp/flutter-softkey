import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

class SettingsPage extends StatefulWidget {
  bool arrow;

  SettingsPage(this.arrow);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController ctrlIPAddress = TextEditingController();
  TextEditingController ctrlPort = TextEditingController();
  TextEditingController ctrlChannel = TextEditingController();
  String version;
  bool isWakelock = false;

  @override
  void initState() {
    // TODO: implement initState
    _getSetting();
    _packageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.arrow,
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      validator: _validateIPAddress,
                      controller: ctrlIPAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          filled: true, labelText: 'IP ADDRESS'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      validator: _validatePort,
                      controller: ctrlPort,
                      style: TextStyle(fontSize: 20),
                      decoration:
                          InputDecoration(filled: true, labelText: 'PORT'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      validator: _validateChannel,
                      controller: ctrlChannel,
                      style: TextStyle(fontSize: 20),
                      decoration:
                          InputDecoration(filled: true, labelText: 'CHANNEL'),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WAKELOCK',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: isWakelock,
                          onChanged: (value) {
                            setState(() {
                              isWakelock = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'APP VERSION',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          version != null ? version : '',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: RaisedButton(
                            color: Colors.green,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'SAVE SETTING',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () => _saveSetting(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  String _validateIPAddress(String value) {
    if (isIP(value)) {
      return null;
    } else {
      return '??????????????????????????? IP ADDRESS ??????????????????????????????';
    }
  }

  String _validatePort(String value) {
    if (!isNumeric(value)) {
      return '??????????????????????????? PORT ??????????????????????????????';
    }
    int port = int.parse(value);
    if (port < 1024 || port > 65535) {
      return '??????????????????????????? PORT 1024-65535 ????????????????????????';
    } else {
      return null;
    }
  }

  String _validateChannel(String value) {
    if (!isNumeric(value)) {
      return '??????????????????????????? CHANNEL ??????????????????????????????';
    }
    int channel = int.parse(value);
    if (channel < 1 || channel > 32) {
      return '??????????????????????????? CHANNEL 1-32 ????????????????????????';
    } else {
      return null;
    }
  }

  Future _getSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ip = await prefs.get('ip');
    var port = await prefs.get('port');
    var channel = await prefs.get('channel');
    var wakelock = await prefs.getBool('wakelock');

    ip == null ? ctrlIPAddress.text = '192.168.1.44' : ctrlIPAddress.text = ip;
    port == null ? ctrlPort.text = '7777' : ctrlPort.text = port;
    channel == null ? ctrlChannel.text = '1' : ctrlChannel.text = channel;
    wakelock == null ? isWakelock = false : isWakelock = wakelock;
  }

  Future _saveSetting() async {
    if (_formKey.currentState.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('ip', ctrlIPAddress.text);
      await prefs.setString('port', ctrlPort.text);
      await prefs.setString('channel', ctrlChannel.text);
      await prefs.setBool('wakelock', isWakelock);
      print('save setting ok');
      Navigator.of(context).pop({'result': 'ok'});
    } else {
      print('save setting false');
    }
  }

  Future _packageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }
}
