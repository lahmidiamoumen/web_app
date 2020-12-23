import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart' as ds;

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
      home: MyHomePage(url: "https://allrestos.com/"),
      title: 'allrestos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.url});
  final String url;

  @override
  _MyWebView createState() => _MyWebView(url: this.url);
}

class _MyWebView extends State<MyHomePage> {
  List<GlobalKey> _key = [GlobalKey(), GlobalKey(), GlobalKey()];
  List<double> pos = [60, 60, 60];
  int _currentIndex = 1;
  InAppWebViewController webView;
  _MyWebView({this.url});
  String url;
  String titles = 'Accueil | allrestos';
  double progress = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<Null> _refresh() async {
    return await webView.reload();
  }

  Future<Void> get home async {
    webView.loadUrl(url: "https://livesawa.com/");
    Navigator.pop(context);
    setState(() {
      this.url = "https://livesawa.com/";
      this.titles = 'Accueil | LiveSawa';
    });
  }

  Future<Void> get geoLoca async {
    await webView.loadUrl(url: "https://allrestos.com/index.php/restos-map/");
    Navigator.pop(context);
    setState(() {
      this.url = "https://allrestos.com/index.php/restos-map/";
      this.titles = 'Restos Map';
    });
  }

  Future<Void> get retos async {
    await webView.loadUrl(url: "https://allrestos.com/?search_term=&lcats");
    Navigator.pop(context);
    setState(() {
      this.url = "https://allrestos.com/?search_term=&lcats";
      this.titles = 'Restos';
    });
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) ds.WebView.platform = ds.SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: myChild(),
        bottomNavigationBar: bottomNavigationBar());
  }

  void _onTab(int value) {
    setState(() {
      //_currentIndex = value;
      switch (value) {
        case 0:
          geoLoca;
          break;
        case 1:
          home;
          break;
        case 2:
          retos;
          break;
        default:
      }
    });
  }



  Widget myChild() => NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.grey[100],
              pinned: false,
              floating: false,
              expandedHeight: 100.0,
              toolbarHeight: 60,
              flexibleSpace:_GridTitleText(this.titles),
            )
          ];
        },
        body: myBody(),
      );

  Widget myBody() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                  initialUrl: this.url,
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                    debuggingEnabled: false,
                  )),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onLoadStart:
                      (InAppWebViewController controller, String url) async {
                    await webView.evaluateJavascript(
                        source:
                            """document.getElementsByClassName('main-header')[0].style.display = 'none';
                                 document.getElementsByClassName('main-footer')[0].style.display = 'none';
                              """);
                    setState(() {
                      this.url = url;
                    });
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    await webView.evaluateJavascript(
                        source:
                            """document.getElementsByClassName('main-header')[0].style.display = 'none';
                                 document.getElementsByClassName('main-footer')[0].style.display = 'none';
                              """);
                    String tt = await controller.getTitle();
                    setState(() {
                      this.titles = tt;
                      this.url = url;
                    });
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
              ),
            ),
            /* ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (webView != null) {
                        webView.goBack();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (webView != null) {
                        webView.goForward();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      if (webView != null) {
                        webView.reload();
                      }
                    },
                  ),
                ],
              ) */
          ],
        ),
      ),
    );
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
                    icon: Icon(CustomIcons.chat, key: _key[2]), label: "Resto"),
              ],
              onTap: _onTab,
            ),
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
class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
                title: Text( text,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22.0)),
              );
  }
}
//document.querySelector('.sticky-wrapper').classList.add('hidden');
