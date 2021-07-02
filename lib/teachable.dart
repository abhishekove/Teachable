import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Teachable extends StatefulWidget {
  // final String path;
  final String path;
  final Function(String)? results;
  const Teachable({Key? key, required this.path, this.results})
      : super(key: key);

  @override
  _TeachableState createState() => _TeachableState();
}

class _TeachableState extends State<Teachable> {
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(useHybridComposition: true),
  );
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
        initialFile: widget.path,
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        onWebViewCreated: (InAppWebViewController controller) async {
          var _webViewController = controller;
          _webViewController.addJavaScriptHandler(
              handlerName: "updater",
              callback: (args) {
                List predictions = args[0];
                Map<String, double> mp = new Map();
                predictions.forEach((element) {
                  mp[element["className"]] = element["probability"];
                });
                widget.results!(JsonEncoder().convert(mp));
              });
        },
        androidOnPermissionRequest: (InAppWebViewController controller,
            String origin, List<String> resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        });
    // );
  }
}
