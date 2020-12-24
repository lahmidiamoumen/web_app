import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Restos extends StatefulWidget {
  final String title;
  final String url;
  Restos({this.url, this.title});

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Restos>
    with SingleTickerProviderStateMixin {
  InAppWebViewController webView;
  String url = "https://allrestos.com/?search_term=&lcats";
  String titles = "Restos - allrestos";
  double progress = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(this.titles),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 1.0),
          child: progress < 1.0
              ? LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.blue,
                )
              : Container(),
        ),
      ),
      body: myBody(),
    );
  }

  Future<Null> _refresh() async {
    return await webView.reload();
  }

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
                            """document.getElementById('main-theme').style.top= '-80px';
                              document.getElementsByClassName('main-header')[0].style.display = 'none';
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
                            """document.getElementById('main-theme').style.top= '-80px';
                            document.getElementsByClassName('main-header')[0].style.display = 'none';
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
}
