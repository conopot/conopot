import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TimbreScreen extends StatefulWidget {
  TimbreScreen({Key? key}) : super(key: key);

  @override
  State<TimbreScreen> createState() => _TimbreScreenState();
}

class _TimbreScreenState extends State<TimbreScreen> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl:
              'https://conopot.netlify.app/',
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
        ),
      ),
    );
  }
}
