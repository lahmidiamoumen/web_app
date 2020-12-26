import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as ds;
import 'Home.dart';
import 'Maps.dart';
import 'Restos.dart';
import 'custom_icons_icons.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

// const MethodChannel _channel = MethodChannel('default_notification_channel_id');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'moumenLahmidi2012',
  'com.google.firebase.messaging.default_notification_channel_id',
  '',
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
);

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the background messaging handler early on, as a named top-level function
  setFirebase();
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
  runApp(MyApp());
}


void setFirebase() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('icon_notif');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectNotificationSubject.add(payload);
  });


}

//updated myBackgroundMessageHandler
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print("myBackgroundMessageHandler message: $message");
  int msgId = int.tryParse(message["data"]["id"].toString()) ?? 0;
  print("msgId $msgId");
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('moumenLahmidi2012',
          'com.google.firebase.messaging.default_notification_channel_id', '',
          color: Colors.blue,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  var flutterLocalNotificationsPlugin;
  await flutterLocalNotificationsPlugin.show(msgId, message["data"]["msgTitle"],
      message["data"]["msgBody"], platformChannelSpecifics,
      payload: message["data"]["data"]);
  return Future<void>.value();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/main',
      routes: {
        '/main': (context) => MyHomePage(),
        '/home': (context) => Home(
            url: "https://allrestos.com/", title: "Restos Map - allrestos"),
        '/map': (context) => Maps(
            url: "https://allrestos.com/index.php/restos-map/",
            title: "Accueil | allrestos"),
        '/restos': (context) => Restos(
            url: "https://allrestos.com/?search_term=&lcats",
            title: "Restos - allrestos"),
      },
      theme: ThemeData(primaryColor: Colors.white),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyWebView createState() => _MyWebView();
}

class _MyWebView extends State<MyHomePage> {
  List<GlobalKey> _key = [GlobalKey(), GlobalKey(), GlobalKey()];
  List<double> pos = [60, 60, 60];
  int _currentIndex = 1;
  List<Widget> _children;

  void _getSizes() {
    for (int i = 0; i < _key.length; i++) {
      RenderBox renderBoxRed = _key[i].currentContext.findRenderObject();
      pos[i] = renderBoxRed.localToGlobal(Offset.zero).dx + 10;
    }
  }

  void _onTab(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  void _afterLayout(_) {
    _onTab(1);
    _getSizes();
  }

Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("Item ${item.itemId} has been updated"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    if (Platform.isAndroid) ds.WebView.platform = ds.SurfaceAndroidWebView();
    _children = [
      Maps(),
      Home(),
      Restos(),
    ];
    _configureSelectNotificationSubject();
  }

  void _configureSelectNotificationSubject() {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.subscribeToTopic('TopicToListen');

   _firebaseMessaging.configure(
      onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _children[_currentIndex],
        bottomNavigationBar: bottomNavigationBar());
  }


  Widget bottomNavigationBar() {
    return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Stack(
          children: <Widget>[
            BottomNavigationBar(
                showUnselectedLabels: false,
                showSelectedLabels: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIconTheme: IconThemeData(color: Colors.black, size: 26),
                currentIndex: _currentIndex,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.compass_1, key: _key[0]),
                      label: "Map"),
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.home_1, key: _key[1]),
                      label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(CustomIcons.chat, key: _key[2]),
                      label: "Resto"),
                ],
                onTap: _onTab),
            AnimatedPositioned(
              duration: Duration(microseconds: 300),
              left: pos[_currentIndex],
              bottom: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ));
  }
}

class _GridTitleText extends StatefulWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  __GridTitleTextState createState() => __GridTitleTextState();
}

class __GridTitleTextState extends State<_GridTitleText> {
  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      title: Text(widget.text,
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.black87, fontSize: 22.0)),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen(
    this.payload, {
    Key key,
  }) : super(key: key);

  final String payload;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Second Screen with payload: ${_payload ?? ''}'),
        ),
        body: Center(
          child: RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go back!'),
          ),
        ),
      );
}

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = data['status'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(itemId),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);
  final String itemId;
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Item _item;
  StreamSubscription<Item> _subscription;

  @override
  void initState() {
    super.initState();
    _item = _items[widget.itemId];
    _subscription = _item.onChanged.listen((Item item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Item ${_item.itemId}"),
      ),
      body: Material(
        child: Center(child: Text("Item status: ${_item.status}")),
      ),
    );
  }
}

//document.querySelector('.sticky-wrapper').classList.add('hidden');
