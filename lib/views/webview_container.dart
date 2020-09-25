import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  final _key = UniqueKey();
  _WebViewContainerState(this._url);

  @override
  Widget build(BuildContext context) {
    return WebView(
      key: _key,
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: _url,
      onWebViewCreated: (WebViewController webViewController) {
        print("Webview created");
      },
    );
  }
}

class WebViewContainer extends StatefulWidget {
  final url;
  WebViewContainer(this.url);
  @override
  createState() => _WebViewContainerState(this.url);
}
