import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as ds;
import 'Home.dart';
import 'Maps.dart';
import 'Restos.dart';
import 'custom_icons_icons.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
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
      theme: ThemeData(primarySwatch: Colors.blue),
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
    //_onTab(1);
    _getSizes();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    if (Platform.isAndroid) ds.WebView.platform = ds.SurfaceAndroidWebView();
    _children = [
      Maps(),
      Home(),
      Restos(),
    ];
    super.initState();
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
//document.querySelector('.sticky-wrapper').classList.add('hidden');
