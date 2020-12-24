import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_icons_icons.dart';

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
    final AlertDialog alertDialog = AlertDialog(
      title: Text('À propos de nous'),
      content: Text(
          "A pour vocation de vous faire découvrir les restaurants d’Algérie et  de vous offrir un panel de découvertes culinaires," +
              " en commençant par la capitale Alger suivi des autres villes et wilaya qui s'étendent sur tout le territoire algérien. "),
      actions: [
        FlatButton(
          textColor: Color(0xFF37af7a),
          onPressed: () => Navigator.pop(context),
          child: Text('Fermer'),
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(this.titles),
        actions: <Widget>[
          PopupMenuButton(
              icon: Icon(CustomIcons.cog_1),
              onSelected: (result) {
                if (result == 0) {
                  webView.evaluateJavascript(
                      source:
                          """document.getElementsByClassName('logreg-modal-open')[0].click();""");
                } else if (result == 1) {
                  showDialog<void>(
                      context: context, builder: (context) => alertDialog);
                } else if (result == 2) {
                  webView.reload();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      child: ListTile(
                        leading: Icon(CustomIcons.arrows_ccw),
                        title: Text('Actualiser'),
                      ),
                      value: 2,
                    ),
                    const PopupMenuItem(
                      child: ListTile(
                        leading: Icon(CustomIcons.login),
                        title: Text('Se connecter'),
                      ),
                      value: 0,
                    ),
                    const PopupMenuItem(
                      child: ListTile(
                        leading: Icon(CustomIcons.help),
                        title: Text('À propos'),
                      ),
                      value: 1,
                    )
                  ]),
        ],
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 1.0),
          child: progress < 1.0
              ? LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white,
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
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    String tt = await controller.getTitle();
                    setState(() {
                      this.titles = tt;
                      this.url = url;
                    });
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    if (progress == 80) {
                      webView.evaluateJavascript(
                          source:
                              """document.getElementById('main-theme').style.top= '-80px';
                                  document.getElementsByClassName('main-header')[0].style.display = 'none';
                                  document.getElementsByClassName('main-footer')[0].style.display = 'none';
                                """);
                    }
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
