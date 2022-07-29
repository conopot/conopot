import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChannelTalkScreen extends StatefulWidget {
  ChannelTalkScreen({Key? key}) : super(key: key);

  @override
  State<ChannelTalkScreen> createState() => _ChannelTalkScreenState();
}

class _ChannelTalkScreenState extends State<ChannelTalkScreen> {
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
          initialUrl: 'https://5qy1e.channel.io',
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
        ),
      ),
    );
  }
}
