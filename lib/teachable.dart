import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Teachable extends StatefulWidget {
  // final String path;
  final String url;
  final Function(Map<String, double>)? results;
  final bool drawPose;
  const Teachable(
      {Key? key, required this.url, this.results, required this.drawPose})
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
        // initialUrl: "help/index.html",
        initialFile: "pose/index.html",
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            mediaPlaybackRequiresUserGesture: false,
            // debuggingEnabled: true,
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
                  mp[element.className] = element.probability;
                });
                widget.results!(mp);
              });
          // controller.addJavaScriptHandler(
          //     handlerName: 'handlerFoo',
          //     callback: (args) {
          //       // return data to the JavaScript side!
          //       print("Called");
          //       return {'url': widget.url, 'drawPose': widget.drawPose};
          //     });
          await controller.evaluateJavascript(source: "init(${widget.url})");
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
