import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_softkey/page/home_page.dart';
import 'package:flutter_softkey/page/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftKey',
      builder: BotToastInit(),
      navigatorObservers: [
        BotToastNavigatorObserver()
      ],
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Sarabun',
      ),
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => HomePage(),
        '/setting': (BuildContext context) => SettingsPage(true),
      },
    );
  }
}
