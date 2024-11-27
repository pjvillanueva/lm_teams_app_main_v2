import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../widgets/frames.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({Key? key, required this.title, required this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  State<AppWebView> createState() => _AppWebViewState();
}

class _AppWebViewState extends State<AppWebView> {
  double _progress = 0;
  // ignore: unused_field
  late InAppWebViewController _inAppWebViewController;
  @override
  Widget build(BuildContext context) {
    return AppFrame(
        padding: 0,
        title: widget.title,
        content: Stack(children: [
          InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (controller) {
                _inAppWebViewController = controller;
              },
              onProgressChanged: (InAppWebViewController controller, int progress) {
                setState(() {
                  _progress = progress / 100;
                });
              }),
          _progress < 1 ? LinearProgressIndicator(value: _progress) : Container()
        ]));
  }
}
